{ config, lib, ... }:
let
  enabledInterfaces = 
    (lib.attrsets.filterAttrs
      (_: cfg:
        cfg.enable
        && cfg.wireguard.autoCreateNamespace
      )
      config.netns
    );

  listNamespaces = wg-cfg: []
  ++ (if (wg-cfg ? socketNamespace) && (wg-cfg.socketNamespace != "init")
      then [ wg-cfg.socketNamespace ] else [])
  ++ (if (wg-cfg ? interfaceNamespace) && (wg-cfg.interfaceNamespace != "init")
       then [ wg-cfg.interfaceNamespace ] else [])
  ;

  namespacesToCreate = lib.flatten (
    map
      (wg-cfg: listNamespaces wg-cfg)
      (builtins.attrValues enabledInterfaces)
  );

  MkNsDefault = name: lib.nameValuePair
    name
    {
      enable = true;
      systemd.before = [ "wireguard-${name}.service" ];
    };

  automaticNamespaces = builtins.listToAttrs 
    (map
      (interface: MkNsDefault interface)
      (lib.unique namespacesToCreate)
    );
in
{
  config.netns = lib.recursiveUpdate 
    automaticNamespaces
    config.netns
  ;
}
