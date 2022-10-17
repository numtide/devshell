let
  scheme =
    if builtins.pathExists ./.git
    then "git+file"
    else "path";
in
  (builtins.getFlake "${scheme}://${toString ./.}")
  .devShell
  .${builtins.currentSystem}
