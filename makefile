
.PHONY: all run

all: run

debug:
	love src debug

debugtime:
	love src debugtime

run:
	love src
