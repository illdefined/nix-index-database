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
        url = "${generated.url}/${system}-index";
        hash = generated.${system}.index;
        name = "nix-index";

        downloadToTemp = true;
        postFetch = ''
          mkdir -p "$out"
          mv "$downloadedFile" "$out/files"
        '';
      };

      nix-channel-index-programs = pkgs.fetchurl {
        url = "${generated.url}/${system}-programs.sqlite";
        hash = generated.${system}.programs;
        name = "programs.sqlite";
      };

      nix-channel-index-debug = pkgs.fetchurl {
        url = "${generated.url}/${system}-debug.sqlite";
        hash = generated.${system}.debug;
        name = "debug.sqlite";
      };
    });
  };
}
