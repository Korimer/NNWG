{ config, lib, ... }:
{
  enabledNameservers = lib.filterAttrs
    (_: cfg: cfg.enable)
    config.netNamespaces.toCreate
  ;
}
