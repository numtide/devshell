{ buildEnv, nixUnstable, git }:
buildEnv {
name = "flake-env";
  paths = [
    git
    nixUnstable
  ];
}
