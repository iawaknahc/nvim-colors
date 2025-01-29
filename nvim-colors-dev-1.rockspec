rockspec_format = "3.0"
package = "nvim-colors"
version = "dev-1"
source = {
  url = "",
}
dependencies = {
  "lua ~> 5.1",
}
test_dependencies = {
  "busted ~> 2",
}
build = {
  type = "builtin",
  modules = {},
}
