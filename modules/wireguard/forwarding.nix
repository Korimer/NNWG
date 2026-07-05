{ config, lib, ... }:
let
  enabledInterfaces = 
    (lib.attrsets.filterAttrs
      (_: cfg: cfg.enable && cfg.wireguard.enable)
      config.netns
    );

  wireguardInterfaces = builtins.mapAttrs
    (_: cfg: cfg.wireguard)
    enabledInterfaces
  ;
in
{
  config.networking.wireguard.interfaces =
    lib.recursiveUpdate
      config.wireguard.interfaces
      wireguardInterfaces
  ;
}
