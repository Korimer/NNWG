{ lib, ... }:

{
  options.networking.netns = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ ... }: {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to create this network namespace.";
        };

        resolv = {
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
            description = ''
              Additional lines appended to the generated resolv.conf
              for this network namespace.
            '';
          };
        };

        systemd = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Additional attributes merged into the generated systemd service.";
        };
      };
    }));

    default = { };

    example = {
      my-vpn = {
        resolv.dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        resolv.extraOptions = ''
          options edns0
        '';

        systemd.before = [ "needs-my-vpn.service" ];
      };
    };

    description = "Declarative network namespace definitions.";
  };
}
