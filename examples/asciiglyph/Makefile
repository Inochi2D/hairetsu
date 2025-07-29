all: build-hairetsu build-example run

build-hairetsu:
	dub build --root=../../ --config=posix-dynamic --build=release

build-example:
	$(CC) -g asciiglyph.c -L. -l:../../out/libhairetsu.so -o asciiglyph
	cp ../../out/libhairetsu.so .

run:
	LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" ./asciiglyph

clean:
	rm *.so &>/dev/null
	rm asciiglyph &>/dev/null