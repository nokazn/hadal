{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils/master";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
          ];
        };
        packages = with pkgs; {
          inherit alejandra dprint treefmt editorconfig-checker pre-commit;
          nodejs = nodejs-16_x;
          pnpm = nodePackages.pnpm;
        };
      in {
        devShells.default = pkgs.devshell.mkShell {
          packages = builtins.attrValues packages;
          commands = with pkgs; [
            {
              name = "node";
              category = "nodejs";
              package = packages.nodejs;
            }
            {
              name = "pnpm";
              category = "nodejs";
              package = packages.pnpm;
            }
            {
              name = "treefmt";
              category = "formatter";
              package = packages.treefmt;
            }
            {
              name = "editorconfig";
              category = "linter";
              package = packages.editorconfig-checker;
            }
            {
              name = "pre-commit";
              category = "linter";
              package = packages.pre-commit;
            }
          ];
        };
      }
    );
}
