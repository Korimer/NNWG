{ config, lib, ... }:
let
  createFor = config.netNamespaces.createFor.wireguard;
  wgInterfaces = config.networking.wireguard.interfaces;

  getTargets = create-target: wg-target:
    let behavior = createFor.${create-target}; in
    map (name: wgInterfaces.${name}.${wg-target})(
      if behavior == true then builtins.attrNames wgInterfaces
      else if behavior == false then []
      else behavior
    );

  targetInterfaces = getTargets "interfaces" "interfaceNamespace";
  targetSockets = getTargets "sockets" "socketNamespace";

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
