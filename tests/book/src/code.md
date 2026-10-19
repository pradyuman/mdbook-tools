# Code

```nix
{ pkgs, lib, ... }:

{
  programs.example = {
    enable = true;
    package = pkgs.hello;
    settings.greeting = lib.mkDefault "hello, ${"world"}";
  };
}
```

```diff
- enable = false;
+ enable = true;
```

```sh
nix build .#checks.aarch64-darwin.book
```
