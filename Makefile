# Expose $VIMRUNTIME for emmylua_check
VIMRUNTIME := $(shell nvim --clean --headless --cmd 'echo $$VIMRUNTIME|q' 2>&1)
export VIMRUNTIME

.PHONY: clean
clean:
	rm -rf ./lua_modules/ ./luarocks

.PHONY: check
check:
	emmylua_check .

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
