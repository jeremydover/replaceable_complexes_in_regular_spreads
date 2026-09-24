import sys
from ortools.sat.python import cp_model
from array import *
from itertools import chain

class SolutionPrinter(cp_model.CpSolverSolutionCallback):
	"""Print intermediate solutions."""

	def __init__(self, variables):
		cp_model.CpSolverSolutionCallback.__init__(self)
		self.__variables = variables
		self.__solution_count = 0
		self.__results = ''

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
		if len(self.__results) > 0:
			self.__results = self.__results + ',' + resStr
		else:
			self.__results = resStr

	def SolutionCount(self):
		return self.__solution_count
		
	def GetResults(self):
		return self.__results

def read_sets(filename):
	with open(filename) as f:
		return [eval(line.strip()) for line in f if line.strip()];
	
def main():
	global results
	circles = read_sets("tools/search/stitchcircles.txt")
	carriedCircles = read_sets("tools/search/carriedcircles.txt")
	orbits = read_sets("tools/search/stitchorbits.txt")
	model = cp_model.CpModel()
	
	orbitSums = dict()
	circleBools = dict()
	circleInts = dict()
	for x in circles:
		circleString = frozenset(x)
		circleBools[circleString] = model.NewBoolVar(str(x))
		circleInts[circleString] = model.NewIntVar(0,1,str(x))
		model.Add(circleInts[circleString] == 1).OnlyEnforceIf(circleBools[circleString])
		model.Add(circleInts[circleString] == 0).OnlyEnforceIf(circleBools[circleString].Not())
		
		for y in orbits:
			o = frozenset(y)
			if len(x & y) > 0:
				if o not in orbitSums:
					orbitSums[o] = len(x & y)*circleInts[circleString]
				else:
					orbitSums[o] = orbitSums[o] + len(x & y)*circleInts[circleString]
					
	for x in carriedCircles:
		circleString = frozenset(x)
		circleBools[circleString] = model.NewBoolVar(str(x))
		circleInts[circleString] = model.NewIntVar(0,1,str(x))
		model.Add(circleInts[circleString] == 1).OnlyEnforceIf(circleBools[circleString])
		model.Add(circleInts[circleString] == 0).OnlyEnforceIf(circleBools[circleString].Not())
		
		for y in orbits:
			o = frozenset(y)
			if len(x & y) > 0:
				if o not in orbitSums:
					orbitSums[o] = circleInts[circleString]
				else:
					orbitSums[o] = orbitSums[o] + circleInts[circleString]

	for y in orbits:
		o = frozenset(y)
		if o in orbitSums:
			model.Add(orbitSums[o] <= 2)
			model.Add(orbitSums[o] != 1)
		
	# To avoid the empty solution
	model.Add(sum(circleInts.values()) > 0)
		
	solver = cp_model.CpSolver()
	solution_printer = SolutionPrinter(circleBools.values())
	status = solver.SearchForAllSolutions(model, solution_printer)

	results = solution_printer.GetResults()
	outfile = "tools/search/stitch.out"
	with open(outfile, "w") as f:
		f.write(f'N:=[{results}];\n')

if __name__ == '__main__':
	main()
