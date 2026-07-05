{ lib, config, ... }:
let
  enabledNameservers = 
    (lib.attrsets.filterAttrs
      (_: cfg: cfg.enable)
      config.netns
    );

  GenerateNameservers = cfg: builtins.concatStringsSep "\n" (
    map
      (server: "nameserver ${server}")
      cfg.dns
  );
  GenerateAllText = cfg: builtins.concatStringsSep "\n" (
    map
      (Generator: Generator cfg)
      [
        GenerateNameservers
      ]
  );
in
{
  config.environment.etc =
  lib.mapAttrs'
    (name: value: {
      name = "netns/${name}/resolv.conf";
      value = { text = GenerateAllText value; };
    })
    enabledNameservers
  ;
}
