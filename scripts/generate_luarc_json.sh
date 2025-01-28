#!/bin/sh

REPLACEMENT=$(nvim -u NONE -Es  +'lua vim.api.nvim_put({ vim.env.VIMRUNTIME }, "l", true, true)' +'g/^$/d' +'%print')

sed -E "s,VIMRUNTIME,$REPLACEMENT," ./luarc.json.sample ./.luarc.json
