# Proof assistant

Command-line proof assistant written in `OCaml`, which helps in proving theorems in first-order logic
(with Peano axioms).

## Prerequisites

You must install `OCaml`, `opam`, `utop`.

To run tests you'll need OCaml module `ounit2`.

## How to run

Compile relevant files and run `utop`. 
Or you can simply run `make.sh` script provided in this repo. 

## How to test

In `utop` run 
```
#use "tests.ml"
```

## How to prove

In `utop` run
```
#use "test_proof_addition.ml"
```
or write your custom proofs. 



