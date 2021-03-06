.PHONY: build
build:
	mkdir -p dist
	cp src/public/* dist/
	elm make --optimize --output=dist/temp.js src/elm/Main.elm
	docker run --rm -i smithmicro/uglifyjs --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' < dist/temp.js \
		| docker run --rm -i smithmicro/uglifyjs --mangle > dist/main.js
	rm dist/temp.js
	docker run --rm --volume=${CURDIR}/src/scss:/sass ubuntudesign/sassc /sass/main.scss > dist/main.css
	sed -i '' -E 's/(main\.js|main\.css|favicon\.ico)/\1?t=$(shell date +%s)/g' dist/index.html

.PHONY: debug
debug:
	mkdir -p debug
	cp src/public/* debug/
	elm make --debug --output=debug/main.js src/elm/Main.elm
	docker run --rm --volume=${CURDIR}/src/scss:/sass ubuntudesign/sassc /sass/main.scss > debug/main.css
	sed -i '' -E 's/(main\.js|main\.css|favicon\.ico)/\1?t=$(shell date +%s)/g' debug/index.html

.PHONY: run
run:
	docker run -it --rm -p 8080:8080 -v $(PWD)/dist:/public/dist -v $(PWD)/debug:/public/debug danjellz/http-server
