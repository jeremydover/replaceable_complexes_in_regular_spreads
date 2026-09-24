/*Search program for spreads of designs.*/
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <gmp.h>
#include <omp.h>
#include "geometry.h"
#define DEBUG 0

typedef struct {
	int size;
	int circles[MAXNESTSIZE];
} Nest;

typedef struct {
	Nest *data;
	size_t count;
	size_t capacity;
} NestBuffer;

void initNestBuffer(NestBuffer *b) {
	b->count = 0;
	b->capacity = 1024;
	b->data = malloc(b->capacity * sizeof(Nest));
}

void storeNest(NestBuffer *b, int size, int *nest) {
	if (b->count == b->capacity) {
		b->capacity *= 2;
		b->data = realloc(b->data, b->capacity * sizeof(Nest));
	}
	Nest *n = &b->data[b->count++];
	n->size = size;
	for (int i = 0; i < size; i++) n->circles[i] = nest[i];
}

typedef struct {
    int nest[MAXNESTSIZE];
    mpz_t candidateCircles[MAXNESTSIZE + 1];
    mpz_t covered1[MAXNESTSIZE];
    mpz_t availableCircles[MAXNESTSIZE];
} SearchWorkspace;

void initWorkspace(SearchWorkspace *w) {
    for (int i = 0; i < MAXNESTSIZE + 1; i++) {
        mpz_init2(w->candidateCircles[i], NUMBLOCKS);
        if (i < MAXNESTSIZE) {
            mpz_init2(w->covered1[i], NUMPOINTS);
            mpz_init2(w->availableCircles[i], NUMBLOCKS);
        }
    }
}

void addCircle(int currentSize, int circleIndex, int *nest, mpz_t *covered1, mpz_t *availableCircles){
	mpz_t temp;
	mpz_init(temp);
	mpz_t temp1;
	mpz_init(temp1);
	
	nest[currentSize]=circleIndex;
	mpz_xor(covered1[currentSize],covered1[currentSize-1],blockpoint[circleIndex]);
	mpz_and(temp,covered1[currentSize-1],blockpoint[circleIndex]);
	mpz_set(availableCircles[currentSize],availableCircles[currentSize-1]);
	for (mp_bitcnt_t j = mpz_scan1(temp, 0); j != ~(mp_bitcnt_t)0; j = mpz_scan1(temp, j + 1)){
		mpz_com(temp1,pointblock[j]);
		mpz_and(availableCircles[currentSize],availableCircles[currentSize],temp1);
	}
	
	mpz_clear(temp);
	mpz_clear(temp1);
}

int nextStepCandidates(int currentSize, mpz_t *covered1, mpz_t *availableCircles, mpz_t *candidateCircles){
	int minPoint = -1;
	mp_bitcnt_t minCount=NUMBLOCKS+1;
	mpz_set_ui(candidateCircles[currentSize],0);
	mpz_t temp;
	mpz_init(temp);
	
	for (mp_bitcnt_t i = mpz_scan1(covered1[currentSize-1], 0); i != ~(mp_bitcnt_t)0; i = mpz_scan1(covered1[currentSize-1], i + 1)){
		mpz_and(temp,availableCircles[currentSize-1],pointblock[i]);
		mp_bitcnt_t tempCount = mpz_popcount(temp);
		if (tempCount < minCount){
			minPoint = i;
			minCount = tempCount;
			mpz_set(candidateCircles[currentSize],temp);
			if (minCount == 0) break;
		}
	}
	
	mpz_clear(temp);
	if (minCount == 0){ minPoint = -1; }
	return minPoint;
}

