{ mdbook
, modules-docs
, stdenv
, lib
}:
with lib;
stdenv.mkDerivation {
  name = "devshell-docs";
  buildInputs = [ mdbook ];
  src =
    let fs = lib.fileset; in
    fs.toSource {
      root = ./.;
      fileset = fs.unions [
        (fs.fileFilter (file: file.hasExt "md") ./src)
        (fs.fileFilter (file: true) ./theme)
        ./book.toml
      ];
    };

  buildPhase = ''
    cp ${modules-docs.markdown} src/modules_schema.md
    mdbook build
  '';

  installPhase = ''
    mv book $out
  '';
}
