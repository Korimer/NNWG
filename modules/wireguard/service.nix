{ config, lib, ... }:
let
  shared = import ./_shared.nix { inherit config; inherit lib; };

  addTaskDep = netns: iface: lib.nameValuePair
    "wireguard-${iface}"
    { requires = [ "netns-${netns}.service" ]; };
    

  interfaceDeps = map
    ( iface: addTaskDep iface "interfaceNamespace" )
    shared.wgToMapInterfaces;
  socketDeps = map
    ( iface: addTaskDep iface "socketNamespace" )
    shared.wgToMapSockets;

  allIfaceDeps = builtins.listToAttrs ( interfaceDeps ++ socketDeps );
in
{
  systemd.services = allIfaceDeps;
}
