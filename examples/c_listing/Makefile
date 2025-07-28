all: build-hairetsu build-example run

build-hairetsu:
	dub build --root=../../ --config=posix-dynamic --build=release

build-example:
	$(CC) c_listing.c -L. -l:../../out/libhairetsu.so -o c_listing
	cp ../../out/libhairetsu.so .

run:
	LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" ./c_listing

clean:
	rm *.so &>/dev/null
	rm c_listing &>/dev/null