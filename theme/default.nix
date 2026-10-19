{
  perSystem =
    { pkgs, lib, ... }:
    let
      stylesheets = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.fileFilter (file: file.hasExt "css") ./.;
      };

      # Replace mdBook's highlight.js 10, whose Nix grammar lacks operators, paths, and parameters
      highlightJs =
        let
          release = pkgs.fetchFromGitHub {
            owner = "highlightjs";
            repo = "cdn-release";
            tag = "11.12.0";
            hash = "sha256-U8/85RnyBM55Gnzy803XAud27eOTy15PXtIAG4TwKqk=";
          };
        in
        pkgs.runCommand "highlight.js" { } ''
          cat ${release}/build/highlight.min.js ${release}/build/languages/nix.min.js > $out

          # Remove the Nix grammar's beforeMatch pattern, which can match empty text at the start of
          # a block and makes highlight.js skip its first character
          substituteInPlace $out --replace-fail 'beforeMatch:/(^|\{|;)\s*/,' ""

          # mdBook calls highlightBlock, which is deprecated in highlight.js 11
          echo 'hljs.highlightBlock = hljs.highlightElement;' >> $out
        '';
    in
    {
      packages.theme =
        pkgs.runCommand "mdbook-theme"
          {
            nativeBuildInputs = [ pkgs.woff2 ];
          }
          ''
            cp -r --no-preserve=mode ${stylesheets} $out
            cp ${highlightJs} $out/highlight.js

            # Replace mdBook's highlight stylesheets with highlight.css
            cp $out/highlight.css $out/tomorrow-night.css
            cp $out/highlight.css $out/ayu-highlight.css

            # Rename the variable fonts from Name[wght].ttf to keep brackets out of URLs
            cp ${pkgs.atkinson-hyperlegible-next}/share/fonts/truetype/AtkinsonHyperlegibleNext\[wght\].ttf $out/fonts/AtkinsonHyperlegibleNext.ttf
            cp ${pkgs.atkinson-hyperlegible-next}/share/fonts/truetype/AtkinsonHyperlegibleNext-Italic\[wght\].ttf $out/fonts/AtkinsonHyperlegibleNext-Italic.ttf
            cp ${pkgs.hasklig}/share/fonts/opentype/Hasklig-{Regular,It,Semibold}.otf $out/fonts

            for font in $out/fonts/*.{ttf,otf}; do
              woff2_compress "$font"
              rm "$font"
            done
          '';
    };
}
