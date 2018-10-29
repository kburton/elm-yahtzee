.PHONY: build
build:
	mkdir -p dist
	cp src/public/* dist/
	elm make src/Main.elm --output=dist/main.js
