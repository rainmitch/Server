
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    ports = [
      "8095:8080"
    ];
    volumes = [
      "/docker/qbittorrent/config:/config"
      "/tank/torrents/data:/data"
      "/tank/torrents/torrent_files:/torrent_files"
    ];
    extraOptions = [
      #"--network=vpn-out-net"
      #"--network=media-net"
      #"--network-alias=qbittorrent"
      "--network=host"
      #"--ip=172.22.0.2"
    ];
    environment = {
      PUID = "1001";
      PGID = "1001";
      TZ = "Europe/Madrid";
      QBT_LEGAL_NOTICE = "confirm";
      WEBUI_PORT="8080";
    };
    environmentFiles = [
      config.sops.secrets.qbittorrent.path
    ];
  };

  systemd.services.docker-qbittorrent = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
