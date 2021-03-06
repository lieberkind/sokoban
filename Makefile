all: dist index css elm js favicon

build: npx elm-make build

dist:
	mkdir -p ./dist/js
	mkdir -p ./dist/css

index:
	cp ./src/index.html ./dist/index.html

css:
	cp ./src/style.css ./dist/css/style.css

elm-package:
	npx elm-package install --yes

elm:
	npx elm-make ./src/Main.elm --output=dist/js/app.js

js:
	./node_modules/.bin/browserify src/main.js -o dist/js/bundle.js -t [ babelify --presets [ es2015 ] ]

favicon:
	cp ./favicon.ico ./dist/favicon.ico

clean:
	rm -rf ./dist
