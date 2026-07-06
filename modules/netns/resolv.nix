{ lib, config, ... }:
let
  enabledNameservers = lib.filterAttrs
    (_: cfg: cfg.enable)
    config.netNamespaces.toCreate
  ;

  generateNameserverText = cfg: builtins.concatStringsSep "\n" (
    map
      (server: "nameserver ${server}")
      cfg.dns
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
