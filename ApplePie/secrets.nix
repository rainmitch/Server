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
  
  /*sops.templates."vpn-in.conf" = {
    # This is where the container will look for the file
    path = "/docker/wireguard/in/vpn-in.conf"; 
    
    # syntax for inserting the decrypted values into the template
    content = ''
      [Interface]
      PrivateKey = ${config.sops.secrets.vpn_in.vpn_in."WIREGUARD_PRIVATE_KEY"}
      Address = ${config.sops.secrets.vpn_in."WIREGUARD_ADDRESSES"}
      DNS = ${config.sops.secrets.vpn_in."WIREGUARD_DNS_ADDRESSES"}

      [Peer]
      PublicKey = ${config.sops.secrets.vpn_in."WIREGUARD_PUBLIC_KEY"}
      Endpoint = ${config.sops.secrets.vpn_in."WIREGUARD_ENDPOINT"}
      AllowedIPs = ${config.sops.secrets.vpn_in."WIREGUARD_ALLOWED_IPS"}
    '';
  };*/
}
