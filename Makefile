all: dist index js favicon

dist:
	mkdir ./dist

index:
	cp ./src/index.html ./dist/index.html

js:
	mkdir -p ./dist/js
	./node_modules/.bin/browserify src/main.js -o dist/js/bundle.js -t [ babelify --presets [ es2015 ] ]

favicon:
	cp ./favicon.ico ./dist/favicon.ico

clean:
	rm -rf ./dist
