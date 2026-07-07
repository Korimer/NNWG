{ lib, config, ... }:
let
  shared = import ./_shared { inherit config; inherit lib; };

  enabledNameservers = shared.enabledNameservers;

  generateNameserverText = cfg: builtins.concatStringsSep "\n" (
    map
      (server: "nameserver ${server}")
      cfg.resolv.dns
  );

  generateResolv = cfg: builtins.concatStringsSep "\n" (
    map
      (generator: generator cfg)
      [
        generateNameserverText
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
