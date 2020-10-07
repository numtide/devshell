# A standalone source filtering library
let
  inherit (builtins)
    any
    isFunction
    isString
    isPath
    map
    stringLength
    substring
    ;

  # Copied from the nixpkgs stdlib
  hasSuffix =
    # Suffix to check for
    suffix:
    # Input string
    content:
    let
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix &&
    substring (lenContent - lenSuffix) lenContent content == suffix;

  # If an argument to allow or deny is a path, transform it to a matcher.
  #
  # This probably needs more work, I don't think that it works on sub-folders.
  toMatcher = f:
    let
      path_ = toString f;
    in
    if isFunction f then f
    else
      (path: type: path_ == toString path);
in
{
  # Match paths with the given extension
  matchExt = ext:
    path: type:
      (hasSuffix ".${ext}" path);

  # A proper filter
  filter = { path, name ? "source", allow ? [ ], deny ? [ ] }:
    let
      allow_ = builtins.map toMatcher allow;
      deny_ = builtins.map toMatcher deny;
    in
    builtins.path {
      inherit name path;
      filter = path: type:
        (builtins.any (f: f path type) allow_) &&
        (!builtins.any (f: f path type) deny_);
    };
}
