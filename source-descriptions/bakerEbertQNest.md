# q-nest Construction

## Reference
q-nests
=======
Baker, R.D. and Ebert, G.L., A new class of translation planes. Ann. Discrete Math. 37:7–20, 1988.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for q-nest construction; q must be an odd prime power.

### Example
```json
{"q":5}
```

## Implementation

### Function

bakerEbertQNestImplementation(q);

### Input

q: integer that is a power of an odd prime, possibly itself a prime

### Output

If successful, a web containing the circles of a q-nest