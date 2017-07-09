build: clean
	coffee --compile --output lib src

run: test

watch: clean
	coffee --compile --watch --output lib src

clean:
	/bin/rm -rf lib

deploy:
	git push -f origin HEAD:gh-pages

test:
	mocha
.PHONY: test
