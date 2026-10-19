{ self, lib, ... }:

let
  defaults = lib.importTOML ./book.toml;

  background = lib.head (
    builtins.match ".*--palette-bg: (#[0-9a-f]+);.*" (builtins.readFile ../../theme/palette.css)
  );
in
{
  flake.lib.buildBook =
    { pkgs, src }:
    let
      theme = self.packages.${pkgs.stdenv.hostPlatform.system}.theme;
      config = lib.importTOML "${src}/book.toml";
      name = lib.strings.sanitizeDerivationName (lib.toLower "${config.book.title or "mdbook"}-book");

      bookToml = (pkgs.formats.toml { }).generate "book.toml" (
        lib.foldl' lib.recursiveUpdate { } [
          defaults
          config
          {
            output.html.additional-css =
              defaults.output.html.additional-css ++ config.output.html.additional-css or [ ];
          }
        ]
      );
    in
    assert lib.assertMsg (
      !(config.output.html or { }) ? theme
    ) "buildBook doesn't support output.html.theme in book.toml";
    pkgs.runCommand name
      {
        nativeBuildInputs = [ pkgs.mdbook ];
      }
      ''
        cp -r --no-preserve=mode ${src} book
        cd book
        cp ${bookToml} book.toml

        mkdir -p theme
        cp -rn ${theme}/. theme

        mdbook build --dest-dir "$out"

        # Replace mdBook's hardcoded theme-color with our background
        find "$out" -name '*.html' -exec sed -i '/name="theme-color"/s/#ffffff/${background}/' {} +
      '';
}
