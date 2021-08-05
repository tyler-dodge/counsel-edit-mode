let
  pkgs = import (builtins.fetchGit {
    name = "emacs-revision-26.2";
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "4599f2bb9a5a6b1482e72521ead95cb24e0aa819";   
  }) {};
  emacsWithPackages = import ./emacs-packages.nix {
    emacsWithPackages = with pkgs; (emacsPackagesNgGen emacs26).emacsWithPackages;
  };
in pkgs.mkShell {
  packages = [
    emacsWithPackages];
  emacs = emacsWithPackages;
}
