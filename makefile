
.PHONY: all run

all: run

debug:
	love src debug

debugtime:
	love src debugtime

debugcenter:
	love src debugcenter

run:
	love src
