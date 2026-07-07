{ config, pkgs, lib, ... }:
let
  shared = import ./_shared.nix { inherit config; inherit lib; };

  enabledNameservers = shared.enabledNameservers;

  mkServiceDefault = name: {
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

  mkNetnsService = name: user-config:
    lib.recursiveUpdate (mkServiceDefault name) user-config;

  allServices = lib.mapAttrs'
    (name: cfg: lib.nameValuePair
      "netns-${name}"
      (mkNetnsService name cfg.systemd)
    )
    enabledNameservers;
in
{
  config.systemd.services = allServices;
}
