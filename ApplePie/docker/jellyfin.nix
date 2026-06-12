
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "linuxserver/jellyfin";
    ports = [
      "8096:8096"
    ];
    volumes = [
      "/docker/jellyfin/library:/config"
      "/tank/media:/media"
    ];
    environment = {
      PUID = "1001";
      PGID = "1001";
      TZ = "Europe/Madrid";
    };
    extraOptions = [
      "--network=media-net"
      "--network-alias=jellyfin"
      "--ip=172.22.0.2"
    ];
  };

  systemd.services.docker-jellyfin = {
    after = [ "docker.service" "init-media-network.service" ];
    requires = [ "docker.service" "init-media-network.service" ];
  };
}
