{ lib, ... }:

with lib;

let
  boolOrStringList =
    types.either
      types.bool
      (types.listOf types.str);
in
{
  options.netNamespaces = {
    createFor = {
      wireguard = {
        sockets = mkOption {
          type = boolOrStringList;
          default = false;
          example = true;
          description = ''
            Automatically create network namespaces referenced in `networking.wireguard.interfaces.<name>.socketNamespace`.
            May be either:

            - `true` to create namespaces for all WireGuard sockets.
            - `false` to create no namespaces.
            - A list of WireGuard interface names corresponding to `networking.wireguard.interfaces.<name>`.
          '';
        };

        interfaces = mkOption {
          type = boolOrStringList;
          default = false;
          example = [ "wg0" "wg1" ];
          description = ''
            Automatically create network namespaces referenced in `networking.wireguard.interfaces.<name>.interfaceNamespace`.
            May be either:

            - `true` to create namespaces for all WireGuard interfaces.
            - `false` to create no namespaces.
            - A list of WireGuard interface names corresponding to `networking.wireguard.interfaces.<name>`.
          '';
        };
      };
    };

    toCreate = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({ ... }: {
        enable = mkOption {
          type = bool;
          description = "Whether or not to automatically create this namespace.";
        };

        options = {
          resolv = {
            dns = mkOption {
              type = types.listOf types.str;
              default = [];
              example = [ "1.1.1.1" "8.8.8.8" ];
              description = "DNS servers to write to resolv.conf.";
            };

            extraOptions = mkOption {
              type = types.lines;
              default = "";
              example = ''
                options edns0
                search example.com
              '';
              description = "Additional lines appended to resolv.conf.";
            };
          };

          systemd = mkOption {
            type = types.submodule ({ ... }: {
              freeformType = attrs;
            });
            default = {};
            example = {
              before = [ "postrequisite.service" ];
            };
            description = ''
              Extra attributes merged into the generated
              `systemd.services.netns-<name>` definition.
            '';
          };
        };
      }));

      description = ''
        Network namespaces to create.

        Each attribute name is the namespace name.
      '';
    };
  };
}
