artwork := $(wildcard artwork/*jpg artwork/*.png)

default: KamenRider.cdb pics


KamenRider.cdb: cards/cards.toml cards/sets.toml cards/macro.toml config.toml Makefile
	#mkdir expansions
	ygofab make
	cp expansions/* .
	#rmdir expansions

pics: $(artwork) config.toml cards/cards.toml cards/sets.toml cards/macro.toml Makefile
	ygofab compose -Pall -Eall
	rm -rf pics/field
	mv pics/Custom/* pics/
	rmdir pics/Custom

