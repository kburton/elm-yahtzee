.PHONY: build
build:
	mkdir -p dist
	cp src/public/* dist/
	elm make --optimize --output=dist/main.js src/Main.elm
