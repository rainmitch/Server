
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."wireguard-out" = {
    image = "linuxserver/wireguard:latest";
    ports = [
    ];
    volumes = [
      "/docker/wireguard/out:/config"
      "/lib/modules:/lib/modules"
      "\${CREDENTIALS_DIRECTORY}/vpn-out.conf:/config/wg0.conf:ro"
    ];
    extraOptions = [
      "--network=host"
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
      #"--network=blank-net"
      #"--network-alias=blank"
      #"--ip=172.blank.0.2"
    ];
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Madrid";
    };
  };

  systemd.services.docker-wireguard-out = {
    after = [ "docker.service" "sops-nix.service" ];
    requires = [ "docker.service"];
    
    serviceConfig = {
      # Systemd safely resolves the symlink and isolates ONLY this file for the service
      LoadCredential = "vpn-out.conf:/run/secrets/rendered/vpn-out.conf";
    };
  };
}
