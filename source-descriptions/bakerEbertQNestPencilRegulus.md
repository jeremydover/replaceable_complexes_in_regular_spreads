# q-nest Construction with disjoint regulus from defining pencil

## Reference
q-nests
=======
Baker, R.D. and Ebert, G.L., A new class of translation planes. Ann. Discrete Math. 37:7–20, 1988.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for q-nest construction; q must be an odd prime power.

a
=
Type: Sequence of integers
Description: The vector representation over the prime field of an element of GF(q), which describes a circle of the underlying bundle (in q-nest terms) which is disjoint from the nest.

### Example
```json
{"q":5,"a":[2]}
```

## Implementation

### Function

bakerEbertQNestPencilRegulusImplementation(q,a);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
a: sequence of integers selecting a circle which corresponds to a reversible regulus

### Output

If successful, a replaceable complex containing the circles of a q-nest and a regulus from its defining pencil which is disjoint from the nest.