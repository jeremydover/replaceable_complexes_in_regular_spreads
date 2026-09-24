# Mixed Nest Construction

## Reference
Baker, R.D. and Ebert, G.L., Filling the nest gaps. Finite Fields Appl. 2:42–61, 1996.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for the mixed nest construction; q must be an odd prime power.

c
=
Type: Sequence of integers
Description: The vector representation over the prime field of an element of GF(q) such that c+1 is a non-square in GF(q).

### Example
```json
{"q":5,"c":[1]}
```

## Implementation

### Function

bakerEbertMixedNestImplementation(q,c);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
c: sequence of integers representing a field element as above

### Output

If successful, a web representing a mixed nest.