.PHONY: build
build:
	mkdir -p dist
	cp src/public/* dist/
	elm make --optimize --output=dist/main.js src/elm/Main.elm
	docker run --rm --volume=${CURDIR}/src/scss:/sass ubuntudesign/sassc /sass/main.scss > dist/main.css
	sed -i '' -E 's/(main\.js|main\.css|favicon\.ico)/\1?t=$(shell date +%s)/g' dist/index.html
	@echo View in browser - file://${CURDIR}/dist/index.html
