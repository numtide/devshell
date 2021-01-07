{ stdenv, mdbook, source }:
stdenv.mkDerivation {
  name = "devshell-docs";
  buildInputs = [ mdbook ];
  src = source.filter {
    path = ../.;
    allow = [
      ../book.toml
      ../docs
      (source.matchExt "md")
    ];
  };

  buildPhase = ''
    mdbook build
  '';

  installPhase = ''
    mv book $out
  '';
}
