ocamlc -c formulas.mli
ocamlc -c formulas.ml

ocamlc -c logic.mli
ocamlc -c logic.ml

ocamlc -c peano.mli
ocamlc -c peano.ml

ocamlc -c proof.mli
ocamlc -c proof.ml


utop formulas.cmo logic.cmo peano.cmo proof.cmo
