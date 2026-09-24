# 2(q-1)-nest Construction - a pair of disjoint (q-1)-nests

## Reference
Baker, R.D. and Ebert, G.L., Nests of size (q−1) and another family of translation planes. J. London Math. Soc. 38:341–355, 1988.

Dover, J.M., Nests and nest accessories. Preprint.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for (q-1)-nest construction; q must be an odd prime power.

b
=
Type: Sequence of integers
Description: The vector representation over the prime field of an element b of GF(q) which satisfies b(b+1) is a nonzero square.


### Example
```json
{"q":5,"b":[2]}
```

## Implementation

### Function

bakerEbertTwoQMinusOneNestImplementation(q,b);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
b: sequence of integers representing a field element as above

### Output

If successful, a replaceable complex containing the circles of a (q-1)-nest and a (q-1)-nest companion.