{ config, lib, pkgs, ... }:

let

  pkgsUnstable = import <nixpkgs-unstable> { };
  mypkgs = import (builtins.fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz";
    sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
  }) {
    overlays = [
      (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
        #"https://github.com/nix-community/emacs-overlay/archive/b539c9174b79abaa2c24bd773c855b170cfa6951.tar.gz";
      }))
      (self: super: { nix-direnv = pkgsUnstable.nix-direnv; })
    ];
  };

in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "baskaran";
  home.homeDirectory = "/Users/baskaran";
  home.sessionVariables = { EDITOR = "vim"; };

  #for gccemacs
  #2021.07.20 - home-manager + emacsGcc is broken on master. See https://github.com/nix-community/emacs-overlay/issues/162
  #2021.07.21 - home-manager + nixpkgs 21.05 nix-direnv is not working for me, as it keeps trying to feed enableFlakes to an old version of nix-direnv. I'm forcing it to use unstable nix-direnv to get around this.
  #2022.02.19 all done
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      #"https://github.com/nix-community/emacs-overlay/archive/b539c9174b79abaa2c24bd773c855b170cfa6951.tar.gz";
    }))
    (self: super: { nix-direnv = pkgsUnstable.nix-direnv; })
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
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
    nix-prefetch-git

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
    #(nerdfonts.override { fonts = [ "Inconsolata" "FiraCode" ]; })

    #oh-my-zsh
    zsh-autosuggestions
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacsNativeComp;
    extraPackages = (epkgs: [ epkgs.vterm ]);
  };

  #direnv stuff:
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      # for nix flakes support
      enableFlakes = false;
    };
  };

  programs.zsh = {
    enable = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        #"zsh-autosuggestions"
        #"zsh-history-substring-search"
        #"zsh-syntax-highlighting"
      ];
      #theme = "robbyrussell";
    };
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = false;
      line_break.disabled = true;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      #package.disabled = true;
      custom.haskell = {
        symbol = "λ";
        extensions = [ "hs" ];
        style = "bold purple";
        format = "\\[[$symbol]($style)\\]";
      };
      aws.format =
        "\\[[$symbol($profile)(\\($region\\))(\\[$duration\\])]($style)\\]";
      cmake.format = "\\[[$symbol($version)]($style)\\]";
      cmd_duration.format = "\\[[⏱ $duration]($style)\\]";
      cobol.format = "\\[[$symbol($version)]($style)\\]";
      conda.format = "\\[[$symbol$environment]($style)\\]";
      crystal.format = "\\[[$symbol($version)]($style)\\]";
      dart.format = "\\[[$symbol($version)]($style)\\]";
      deno.format = "\\[[$symbol($version)]($style)\\]";
      docker_context.format = "\\[[$symbol$context]($style)\\]";
      dotnet.format = "\\[[$symbol($version)(🎯 $tfm)]($style)\\]";
      elixir.format =
        "\\[[$symbol($version \\(OTP $otp_version\\))]($style)\\]";
      elm.format = "\\[[$symbol($version)]($style)\\]";
      erlang.format = "\\[[$symbol($version)]($style)\\]";
      gcloud.format =
        "\\[[$symbol$account(@$domain)(\\($region\\))]($style)\\]";
      git_branch.format = "\\[[$symbol$branch]($style)\\]";
      git_status.format = "([\\[$all_status$ahead_behind\\]]($style))";
      golang.format = "\\[[$symbol($version)]($style)\\]";
      helm.format = "\\[[$symbol($version)]($style)\\]";
      hg_branch.format = "\\[[$symbol$branch]($style)\\]";
      java.format = "\\[[$symbol($version)]($style)\\]";
      julia.format = "\\[[$symbol($version)]($style)\\]";
      kotlin.format = "\\[[$symbol($version)]($style)\\]";
      kubernetes.format = "\\[[$symbol$context( \\($namespace\\))]($style)\\]";
      lua.format = "\\[[$symbol($version)]($style)\\]";
      memory_usage.format = "\\[$symbol[$ram( | $swap)]($style)\\]";
      nim.format = "\\[[$symbol($version)]($style)\\]";
      #nix_shell.format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
      nix_shell.format = "\\[[$symbol\\($name\\)]($style)\\]";
      nodejs.format = "\\[[$symbol($version)]($style)\\]";
      ocaml.format =
        "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]($style)\\]";
      openstack.format = "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
      package.format = "\\[[$symbol$version]($style)\\]";
      perl.format = "\\[[$symbol($version)]($style)\\]";
      php.format = "\\[[$symbol($version)]($style)\\]";
      pulumi.format = "\\[[$symbol$stack]($style)\\]";
      purescript.format = "\\[[$symbol($version)]($style)\\]";
      python.format =
        "\\[[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style)\\]";
      red.format = "\\[[$symbol($version)]($style)\\]";
      ruby.format = "\\[[$symbol($version)]($style)\\]";
      rust.format = "\\[[$symbol($version)]($style)\\]";
      scala.format = "\\[[$symbol($version)]($style)\\]";
      sudo.format = "\\[[as $symbol]\\]";
      swift.format = "\\[[$symbol($version)]($style)\\]";
      terraform.format = "\\[[$symbol$workspace]($style)\\]";
      time.format = "\\[[$time]($style)\\]";
      username.format = "\\[[$user]($style)\\]";
      vagrant.format = "\\[[$symbol($version)]($style)\\]";
      vlang.format = "\\[[$symbol($version)]($style)\\]";
      zig.format = "\\[[$symbol($version)]($style)\\]";

      # This is the "bracketed segments" preset.
    };
  };

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
