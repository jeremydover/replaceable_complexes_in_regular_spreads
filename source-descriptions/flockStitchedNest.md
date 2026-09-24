# Flock-Stitched Nest Constructions

## Reference
Dover, J.M., Nests and nest accessories. Preprint.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for the flock-stitched nest construction; q must be an odd prime power.

orbit_circles
=============
Type: Sequence of integers
Description: The vector representations of circles <lambda,s> whose orbits under the index 2 subgroup of the group cyclically permuting the points in the flock circles form part of the nest. Each of lambda and s is in GF(q^2), and thus is represented by a sequence of length 2e, where q=p^e, of elements of GF(p). All elements are concatenated into a single sequence.

flock_circles
=============
Type: Sequence of integers
Description: The vector representations of circles <0,s> in the flock which are contained in the nest. For brevity, the leading 0 is omitted, and just the vector representation of s is provided.

### Example
```json
{"q":5,"orbit_circles":[4,0,3,1,4,4,1,0],"flock_circles":[1,0]}
```

## Implementation

### Function

flockStitchedNestImplementation(q,orbit_circles,flock_circles);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
orbit_circles: sequence of integers representing circles as above
flock_circles: sequence of integers representing circles as above

### Output

If successful, a web representing a flock-stitched nest, which consists of the union of orbits under the index 2 subgroup of the group which cyclically permutes the points on each circle in a linear flock.