# Prince's (q+3)-Nest Construction

## Reference
Prince, A.R., The construction of replaceable (q+3)-nests of reguli in PG(3,q). Finite Fields Appl. 18:437-444, 2012.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for the nest construction; q must be an odd prime power.

a
=
Type: Sequence of integers
Description: The vector representation over the prime field of an element of GF(q^2) such that a is a square with a^(q+1) neither 0 nor 1.

### Example
```json
{"q":5,"a":[2,0]}
```

## Implementation

### Function

princeQPlusThreeNestImplementation(q,a);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
a: sequence of integers representing a field element as above

### Output

If successful, a web representing a Prince (q+3)-nest.