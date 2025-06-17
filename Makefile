LIGHT	=ramine-light-amd64.hybrid.iso
STD	=ramine-amd64.hybrid.iso


.PHONY: all
all: $(LIGHT) $(STD)


$(LIGHT): light/
	cd light && make clean && make
	mv ./light/$(LIGHT) .

$(STD): standard/
	cd standard && make clean && make
	mv ./standard/$(STD) .
