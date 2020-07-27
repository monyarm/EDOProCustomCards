artwork := $(wildcard artwork/*.jpg artwork/*.png)
toml := $(wildcard cards/*.toml)

default: KamenRider.cdb pics


KamenRider.cdb:config.toml $(toml) Makefile
	#mkdir expansions
	ygofab make
	cp expansions/* .
	#rmdir expansions

pics: $(artwork) config.toml $(toml) Makefile
	ygofab compose -Pall -Eall
	rm -rf pics/field
	mv pics/Custom/* pics/
	rmdir pics/Custom

