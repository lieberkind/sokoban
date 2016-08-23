all: dist index js

dist:
	mkdir ./dist

index:
	cp ./src/index.html ./dist/index.html

js:
	mkdir -p ./dist/js
	./node_modules/.bin/browserify src/main.js -o dist/js/bundle.js -t [ babelify --presets [ es2015 ] ]

clean:
	rm -rf ./dist
