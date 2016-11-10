.PHONY: all clean

all:
	ocaml pkg/pkg.ml build

test: all
	ocaml pkg/pkg.ml test

clean:
	ocaml pkg/pkg.ml clean
