.PHONY: check
check:
	llscheck

.PHONY: format
format:
	stylua -v ./lua

.PHONY: ./corpus/css4.txt
./corpus/css4.txt:
	./scripts/generate_corpus_css4.sh > ./corpus/css4.txt

.PHONY: ./corpus/u32_argb.txt
./corpus/u32_argb.txt:
	./scripts/generate_corpus_u32_argb.sh > ./corpus/u32_argb.txt

.PHONY: luarc.json
luarc.json:
	./scripts/generate_luarc_json.sh > ./.luarc.json
