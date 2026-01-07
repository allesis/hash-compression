{
  description = "Flake for installing dependencies needed to use wrapper script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
          };
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: let
      lua_with_lux = pkgs.lua5_1.withPackages (ps: [
        ps.lux-lua
      ]);
    in {
      default = pkgs.mkShell {
        nativeBuildInputs = [
          lua_with_lux
          pkgs.lux-cli
        ];

        packages = with pkgs; [
          lux-cli
	  lua_with_lux
          # lua-language-server
          emmylua-check
          emmylua-ls
          emmylua-doc-cli
          emmy-lua-code-style
          stylua
	  uv
	  python314
          python313Packages.jedi-language-server
	  just-lsp
        ];
      };
    });
  };
}
