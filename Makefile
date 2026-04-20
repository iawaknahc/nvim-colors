# Expose $VIMRUNTIME for emmylua_check
VIMRUNTIME := $(shell nvim --clean --headless --cmd 'echo $$VIMRUNTIME|q' 2>&1)
export VIMRUNTIME

.PHONY: clean
clean:
	rm -rf ./lua_modules/ ./luarocks

.PHONY: check
check:
	emmylua_check .

# stylua is smart enough to look at .gitignore and ignore the directories there.
.PHONY: format
format:
	stylua -v .

.PHONY: test
test: ./luarocks
	./luarocks test

.PHONY: tree-sitter-clean
tree-sitter-clean:
	rm -rf ./src/node-types.json ./src/parser.c ./src/tree_sitter/ ./parser.so

.PHONY: tree-sitter-generate
tree-sitter-generate: tree-sitter-clean
	tree-sitter generate --abi 15

.PHONY: tree-sitter-test
tree-sitter-test: tree-sitter-generate
	tree-sitter test

# This make target is not actually used.
# The actual parser is built in ./plugin/nvim-colors.lua automatically.
.PHONY: tree-sitter-build
tree-sitter-build: tree-sitter-generate
	tree-sitter build -o parser.so

./luarocks:
	rm -rf ./lua_modules/
	luarocks --local init
	git checkout -- .gitignore
