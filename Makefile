.PHONY: build
build:
	mkdir -p dist
	cp src/public/* dist/
	elm make --optimize --output=dist/main.js src/Main.elm
	sed -i '' 's/main.js/main.js?t=$(shell date +%s)/g' dist/index.html
