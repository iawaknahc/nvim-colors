.PHONY: clean
clean:
	rm -rf ./lua_modules/ ./luarocks ./luarc.json

.PHONY: check
check:
	llscheck

.PHONY: format
format:
	stylua -v ./lua

.PHONY: test
test: ./luarocks
	./luarocks test

./luarocks:
	rm -rf ./lua_modules/
	luarocks --local init
	git checkout -- .gitignore

luarc.json:
	./scripts/generate_luarc_json.sh > ./.luarc.json
