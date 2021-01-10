{ mdbook
, stdenv
}:
let
  source = import ../nix/source.nix;
in
stdenv.mkDerivation {
  name = "devshell-docs";
  buildInputs = [ mdbook ];
  src = source.filter {
    path = ./.;
    allow = [
      ./book.toml
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
