# Generate all id files referring to the following files
# - all.id
# - full/train.id
# - full/dev.id
# - full/test.id

SHELL := bash

.PHONY: all
all: full/all.id syntax-only/all.id train.id test.id

full/all.id: full/train.id full/dev.id full/test.id
	cat $^ | sort | uniq > $@

syntax-only/all.id: all.id full/all.id
	comm -23 <(cat all.id | sort) <(cat full/all.id | sort) > $@

train.id: full/train.id full/dev.id syntax-only/all.id
	cat $^ | sort | uniq > $@

test.id: full/test.id
	cat $^ | sort | uniq > $@
