{ config, lib, ... }:
let
  createFor = config.netNamespaces.createFor.wireguard;
  wgInterfaces = config.networking.wireguard.interfaces;

  getTargets = create-target:
    let behavior = createFor.${create-target}; in
      if behavior == true then wgInterfaces
      else if behavior == false then []
      else behavior
  ;

  targetInterfaces = getTargets "interfaces";
  targetSockets = getTargets "sockets";
in
{
  wgToMapInterfaces = targetInterfaces;
  wgToMapSockets = targetSockets;
}
