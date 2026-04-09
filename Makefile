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

./luarocks:
	rm -rf ./lua_modules/
	luarocks --local init
	git checkout -- .gitignore
