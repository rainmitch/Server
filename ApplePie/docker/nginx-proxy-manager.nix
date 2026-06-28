
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."nginx-proxy-manager" = {
    image = "jc21/nginx-proxy-manager:latest";
    ports = [
    ];
    volumes = [
      "/docker/nginx-proxy-manager/data:/data"
      "/docker/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
    ];
    extraOptions = [
      "--network=services-net"
      "--ip=172.24.0.2"
    ];
    environment = {
      TZ = "Europe/Madrid";
    };
  };

  systemd.services.docker-nginx-proxy-manager = {
    after = [ "docker.service" "init-services-network.service" ];
    requires = [ "docker.service" "init-services-network.service" ];
  };
}
