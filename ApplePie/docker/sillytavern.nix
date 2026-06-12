
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."sillytavern" = {
    image = "ghcr.io/sillytavern/sillytavern:latest";
    ports = [
      "7388:8000"
    ];
    volumes = [
      "/docker/sillytavern/config:/home/node/app/config"
      "/docker/sillytavern/data:/home/node/app/data"
      "/docker/sillytavern/plugins:/home/node/app/plugins"
      "/docker/sillytavern/extensions:/home/node/app/public/scripts/extensions/third-party"
    ];
    environment = {
      NODE_ENV = "production";
      FORCE_COLOR = "1";
      SILLYTAVERN_HEARTBEATINTERVAL = "30";
    };
    extraOptions = [
      "--network-alias=sillytavern"
      "--network=ai-net"
      "--ip=172.21.0.4"
    ];
  };

  systemd.services.docker-sillytavern = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