int search(mpz_t starter, NestBuffer *results, SearchWorkspace *w){
	int currentSize = 0;
	int state = 1;
	
	/*We're ready to take a step*/
	int nextStepPoint;
	mp_bitcnt_t nextCircle;
	
	/*Fill initial arrays with data from the starter.*/
	for (mp_bitcnt_t i = mpz_scan1(starter, 0); i != ~(mp_bitcnt_t)0; i = mpz_scan1(starter, i + 1)){
		/*i is the index of a circle in the starter*/
		if (currentSize == 0){
			w->nest[currentSize] = i;
			mpz_set(w->covered1[currentSize],blockpoint[i]);
			mpz_set_ui(w->availableCircles[currentSize],0);
			mpz_setbit(w->availableCircles[currentSize],NUMBLOCKS);
			mpz_sub_ui(w->availableCircles[currentSize],w->availableCircles[currentSize],1);
			mpz_clrbit(w->availableCircles[currentSize],i);
		}
		else{
			addCircle(currentSize,i,w->nest,w->covered1,w->availableCircles);
		}
		mpz_set_ui(w->candidateCircles[currentSize],0);
		currentSize++;
	}
	
	nextStepPoint = nextStepCandidates(currentSize,w->covered1,w->availableCircles,w->candidateCircles);
	if (nextStepPoint == -1){
		/* There are no ways to continue, even from the starter. No need to backtrack, as there are no other candidates.*/
		state = 3;
	}
	
	while (state < 3){
		if (state == 1){
			/* In this state, we have a non-empty candidate list. We pick the smallest on the list, and add the circle.*/
			nextCircle=mpz_scan1(w->candidateCircles[currentSize],0);
			mpz_clrbit(w->candidateCircles[currentSize],nextCircle);
			addCircle(currentSize,nextCircle,w->nest,w->covered1,w->availableCircles);
			currentSize++;
			if (mpz_sgn(w->covered1[currentSize-1]) == 0){
				/*This is a nest.*/
				storeNest(results, currentSize, w->nest);
				state = 2;
			}
			else{
				if (currentSize >= MAXNESTSIZE){
					state = 2;
				}
				else{
					nextStepPoint = nextStepCandidates(currentSize,w->covered1,w->availableCircles,w->candidateCircles);
					if (nextStepPoint == -1){
						state = 2;
					}
				}
			}
		}
		
		if (state == 2){
			/*We are in state 2 if we do not wish to take further steps with the current partial.*/
			currentSize--;
			if (currentSize == -1){
				state = 3;
			}
			else{
				if (mpz_sgn(w->candidateCircles[currentSize]) == 0){
					state = 2;
				}
				else{
					state = 1;
				}
			}
		}
	}
		
	return 0;
}

int main(){
	/* Set up results structures for worker threads.*/
	NestBuffer *results;
	SearchWorkspace *workspaces;
	int numThreads = omp_get_max_threads();
	results = malloc(numThreads * sizeof(NestBuffer));
	if (results == NULL){
		fprintf(stderr, "Could not allocate result buffers.\n");
		return 1;
	}
	for (int i = 0; i < numThreads; i++){
		initNestBuffer(&results[i]);
	}
	
	workspaces = malloc(numThreads * sizeof(SearchWorkspace));
	for (int i = 0; i < numThreads; i++){
		initWorkspace(&workspaces[i]);
	}
	
	/* Load geometry data. */
	#include "geometry_init.h"
	
	/* Load starters. */
	mpz_t *starters = malloc(NUMSTARTERS * sizeof(mpz_t));
	if (starters == NULL){
		fprintf(stderr, "Could not allocate space for all starters.\n");
		return 1;
	}
	
	FILE *f = fopen("tools/search/web_search_code/starters.txt","r");
	char *line = NULL;
    size_t len = 0;

    for (long i = 0; i < NUMSTARTERS; i++) {
        if (getline(&line,&len,f) == -1) {
            fprintf(stderr,"Unexpected EOF at starter %ld\n",i);
            exit(EXIT_FAILURE);
        }

        mpz_init2(starters[i],NUMBLOCKS);

        if (mpz_set_str(starters[i],line,16) != 0) {
            fprintf(stderr,"Invalid starter at line %ld\n",i);
            exit(EXIT_FAILURE);
        }
    }
    free(line);
    fclose(f);
	
	#pragma omp parallel for schedule(dynamic, 1)
	for (long i = 0; i < NUMSTARTERS; i++){
		int tid=omp_get_thread_num();
		int work=search(starters[i],&results[tid],&workspaces[tid]);
		if (work!=0){
			#pragma omp critical
			{fprintf(stderr,"Search failed on starter %ld with code %d\n",i,work);}
		}
	}
	
	FILE *outfile=fopen("nests.out","w");
	for (int i = 0;i < numThreads;i++){
		for (size_t j = 0;j < results[i].count; j++){
			Nest *n = &results[i].data[j];
			fprintf(outfile,"{");
			bool firstinNest = true;
			for (int k = 0;k < n->size;k++){
				if (firstinNest) {
					firstinNest = false;
				}
				else{
					fprintf(outfile,",");
				}
				fprintf(outfile,"%s",circleCoordinates[n->circles[k]]);
			}
			fprintf(outfile,"}\n");
		}
	}
	fclose(outfile);
	return 0;
}