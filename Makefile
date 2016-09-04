all: dist index css js favicon

clean:
	rm -rf ./dist

css:
	mkdir -p ./dist/css
	cp ./src/style.css ./dist/css/style.css

dist:
	mkdir ./dist

favicon:
	cp ./favicon.ico ./dist/favicon.ico

index:
	cp ./src/index.html ./dist/index.html

js:
	mkdir -p ./dist/js
	./node_modules/.bin/browserify src/main.js -o dist/js/bundle.js -t [ babelify --presets [ es2015 ] ]
