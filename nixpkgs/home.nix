{ config, lib, pkgs, ... }:

let

  pkgsUnstable = import <nixpkgs-unstable> {};
  mypkgs = import (
  builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz";
    sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
  }
){overlays =  [
    (import (builtins.fetchTarball {
      url =
        #"https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
	"https://github.com/nix-community/emacs-overlay/archive/b539c9174b79abaa2c24bd773c855b170cfa6951.tar.gz";
    }))
    (self: super: {nix-direnv = pkgsUnstable.nix-direnv;})
  ];};

in

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "baskaran";
  home.homeDirectory = "/Users/baskaran";

  #for gccemacs
  #2021.07.20 - home-manager + emacsGcc is broken on master. See https://github.com/nix-community/emacs-overlay/issues/162
  #2021.07.21 - home-manager + nixpkgs 21.05 nix-direnv is not working for me, as it keeps trying to feed enableFlakes to an old version of nix-direnv. I'm forcing it to use unstable nix-direnv to get around this.
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url =
        #"https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
	"https://github.com/nix-community/emacs-overlay/archive/b539c9174b79abaa2c24bd773c855b170cfa6951.tar.gz";
    }))
    (self: super: {nix-direnv = pkgsUnstable.nix-direnv;})
  ];

  fonts.fontconfig.enable = true;

  home.packages = with mypkgs; [
    ##General config
    #Terminal Manager
    kitty
    tmux

    #Print to Remarkable stuff
    qpdf
    ghostscript
    rmapi

    ####Dev stuff:
    niv
    direnv
    lorri

    nixfmt

    ###DOOM packages
    ##Org packages
    sqlite # for org-roam
    graphviz
    #pngpaste

    ##Python packages
    black # for doom python autoformat
    nodePackages.pyright # for doom python-lsp
    ###Python Emacs Debugger packages
    nodejs
    python39Packages.debugpy


    ##Julia packages

    ##General Doom Packages
    ripgrep
    fd
    coreutils
    git
    clang

    shellcheck
    pandoc

    #emacs fonts
    fontconfig
    emacs-all-the-icons-fonts
  ];

  programs.emacs = {
    enable = true;
    package = mypkgs.emacsGcc;
    extraPackages = (epkgs: [ epkgs.vterm ]);
  };

  #direnv stuff:
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # for nix flakes support
  programs.direnv.nix-direnv.enableFlakes = false;
  programs.zsh.enable = true;

  # add installs to spotlight search
  # copied from https://github.com/nix-community/home-manager/issues/1341
  home.activation = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
    copyApplications = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      baseDir="$HOME/Applications/Home Manager Apps"
      if [ -d "$baseDir" ]; then
        rm -rf "$baseDir"
      fi
      mkdir -p "$baseDir"
      for appFile in ${apps}/Applications/*; do
        target="$baseDir/$(basename "$appFile")"
        $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
        $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
      done
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
