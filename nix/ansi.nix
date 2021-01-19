# Ansi escape codes
rec {
  # Nix strings only support \t, \r and \n as escape codes, so actually store
  # the literal escape "ESC" code.
  esc = "";

  orange = "${esc}[38;5;202m";
  reset = "${esc}[0m";
  bold = "${esc}[1m";
}
