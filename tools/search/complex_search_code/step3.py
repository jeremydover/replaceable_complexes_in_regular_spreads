import sys
from ortools.sat.python import cp_model
from array import *
from step2 import circles
from itertools import chain

class SolutionPrinter(cp_model.CpSolverSolutionCallback):
	"""Print intermediate solutions."""

	def __init__(self, variables, myID):
		cp_model.CpSolverSolutionCallback.__init__(self)
		self.__variables = variables
		self.__solution_count = 0
		self.__id = myID

	def OnSolutionCallback(self):
		self.__solution_count += 1
		cntr = 0
		#for v in self.__variables:
		#	print(v)
		#	print(str(self.Value(v)))
		
		first = 0
		resStr = '['
		for v in self.__variables:
			if self.Value(v) == 1:
				if first != 0:
					resStr = resStr + ','
				else:
					first = 1
				resStr = resStr + str(v)
		resStr = resStr + ']'
		if self.__id in results:
			results[self.__id] = results[self.__id] + ',' + resStr
		else:
			results[self.__id] = resStr

	def SolutionCount(self):
		return self.__solution_count
	
def main():
	global results
	results = dict()
	for myID in circles:
		if len(circles[myID]) == 0:
			continue
		model = cp_model.CpModel()	
		covered = set(chain.from_iterable(circles[myID]))
		pointCovered = dict()
		for p in covered:
			pointCovered[p] = model.NewIntVar(0,2,str(p))
			
		pointSums = dict()
		circleBools = dict()
		circleInts = dict()
		for x in circles[myID]:
			circleString = '{'+','.join(map(str,x))+'}'
			circleBools[circleString] = model.NewBoolVar(circleString)
			circleInts[circleString] = model.NewIntVar(0,1,circleString)
			model.Add(circleInts[circleString] == 1).OnlyEnforceIf(circleBools[circleString])
			model.Add(circleInts[circleString] == 0).OnlyEnforceIf(circleBools[circleString].Not())
			first = True
			for p in x:
				if first:
					first = False
				else:
					model.Add(pointCovered[p] == pointCovered[lastP]).OnlyEnforceIf(circleBools[circleString])
				if p in pointSums:
					pointSums[p] = pointSums[p] + circleInts[circleString]
				else:
					pointSums[p] = circleInts[circleString]
				lastP = p
		
		for p in covered:
			model.Add(pointCovered[p] == pointSums[p])
		
		# To avoid the empty solution
		model.Add(sum(circleInts.values()) > 0)
		
		solver = cp_model.CpSolver()
		solution_printer = SolutionPrinter(circleBools.values(),myID)
		status = solver.SearchForAllSolutions(model, solution_printer)

	outfile = "tools/search/complex_search_code/step3.out"
	with open(outfile, "w") as f:
		f.write("C:=AssociativeArray();\n")
		for myID in sorted(results):
			f.write(f'C["{myID}"]:=[{results[myID]}];\n')

if __name__ == '__main__':
	main()
