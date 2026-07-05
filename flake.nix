{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { ... }: {

    nixosModules = {
      default = { imports = [ ./modules ]; };
      netns = { imports = [ ./modules/netns ]; };
    };
  };
}
