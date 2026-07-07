{ lib, config, ... }:
let
  shared = import ./_shared.nix { inherit config; inherit lib; };

  enabledNameservers = shared.enabledNameservers;

  generateNameserverText = cfg: builtins.concatStringsSep "\n" (
    map
      (server: "nameserver ${server}")
      cfg.resolv.dns
  );
  generateExtraOptions = cfg: cfg.resolv.extraOptions;

  generateResolv = cfg: builtins.concatStringsSep "\n" (
    map
      (generator: generator cfg)
      [
        generateNameserverText
        generateExtraOptions
      ]
  );

  allResolvs = lib.mapAttrs'
    (name: value: {
      name = "netns/${name}/resolv.conf";
      value = { text = generateResolv value; };
    })
    enabledNameservers
  ;
in
{
  config.environment.etc = allResolvs;
}
