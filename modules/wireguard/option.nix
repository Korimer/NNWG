{ lib, ... }:
{
  options.netns.wireguard = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ ... }: {
      enable = lib.types.mkOption {
        type = lib.types.bool;
        default = true;
      };
      autoCreateNamespace = lib.types.mkOption {
        type = lib.types.bool;
        default = true;
      };
      config = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Vanilla NixOS WireGuard configuration.";
      };

    }));

    default = { };

    example = {
      vpn = {
        enable = true;
        autoCreateNamespace = true;

        # Options for networking.wireguard.interfaces.<name>
        config = {
          ips = [ "10.0.0.2/32" ];
          privateKeyFile = "/run/secrets/wg.key";

          peers = [
            {
              publicKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
              endpoint = "vpn.example.com:51820";
              allowedIPs = [ "0.0.0.0/0" "::/0" ];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

    description = "Namespace-enhanced wireguard configurations.";
  };
}

