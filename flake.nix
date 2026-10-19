{
  description = "My mdBook theme and tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        treefmt-nix.flakeModule
        ./theme
        ./lib/build-book
        ./tests
      ];

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem = {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            actionlint.enable = true;
            biome = {
              enable = true;
              settings = {
                formatter = {
                  indentStyle = "space";
                  lineWidth = 100;
                };
                assist.actions.source.useSortedProperties = "on";
              };
            };
            mdformat = {
              enable = true;
              plugins = ps: [
                ps.mdformat-footnote
                ps.mdformat-gfm
                ps.mdformat-gfm-alerts
              ];
              settings = {
                number = true;
                wrap = 80;
              };
            };
            nixfmt.enable = true;
            taplo.enable = true;
            yamlfmt = {
              enable = true;
              settings.formatter.retain_line_breaks_single = true;
            };
          };
        };
      };
    };
}
