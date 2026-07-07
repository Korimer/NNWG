{ config, lib, ... }:
let
  shared = import ./_shared { inherit config; inherit lib; };

  addTaskDep = netns: iface: lib.nameValuePair
    "wireguard-${iface}"
    { requires = [ "netns-${netns}.service" ]; };
    

  interfaceDeps = map
    ( iface: addTaskDep iface "interfaceNamespace" )
    shared.wgToMapInterface;
  socketDeps = map
    ( iface: addTaskDep iface "socketNamespace" )
    shared.wgToMapSocket;

  allIfaceDeps = builtins.listToAttrs ( interfaceDeps ++ socketDeps );
in
{
  systemd.services = allIfaceDeps;
}
