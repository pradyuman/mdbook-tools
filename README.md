# mdbook-tools

My [mdBook](https://rust-lang.github.io/mdBook/) theme and tools.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Add mdbook-tools to your flake inputs
    mdbook-tools = {
      url = "github:pradyuman/mdbook-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { mdbook-tools, nixpkgs, ... }:
    {
      packages.aarch64-darwin.docs = mdbook-tools.lib.buildBook {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;

        # A directory with your book.toml and src/
        src = ./docs;
      };
    };
}
```

Then build your book with `nix build .#docs` and open `result/index.html` to see
it.

## Configuration

`buildBook` merges your `book.toml` with these
[defaults](lib/build-book/book.toml), so you only need to set what's unique to
your book:

```toml
[book]
title = "My project"

[output.html]
git-repository-url = "https://github.com/you/my-project"
```

Your settings take precedence over the defaults.
