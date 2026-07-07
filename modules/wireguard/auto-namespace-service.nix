{ config, lib, ... }:
let
  
  shared = import ./_shared.nix { inherit config; inherit lib; };

  targetInterfaces = map
    ( iface: iface.interfaceNamespace )
    shared.wgToMapInterfaces;

  targetSockets = map
    ( iface: iface.socketNamespace )
    shared.wgToMapSockets;

  targetNamespaces = lib.unique (builtins.filter
    (name: name != null && name != "init")
    (targetInterfaces ++ targetSockets)
  );

  mkNamespace = name: lib.nameValuePair
    name
    (with lib; {
      enable = mkDefault true;
      systemd.before = mkDefault [ "wireguard-${name}.service" ];
    });

  automaticNamespaces = builtins.listToAttrs 
    (map
      (interface: mkNamespace interface)
      targetNamespaces
    );
in
{
  config.netNamespaces.toCreate = automaticNamespaces;
}
