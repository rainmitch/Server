
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."open-webui" = {
    image = "ghcr.io/open-webui/open-webui:main";
    ports = [
      "7000:8080"
    ];
    volumes = [
      "/docker/openWebUI:/app/backend/data"
    ];
    extraOptions = [
      "--network=ai-net"
      "--network-alias=openWebUI"
    ];
  };

  systemd.services.docker-comfyui = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
