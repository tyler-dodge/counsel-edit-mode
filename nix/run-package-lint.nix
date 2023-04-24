{ emacsWithPackages }:
let
  pkgs = import <nixpkgs> {};
  versioned_emacs = emacsWithPackages (epkgs: with epkgs; [
    package-lint
  ]);
in derivation rec {
  name = "counsel-edit-mode";
  baseInputs = [];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  setup = ./package-lint.sh;
  buildInputs = [
    pkgs.wget
    versioned_emacs pkgs.coreutils];
  emacs = versioned_emacs;
  counsel_edit_mode = ../counsel-edit-mode.el;
  test_target = ../test;
  system = builtins.currentSystem;
}

  
