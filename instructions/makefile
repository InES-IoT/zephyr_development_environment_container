SRC = zephyr_container.tex
BUILD_DIR = build
LATEXINDENT_DIR = /tmp/latexindent

.PHONY: all
all: $(addprefix ${BUILD_DIR}/,$(subst .tex,.pdf,${SRC}))

${BUILD_DIR}/%.pdf: %.tex img/* common.tex | ${BUILD_DIR}
ifndef ZEPHYRVERSION
	$(error ZEPHYRVERSION not set)
endif
ifndef SDKVERSION
	$(error SDKVERSION not set)
endif
ifndef MCU
	$(error MCU not set)
endif
ifndef BOARD
	$(error BOARD not set)
endif
ifndef IMAGENAME
	$(error IMAGENAME not set)
endif
	# run twice to resolve references
	for run in $(shell seq 1 2); do \
		xelatex --halt-on-error --output-directory=./${BUILD_DIR} "\
\def\zephyrversion {${ZEPHYRVERSION}} \
\def\sdkversion {${SDKVERSION}} \
\def\mcu {${MCU}} \
\def\board {${BOARD}} \
\def\imagename {${IMAGENAME}} \
\input{$<}"; \
	done

.PHONY: format
format: | ${LATEXINDENT_DIR}
	latexindent -l -w -s -m -c $| *.tex

${BUILD_DIR} ${LATEXINDENT_DIR}:
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}
