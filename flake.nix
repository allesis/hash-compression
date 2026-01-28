{
  description = "Flake for installing dependencies needed to use wrapper script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    luasmith = {
      url = "github:allesis/luasmith-flake";
    };
    vqmetric-nix = {
      url = "github:allesis/vqmetric-nix?rev=18f95c4254eefc738c65d1c2e823151da462cd26";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    luasmith,
    vqmetric-nix,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin"];
    l = nixpkgs.lib // builtins;
    forEachSupportedSystem = f:
      l.genAttrs supportedSystems
      (system:
        f system (import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default self.overlays.default];
        }));
  in {
    overlays.default = final: prev: {
      rustToolchain = let
        rust = prev.rust-bin;
      in
        if builtins.pathExists ./rust-toolchain.toml
        then rust.fromRustupToolchainFile ./rust-toolchain.toml
        else if builtins.pathExists ./rust-toolchain
        then rust.fromRustupToolchainFile ./rust-toolchain
        else
          rust.nightly.latest.default.override {
            extensions = ["rust-src" "rustfmt"];
          };
    };
    devShells = forEachSupportedSystem (system: pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          rust-bin.stable.latest.default
          rust-analyzer
          nasm
          libGL
          libz
          glibc
          glib
          libvmaf
          ffmpeg-full
          opencv
          cargo
          rustc
          pkg-configUpstream
        ];

        nativeBuildInputs = with pkgs; [
          pkg-configUpstream
          python313
          python313Packages.scikit-misc
          python313Packages.ffmpy
          libGL
          libz
          glibc
          glib
          libvmaf
          ffmpeg-full
          opencv
          cargo
          rustc
          jq
          bc
          vqmetric-nix.packages.${system}.default
        ];

        cargoBuildFlags = [
          "--no-default-features"
          #"--features=binaries,ivf,y4m,serde"
        ];

        packages = with pkgs; [
pkg-configUpstream
          rustToolchain
          openssl
          cargo-deny
          cargo-edit
          cargo-watch
          rust-analyzer
          bacon
          clippy
          taplo
          lazygit
          lua5_2
          lua52Packages.lux-lua
          lux-cli
          # lua-language-server
          emmylua-check
          emmylua-ls
          emmylua-doc-cli
          stylua
          bc
          jq
          uv
          libGL
          libz
          glibc
          glib
          libvmaf
          ffmpeg-full
          opencv
          just-lsp
          luasmith.packages.${system}.default
          vqmetric-nix.packages.${system}.default
        ];
        shellHook = ''
          export PATH=$HOME/.cargo/bin:$PATH
          rustup default stable
          cargo install av-metrics-tool
        '';
        LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib/:${pkgs.libz}/lib/:${pkgs.libGL}/lib/:${pkgs.glib.out}/lib/:${pkgs.glibc}/lib/";
      };
    });
  };
}
