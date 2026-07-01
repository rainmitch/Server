
{ config, lib, pkgs, ... }:

{
  networking.nat.enable = false;
  networking.firewall.enable = false;
  networking.iproute2.enable = true;
  
  sops.templates."nftables-rules" = {
    content = ''
      # Clear out any old rules on reload
      flush ruleset
      
      # Define variables
      define WIREGUARD_VPN_IN_SERVER = ${builtins.readFile config.sops.secrets.WIREGUARD_VPN_IN_SERVER.path}
      define WIREGUARD_VPN_IN_CLIENT = ${builtins.readFile config.sops.secrets.WIREGUARD_VPN_IN_CLIENT.path}
      define WIREGUARD_VPN_OUT_SERVER = ${builtins.readFile config.sops.secrets.WIREGUARD_VPN_OUT_SERVER.path}
      define WIREGUARD_DNS_1 = ${builtins.readFile config.sops.secrets.WIREGUARD_DNS_1.path}
      define WIREGUARD_DNS_2 = ${builtins.readFile config.sops.secrets.WIREGUARD_DNS_2.path}
      # Import the modular nftables files
      ${builtins.readFile ./nftables/mangle-routing.nft}
      ${builtins.readFile ./nftables/nat.nft}
    '';
    reloadUnits = [ "nftables.service" ];
  };
    
  networking.nftables = {
    enable = true;
    rulesetFile = config.sops.templates."nftables-rules".path;
    checkRuleset = false;
  };
  
}
