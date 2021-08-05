let
  pkgs = import (builtins.fetchGit {
    name = "emacs-revision-27.2";
    url = "https://github.com/NixOS/nixpkgs/";                       
    ref = "refs/heads/nixpkgs-unstable";                     
    rev = "860b56be91fb874d48e23a950815969a7b832fbc";           
  }) {};
  emacsWithPackages = import ./emacs-packages.nix {
    emacsWithPackages = with pkgs; (emacsPackagesNgGen emacs).emacsWithPackages;
  };
in pkgs.mkShell {
  packages = [
    emacsWithPackages];
  emacs = emacsWithPackages;
}
