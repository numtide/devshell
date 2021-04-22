let
  gitRev = "05aabdbca6d1972b6f14df9a47863d3de8bf61d2";
in
builtins.fetchTarball {
  url = "https://github.com/hercules-ci/hercules-ci-effects/archive/${gitRev}.tar.gz";
  sha256 = "1gbbh7j5a0sjl1rqk0kazk3hmy9khpaa2c4rbd34cjpskfanci6a";
}
