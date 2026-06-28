{ config, lib, pkgs, ... }:

{
  imports = [
    <sops-nix/modules/sops>
  ];
  sops.defaultSopsFile = /etc/nixos/secrets/secrets.yaml; # Adjust path to your actual secrets file
  sops.age.keyFile = "/etc/sops/sops.key"; # Path to your age key
  #sops.validateSopsFiles = false; # <-- Add this line
  sops.secrets.shimmie2_postgres = {
    owner = "root";
    group = "root";
    mode = "0600";
  };
  sops.secrets.koboldcpp = {
    owner = "root";
    group = "root";
    mode = "0600";
  };
  sops.secrets.qbittorrent = {
    owner = "root";
    group = "root";
    mode = "0600";
  };
  
  sops.secrets = {
    WIREGUARD_VPN_OUT_CONF     = {};
    WIREGUARD_VPN_OUT_SERVER   = {};
    WIREGUARD_VPN_IN_CONF      = {};
    WIREGUARD_VPN_IN_SERVER    = {};
    WIREGUARD_VPN_IN_CLIENT    = {};
    WIREGUARD_DNS_1            = {};
    WIREGUARD_DNS_2            = {};
  };

  
  sops.templates."vpn-out.conf" = {
    # This is where the container will look for the file
    #path = "/docker/wireguard/out/wg_confs/vpn-out.conf";
    path = "/etc/wireguard/vpn-out.conf";
    owner = "rain";
    group = "users";
    mode = "0600";

    # syntax for inserting the decrypted values into the template
    content = ''${config.sops.placeholder.WIREGUARD_VPN_OUT_CONF}'';
  };
  
  sops.templates."vpn-in.conf" = {
    # This is where the container will look for the file
    #path = "/docker/wireguard/out/wg_confs/vpn-out.conf";
    path = "/etc/wireguard/vpn-in.conf";
    owner = "rain";
    group = "users";
    mode = "0600";

    # syntax for inserting the decrypted values into the template
    content = ''${config.sops.placeholder.WIREGUARD_VPN_IN_CONF}'';
  };
  
  environment.etc."nftables-secrets.conf" = {
    text = ''
      define vpn_in_server_ip = ${config.sops.placeholder.WIREGUARD_VPN_IN_SERVER}
      define sops_vpn_in_static_ip = ${config.sops.placeholder.WIREGUARD_VPN_IN_CLIENT}
    '';
  };
}
