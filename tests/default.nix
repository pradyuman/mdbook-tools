{ self, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      checks.book = self.lib.buildBook {
        inherit pkgs;
        src = ./book;
      };
    };
}
