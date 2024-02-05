let
  mozillaOverlay =
    import (builtins.fetchGit {
      url = "https://github.com/mozilla/nixpkgs-mozilla.git";
    });
  nixpkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };
in
with nixpkgs; pkgs.mkShell {
  nativeBuildInputs = [
      (nixpkgs.rustChannelOf { date = "2023-10-25"; channel = "nightly"; }).rust
  ];
}
