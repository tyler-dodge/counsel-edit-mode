let
  pkgs = import (builtins.fetchGit {
    name = "emacs-revision-27.1";
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "a765beccb52f30a30fee313fbae483693ffe200d";
  }) {};
  emacsWithPackages = import ./emacs-packages.nix {
    emacsWithPackages = with pkgs; (emacsPackagesNgGen emacs).emacsWithPackages;
  };
in pkgs.mkShell {
  packages = [
    emacsWithPackages];
  emacs = emacsWithPackages;
}
