# Bundle Mixed Nest Construction

## Reference
Dover, J.M., Nests and nest accessories. Preprint.

Baker, R.D. and Ebert, G.L., Filling the nest gaps. Finite Fields Appl. 2:42–61, 1996.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for nest construction; q must be an odd prime power.

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

bundleMixedNestImplementation(q,b);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
b: sequence of integers representing a field element as above

### Output

If successful, a web containing the circles of a mixed nest obtained from a circle bundle.

### Notes
This construction likely only works for q less than 17; however, we do not have a validated proof of this fact. The construction function will fail gracefully if the construction does not work, returning 0.