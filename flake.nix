{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    generated = import ./generated.nix;
  in {
    packages = lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nix-index-database = pkgs.fetchurl {
        url = "${generated.url}/index-${system}";
        hash = generated.${system}.index;
        name = "nix-index";

        recursiveHash = true;
        downloadToTemp = true;
        postFetch = ''
          mkdir -p "$out"
          mv "$downloadedFile" "$out/files"
        '';
      };

      nix-channel-index-programs = pkgs.fetchurl {
        url = "${generated.url}/programs-${system}.sqlite";
        hash = generated.${system}.programs;
        name = "programs.sqlite";
      };

      nix-channel-index-debug = pkgs.fetchurl {
        url = "${generated.url}/debug-${system}.sqlite";
        hash = generated.${system}.debug;
        name = "debug.sqlite";
      };
    });
  };
}
