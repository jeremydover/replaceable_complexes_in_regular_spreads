# Bundle-Stitched Nest Constructions

## Reference
Dover, J.M., Nests and nest accessories. Preprint.

## Instance Data
q
=
Type: Integer
Description: Order of ground field for the bundle-stitched nest construction; q must be an odd prime power.

orbit_circles
=============
Type: Sequence of integers
Description: The vector representations of circles <lambda,s> whose orbits under the index 2 subgroup of the group cyclically permuting the points in the bundle circles form part of the nest. Each of lambda and s is in GF(q^2), and thus is represented by a sequence of length 2e, where q=p^e, of elements of GF(p). All elements are concatenated into a single sequence.

bundle_circles
=============
Type: Sequence of integers
Description: The vector representations of circles {\infty} \cup {fk:f in GF(q)} in the bundle which are contained in the nest, for non-zero k in GF(q^2). Representation of such elements k is given as above.

### Example
```json
{"q":5,"orbit_circles":[3,3,3,4,3,1,0,1],"bundle_circles":[3,1,2,2]}
```

## Implementation

### Function

bundleStitchedNestImplementation(q,orbit_circles,bundle_circles);

### Input

q: integer that is a power of an odd prime, possibly itself a prime
orbit_circles: sequence of integers representing circles as above
bundle_circles: sequence of integers representing circles as above

### Output

If successful, a web representing a bundle-stitched nest, which consists of the union of orbits under the index 2 subgroup of the group which cyclically permutes the non-carrier points of each circle in a bundle.