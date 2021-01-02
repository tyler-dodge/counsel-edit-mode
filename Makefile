EMACS ?= emacs
CASK ?= cask

all: test
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

deps:
	${CASK} install

test: clean-elc
	${MAKE} compile
	${MAKE} unit
	${MAKE} clean-elc

unit:
	${CASK} exec ert-runner

compile: deps
	${CASK} exec ${EMACS} -Q -batch -L . -f batch-byte-compile counsel-edit-mode.el

clean-elc:
	rm -f counsel-edit-mode.elc

.PHONY:	all test docs unit
