{ config, lib, ... }:
let
  createFor = config.netNamespaces.createFor.wireguard;
  wgInterfaces = config.networking.wireguard.interfaces;

  getTargets = create-target:
    let behavior = createFor.${create-target}; in
      if behavior == true then builtins.attrNames wgInterfaces
      else if behavior == false then []
      else behavior
  ;

  targetInterfaces = getTargets "interfaces";
  targetSockets = getTargets "sockets";
in
{
  wgInterfaces = config.networking.wireguard.interfaces;
  wgToMapInterfaces = targetInterfaces;
  wgToMapSockets = targetSockets;
}
