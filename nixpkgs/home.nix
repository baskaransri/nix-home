{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "baskaran";
  home.homeDirectory = "/Users/baskaran";
 
  #for gccemacs
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ]; 

  fonts.fontconfig.enable = true;

  home.packages = [
    #Print to Remarkable stuff
    pkgs.qpdf
    pkgs.ghostscript
    pkgs.rmapi

    ####Dev stuff:
    pkgs.niv
    pkgs.direnv
    pkgs.lorri

    pkgs.nixfmt

    ###DOOM packages
    ##Org packages
    pkgs.sqlite #for org-roam
    pkgs.graphviz
    #pkgs.pngpaste

    ##Python packages
    pkgs.black #for doom python autoformat
    pkgs.nodePackages.pyright #for doom python-lsp

    ##General Doom Packages
    pkgs.ripgrep 
    pkgs.fd 
    pkgs.coreutils
    pkgs.git
    pkgs.clang

    pkgs.shellcheck
    pkgs.pandoc
    
    #emacs fonts
    pkgs.fontconfig
    pkgs.emacs-all-the-icons-fonts
  ];
  
  #fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
  
  programs.emacs = {
    enable = true;
    package = pkgs.emacsGcc;
    #extraPackages = (epkgs : [ epkgs.vterm ] );
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
