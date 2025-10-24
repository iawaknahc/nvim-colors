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

./corpus/css4.txt:
	./scripts/generate_corpus_css4.sh > ./corpus/css4.txt

./corpus/u32_argb.txt:
	./scripts/generate_corpus_u32_argb.sh > ./corpus/u32_argb.txt

luarc.json:
	./scripts/generate_luarc_json.sh > ./.luarc.json
