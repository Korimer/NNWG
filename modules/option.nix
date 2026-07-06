{ lib, ... }:

{
  options.netns = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ ... }: {

      options = {

        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to create this network namespace.";
        };

        resolv = lib.mkOption {
          type = lib.types.submodule {
            options = {
              dns = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [ "1.1.1.1" "8.8.8.8" ];
                description = "DNS servers for this namespace.";
              };

              extraOptions = lib.mkOption {
                type = lib.types.lines;
                default = "";
                example = ''
                  options edns0
                  search example.com
                '';
                description = "Extra resolv.conf lines.";
              };
            };
          };
        };

        systemd = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.anything;
          };
          description = "Extra systemd service attributes.";
        };

        wireguard = lib.mkOption {
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              autoCreateNamespace = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };

              config = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = { };
                description = "WireGuard interface config.";
              };
            };
          };
          description = "Namespace WireGuard configuration.";
        };

      };
    }));

    default = { };

    example = {
      my-vpn = {
        resolv.dns = [ "1.1.1.1" "8.8.8.8" ];

        resolv.extraOptions = ''
          options edns0
        '';

        systemd.before = [ "needs-my-vpn.service" ];

        wireguard = {
          enable = true;
          autoCreateNamespace = true;
          config = {
            ips = [ "10.0.0.2/32" ];
          };
        };
      };
    };

    description = "Declarative network namespace definitions.";
  };
}
