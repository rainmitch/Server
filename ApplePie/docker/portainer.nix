
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      portainer = {
        image = "portainer/portainer-ce:latest";
        ports = [
          "8000:8000"
          "9443:9443" # HTTPS Port
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/docker/portainer:/data" # Stores Portainer configs natively on the NVMe drive
        ];
      };
    };
  };

  systemd.services.docker-portainer = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
