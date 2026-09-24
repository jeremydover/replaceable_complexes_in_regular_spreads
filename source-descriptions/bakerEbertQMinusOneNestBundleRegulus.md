# (q-1)-nest Construction with disjoint regulus from the bundle

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

mu
==
Type: Sequence of integers
Description: The vector representation over the prime field of an element of GF(q^2). This field element defines a circle from the bundle of q+1 circles that contains both 0 and infinity. In order for this construction to work, this circle must be disjoint from the circle:
[1  1]
[b -1]
which defines the base circle of the nest; this condition is checked as part of the construction.

### Example
```json
{"q":5,"b":[2],"mu":[3,1]}
```

## Implementation

### Function

bakerEbertQMinusOneNestBundleRegulusImplementation(q,b,mu);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
b: sequence of integers representing a field element as above
mu: sequence of integers representing a field element as above

### Output

If successful, a replaceable complex containing the circles of a (q-1)-nest together with the disjoint bundle circle chosen.