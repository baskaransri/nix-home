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
                } // pkgs.lib.mapAttrs (_: value: { format = value; }) {
                  aws =
                    "\\[[$symbol($profile)(\\($region\\))(\\[$duration\\])]($style)\\]";
                  cmake = "\\[[$symbol($version)]($style)\\]";
                  cmd_duration = "\\[[⏱ $duration]($style)\\]";
                  cobol = "\\[[$symbol($version)]($style)\\]";
                  conda = "\\[[$symbol$environment]($style)\\]";
                  crystal = "\\[[$symbol($version)]($style)\\]";
                  dart = "\\[[$symbol($version)]($style)\\]";
                  deno = "\\[[$symbol($version)]($style)\\]";
                  docker_context = "\\[[$symbol$context]($style)\\]";
                  dotnet = "\\[[$symbol($version)(🎯 $tfm)]($style)\\]";
                  elixir =
                    "\\[[$symbol($version \\(OTP $otp_version\\))]($style)\\]";
                  elm = "\\[[$symbol($version)]($style)\\]";
                  erlang = "\\[[$symbol($version)]($style)\\]";
                  gcloud =
                    "\\[[$symbol$account(@$domain)(\\($region\\))]($style)\\]";
                  git_branch = "\\[[$symbol$branch]($style)\\]";
                  git_status = "([\\[$all_status$ahead_behind\\]]($style))";
                  golang = "\\[[$symbol($version)]($style)\\]";
                  helm = "\\[[$symbol($version)]($style)\\]";
                  hg_branch = "\\[[$symbol$branch]($style)\\]";
                  java = "\\[[$symbol($version)]($style)\\]";
                  julia = "\\[[$symbol($version)]($style)\\]";
                  kotlin = "\\[[$symbol($version)]($style)\\]";
                  kubernetes =
                    "\\[[$symbol$context( \\($namespace\\))]($style)\\]";
                  lua = "\\[[$symbol($version)]($style)\\]";
                  memory_usage = "\\[$symbol[$ram( | $swap)]($style)\\]";
                  nim = "\\[[$symbol($version)]($style)\\]";
                  #nix_shell.format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
                  nix_shell = "\\[[$symbol\\($name\\)]($style)\\]";
                  nodejs = "\\[[$symbol($version)]($style)\\]";
                  ocaml =
                    "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]($style)\\]";
                  openstack = "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
                  package = "\\[[$symbol$version]($style)\\]";
                  perl = "\\[[$symbol($version)]($style)\\]";
                  php = "\\[[$symbol($version)]($style)\\]";
                  pulumi = "\\[[$symbol$stack]($style)\\]";
                  purescript = "\\[[$symbol($version)]($style)\\]";
                  python =
                    "\\[[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style)\\]";
                  red = "\\[[$symbol($version)]($style)\\]";
                  ruby = "\\[[$symbol($version)]($style)\\]";
                  rust = "\\[[$symbol($version)]($style)\\]";
                  scala = "\\[[$symbol($version)]($style)\\]";
                  sudo = "\\[[as $symbol]\\]";
                  swift = "\\[[$symbol($version)]($style)\\]";
                  terraform = "\\[[$symbol$workspace]($style)\\]";
                  time = "\\[[$time]($style)\\]";
                  username = "\\[[$user]($style)\\]";
                  vagrant = "\\[[$symbol($version)]($style)\\]";
                  vlang = "\\[[$symbol($version)]($style)\\]";
                  zig = "\\[[$symbol($version)]($style)\\]";

                  # This is the "bracketed segments" preset.
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
