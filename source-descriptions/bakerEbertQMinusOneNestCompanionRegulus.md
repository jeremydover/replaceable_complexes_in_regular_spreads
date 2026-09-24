# (q-1)-nest Construction with disjoint regulus from companion nest

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
Description: The vector representation over the prime field of an element b of GF(q) satisfying b(b+1) is a nonzero square.

### Example
```json
{"q":5,"b":[2]}
```

## Implementation

### Function

bakerEbertQMinusOneNestCompanionRegulusImplementation(q,b);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
b: sequence of integers representing a field element as above

### Output

If successful, a replaceable complex containing a (q-1)-nest and a regulus from its companion nest which is disjoint from it. By construction, the complexes obtained from taking different reguli in the companion nest are isomorphic.