{
  description = "A development environment for Bitcoin Core";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/5ebe08339915f21fa964ff7d56e6fc2736e75a4e";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # myOverlay = self: super: {
        #   stdenv = super.addAttrsToDerivation { NIX_CFLAGS_COMPILE = "-Wno-unused-but-set-variable"; } super.stdenv;
        # };
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          # overlays = [
          #   myOverlay
          # ];
        };
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs;}) mkPoetryEnv defaultPoetryOverrides;
        pythonEnv = mkPoetryEnv {
          projectDir = ./.;
          python = pkgs.python39;
          overrides = defaultPoetryOverrides.extend
            (final: prev: {
              protobuf3 = prev.protobuf3.overridePythonAttrs
                (
                  old: {
                    buildInputs = (old.buildInputs or [ ]) ++ [ prev.setuptools ];
                  }
                );
              pytest-custom-exit-code = prev.pytest-custom-exit-code.overridePythonAttrs
                (
                  old: {
                    buildInputs = (old.buildInputs or [ ]) ++ [ prev.setuptools ];
                  }
                );
              pytest-test-groups = prev.pytest-test-groups.overridePythonAttrs
                (
                  old: {
                    buildInputs = (old.buildInputs or [ ]) ++ [ prev.setuptools ];
                  }
                );
            });
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            sqlite
            autoconf
            # clang
            libtool
            autogen
            automake
            gmp
            zlib
            gettext
            libsodium
            pythonEnv
          ];
          shellHook = ''
              export CFLAGS=$NIX_CFLAGS_COMPILE
              export LDFLAGS=$NIX_LDFLAGS
          '';
        };
      }
    );
}
