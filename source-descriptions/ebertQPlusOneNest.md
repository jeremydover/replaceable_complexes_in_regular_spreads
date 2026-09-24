# (q+1)-nest Construction

## Reference
Ebert, G.L., Spreads admitting regular elliptic covers. Europ. J. Combin. 10:319–330, 1989.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for the (q+1)-nest construction; q must be an odd prime power.

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

ebertQPlusOneNestImplementation(q,c);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
c: sequence of integers representing a field element as above

### Output

If successful, a web representing a (q+1)-nest.