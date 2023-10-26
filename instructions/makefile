SRC=docker_zephyr_environment.tex

.PHONY: all
all: $(addprefix build/,$(subst .tex,.pdf,${SRC}))

build/%.pdf: %.tex | build
	latexmk -xelatex -halt-on-error -jobname="$(basename $@)" $<

.PHONY: format
format: | /tmp/latexindent
	latexindent -l -w -s -c /tmp/latexindent *.tex

build /tmp/latexindent:
	mkdir -p $@

.PHONY: clean
clean:
	rm -r build
