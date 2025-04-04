BUILD_DIR = build

${BUILD_DIR}/zephyr_container.pdf: *.tex img/* | ${BUILD_DIR}
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
		xelatex --halt-on-error --output-directory=./${BUILD_DIR} --jobname=zephyr_container "\
\def\zephyrversion {${ZEPHYRVERSION}} \
\def\sdkversion {${SDKVERSION}} \
\def\mcu {${MCU}} \
\def\board {${BOARD}} \
\def\imagename {${IMAGENAME}} \
\input{main.tex}"; \
	done

${BUILD_DIR}:
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}
