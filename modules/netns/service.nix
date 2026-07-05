{ config, pkgs, lib, ... }:
let
  enabledNameservers = 
    (lib.attrsets.filterAttrs
      (_: cfg: cfg.enable)
      config.netns
    );

  MkServiceDefault = name: {
    description = "Create network namespace ${name}";

    wantedBy = [ "multi-user.target" ];
    before = [ "network.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = ''
        ${pkgs.iproute2}/bin/ip netns add ${name}
      '';

      ExecStop = ''
        ${pkgs.iproute2}/bin/ip netns del ${name}
      '';
    };
  };

  MkNetnsService = name: overrides:
    lib.recursiveUpdate (MkServiceDefault name) overrides;
in
{
  config.systemd.services =
    lib.mapAttrs'
      (name: cfg: lib.nameValuePair
        "netns-${name}"
        (MkNetnsService name cfg.systemd)
      )
      enabledNameservers;
}
