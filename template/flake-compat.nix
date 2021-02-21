import
  (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/99f1c2157fba4bfe6211a321fd0ee43199025dbf.tar.gz";
    sha256 = "sha256-oq8d4//CJOrVj+EcOaSXvMebvuTkmBJuT5tzlfewUnQ=";
  })
{
  src = ./.;
}
