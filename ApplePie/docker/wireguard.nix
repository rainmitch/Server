
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."wireguard-in" = {
    image = "linuxserver/wireguard:latest";
    ports = [
    ];
    volumes = [
      "/docker/wireguard/in:/config"
      "/lib/modules:/lib/modules"
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

  systemd.services.docker-wireguard-in = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
