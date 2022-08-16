{
  #home-manager build --flake './#baskaran'
  ## TODO:
  # manage ~/.ipython/profile_default/ipython_config.py
  # switch to flake
  # figure out how to mix in unstable in flake
  # install/manage tabnine
  description = "Baskaran's Home manager";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # emacsOverlay.url = "github:nix-community/emacs-overlay";

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, homeManager }: {
    homeConfigurations = {
      "baskaran" = homeManager.lib.homeManagerConfiguration {
        configuration = { lib, config, pkgs, ... }: {
          programs.home-manager.enable = true;
          home.sessionVariables.EDITOR = "vim";
          home.packages = with pkgs; [
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
            #pngpaste

            ##Python packages
            black # for doom python autoformat
            nodePackages.pyright # for doom python-lsp
            # Python Emacs Debugger packages
            nodejs
            python39Packages.debugpy

            ##Latex packages
            #LSP: - should be in a local flake managing dev env, not here
            texlab
            texlive.combined.scheme-medium

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
          fonts.fontconfig.enable = true;
          programs.emacs = {
            enable = true;
            package = pkgs.emacs28NativeComp;
            extraPackages = (epkgs: [ epkgs.vterm ]);
          };

          #direnv stuff:
          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          programs.zsh = {
            enable = true;
            enableSyntaxHighlighting = true;
            shellAliases = {
              home-manager-flake =
                "home-manager --flake '/Users/baskaran/.config/#baskaran'";
            };
            oh-my-zsh = {
              enable = true;
              plugins = [
                "git"
                # "zsh-autosuggestions"
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
              kubernetes.format =
                "\\[[$symbol$context( \\($namespace\\))]($style)\\]";
              lua.format = "\\[[$symbol($version)]($style)\\]";
              memory_usage.format = "\\[$symbol[$ram( | $swap)]($style)\\]";
              nim.format = "\\[[$symbol($version)]($style)\\]";
              #nix_shell.format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
              nix_shell.format = "\\[[$symbol\\($name\\)]($style)\\]";
              nodejs.format = "\\[[$symbol($version)]($style)\\]";
              ocaml.format =
                "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]($style)\\]";
              openstack.format =
                "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
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

          # # add installs to spotlight search
          # # copied from https://github.com/nix-community/home-manager/issues/1341
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
          home.stateVersion = "21.11";
        };

        pkgs = import nixpkgs {
          system = "x86_64-darwin";
          # overlays = [ emacsOverlay.overlay ];
        };
        system = "x86_64-darwin";
        homeDirectory = "/Users/baskaran";
        username = "baskaran";
        stateVersion = "21.11";
      };
    };
  };
}
