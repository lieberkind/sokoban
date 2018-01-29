all: dist index elm js favicon

dist:
	mkdir -p ./dist/js
	mkdir -p ./dist/css

index:
	cp ./src/index.html ./dist/index.html

elm:
	elm-make ./src/Buttons.elm --output=dist/js/buttons.js

js:
	./node_modules/.bin/browserify src/main.js -o dist/js/bundle.js -t [ babelify --presets [ es2015 ] ]

favicon:
	cp ./favicon.ico ./dist/favicon.ico

clean:
	rm -rf ./dist
