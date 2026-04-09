rockspec_format = "3.0"
package = "nvim-colors"
version = "dev-1"
-- source.url is required by luarocks.
-- So make it happy by supplying an empty string.
source = {
  url = "",
}
test_dependencies = {
  "busted ~> 2",
}
build = {
  type = "builtin",
}
