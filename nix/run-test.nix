{ emacsWithPackages }:
let
  pkgs = import <nixpkgs> {};
  versioned_emacs = emacsWithPackages (epkgs: with epkgs; [
  counsel
  dash
  ht
  s
  ert-runner
  el-mock
  ]);
in derivation rec {
  name = "counsel-edit-mode";
  baseInputs = [];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./builder.sh ];
  setup = ./setup.sh;
  buildInputs = with pkgs; [
    gnugrep
    versioned_emacs coreutils];
  emacs = versioned_emacs;
  counsel_edit_mode = ../counsel-edit-mode.el;
  test_target = ../test;
  system = builtins.currentSystem;
}

  
