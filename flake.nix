{
  #home-manager build --flake './#baskaran'
  ## TODO:
  # manage ~/.ipython/profile_default/ipython_config.py
  # switch to flake
  # figure out how to mix in unstable in flake
  # install/manage tabnine
  # remove oh-my-zsh from files watched by emacs (see note under 'oh-my-zsh')
  description = "Baskaran's Home manager";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mkalias = {
      url = "github:reckenrode/mkalias";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # emacsOverlay.url = "github:nix-community/emacs-overlay";

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, homeManager, mkalias }@inputs:
    let
      system = "x86_64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      # texpkgs = (nixpkgs-unstable.texlive.combine {
      #   inherit (nixpkgs-unstable.texlive)
      #     scheme-full ieeetran caption dvisvgm
      #     dvipng # for preview and export as html
      #     wrapfig amsmath ulem hyperref capt-of;
      #   #(setq org-latex-compiler "lualatex")
      #   #(setq org-preview-latex-default-process 'dvisvgm)
      # });
    in {
      homeConfigurations.baskaran = homeManager.lib.homeManagerConfiguration {
        inherit pkgs;
        # pkgs = import nixpkgs {
        #   system = "x86_64-darwin";
        #   # overlays = [ emacsOverlay.overlay ];
        # };
        # Make inputs and system available to all modules.
        extraSpecialArgs = { inherit inputs system; };

        modules = [
          ({ pkgs, ... }: rec {
            _module.args.nixpkgs-unstable =
              import nixpkgs-unstable { system = "x86_64-darwin"; };
          })
          ./darwin.nix
          {
            home = {
              username = "baskaran";
              homeDirectory = "/Users/baskaran";
              stateVersion = "21.11";
              sessionVariables.EDITOR = "vim";

              packages = with pkgs; [
                ##General config
                #Terminal Manager
                kitty
                tmux

                # #Print to Remarkable stuff
                qpdf
                #ghostscript # clashes with texlive, move texlive to local direnv
                #rmapi

                # ####Dev stuff:
                niv
                direnv
                lorri

                nixfmt
                nix-prefetch-git

                ###DOOM packages
                ##Org packages
                sqlite # for org-roam
                graphviz
                taskjuggler # for gannt charts
                #pngpaste

                ##Python packages
                black # for doom python autoformat
                nodePackages.pyright # for doom python-lsp
                # Python Emacs Debugger packages
                nodejs
                python310Packages.debugpy

                ##Latex packages
                #LSP: - should be in a local flake managing dev env, not here
                texlab
                # texpkgs

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
                # emacs-all-the-icons-fonts causes the flake to try and create my home directory.
                # emacs-all-the-icons-fonts
                # #(nerdfonts.override { fonts = [ "Inconsolata" "FiraCode" ]; })

                # zsh-autosuggestions
              ];
            };
            programs = {
              home-manager.enable = true;
              emacs = {
                enable = true;
                package = pkgs.emacs28NativeComp;
                extraPackages = (epkgs: [ epkgs.vterm ]);
              };
              direnv = {
                enable = true;
                nix-direnv.enable = true;
              };

              zsh = {
                enable = true;
                enableSyntaxHighlighting = true;
                shellAliases = {
                  home-manager-flake =
                    "home-manager --flake '/Users/baskaran/.config/#baskaran'";
                };
                initExtra =
                  "export PATH=$PATH:/opt/intel/oneapi/compiler/latest/mac/bin/intel64/";
                oh-my-zsh = {
                  # opens up too many file descriptors in emacs, figure out how to
                  # make sure that doesn't happen.
                  # you can check file descriptors by opening activity monitor, double clicking emacs and
                  # looking at open files.
                  # 2022-09-01: files are in /nix/store/4y1wgj9rd9fcv5hpdpdqz9asr3avgkjq-oh-my-zsh-2021-12-18/share/oh-my-zsh/plugins
                  # on futher look this is only when I direnv in ~/programming/python/pytorch-geometric/cora/simplecs.py
                  # removing likely packages doesn't do anything
                  # have just deleted all the plugins from there.
                  enable = false;
                  plugins = [
                    "git"
                    # "zsh-autosuggestions"
                    #"zsh-history-substring-search"
                    #"zsh-syntax-highlighting"
                  ];
                  #theme = "robbyrussell";
                };
              };

              starship = {
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
                } // pkgs.lib.mapAttrs
                  (_: value: { format = value + "($style)\\]"; }) {
                    aws =
                      "\\[[$symbol($profile)(\\($region\\))(\\[$duration\\])]";
                    cmake = "\\[[$symbol($version)]";
                    cmd_duration = "\\[[⏱ $duration]";
                    cobol = "\\[[$symbol($version)]";
                    conda = "\\[[$symbol$environment]";
                    crystal = "\\[[$symbol($version)]";
                    dart = "\\[[$symbol($version)]";
                    deno = "\\[[$symbol($version)]";
                    docker_context = "\\[[$symbol$context]";
                    dotnet = "\\[[$symbol($version)(🎯 $tfm)]";
                    elixir = "\\[[$symbol($version \\(OTP $otp_version\\))]";
                    elm = "\\[[$symbol($version)]";
                    erlang = "\\[[$symbol($version)]";
                    gcloud = "\\[[$symbol$account(@$domain)(\\($region\\))]";
                    git_branch = "\\[[$symbol$branch]";
                    golang = "\\[[$symbol($version)]";
                    helm = "\\[[$symbol($version)]";
                    hg_branch = "\\[[$symbol$branch]";
                    java = "\\[[$symbol($version)]";
                    julia = "\\[[$symbol($version)]";
                    kotlin = "\\[[$symbol($version)]";
                    kubernetes = "\\[[$symbol$context( \\($namespace\\))]";
                    lua = "\\[[$symbol($version)]";
                    memory_usage = "\\[$symbol[$ram( | $swap)]";
                    nim = "\\[[$symbol($version)]";
                    #nix_shell.format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
                    nix_shell = "\\[[$symbol\\($name\\)]";
                    nodejs = "\\[[$symbol($version)]";
                    ocaml =
                      "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]";
                    openstack = "\\[[$symbol$cloud(\\($project\\))]";
                    package = "\\[[$symbol$version]";
                    perl = "\\[[$symbol($version)]";
                    php = "\\[[$symbol($version)]";
                    pulumi = "\\[[$symbol$stack]";
                    purescript = "\\[[$symbol($version)]";
                    python =
                      "\\[[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]";
                    red = "\\[[$symbol($version)]";
                    ruby = "\\[[$symbol($version)]";
                    rust = "\\[[$symbol($version)]";
                    scala = "\\[[$symbol($version)]";
                    swift = "\\[[$symbol($version)]";
                    terraform = "\\[[$symbol$workspace]";
                    time = "\\[[$time]";
                    username = "\\[[$user]";
                    vagrant = "\\[[$symbol($version)]";
                    vlang = "\\[[$symbol($version)]";
                    zig = "\\[[$symbol($version)]";

                    # This is the "bracketed segments" preset.
                  } // {
                    git_status.format =
                      "([\\[$all_status$ahead_behind\\]]($style))";
                    sudo.format = "\\[[as $symbol]\\]";
                  };
              };

            };
            # 2023.01.02: build error in home-manager, removing manpages fixes this
            # See: https://github.com/nix-community/home-manager/issues/3342
            manual = {
              manpages.enable = false;
              html.enable = false;
              json.enable = false;
            };
            fonts.fontconfig.enable = true;
          }
        ];

      };
    };
}
