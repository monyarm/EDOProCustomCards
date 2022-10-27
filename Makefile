artwork := $(wildcard artwork/*.jpg artwork/*.png)
toml := $(wildcard cards/*.toml)

default: Custom.cdb pics


Custom.cdb: config.toml $(toml) Makefile
	#mkdir expansions
	ygofab make
	cp expansions/* .
	#rmdir expansions

pics: $(artwork) config.toml $(toml) Makefile
	ygofab compose -p proxy -Eall
	cp -r pics/proxy/* pics/

