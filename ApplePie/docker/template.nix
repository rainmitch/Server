
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."" = {
    image = "";
    ports = [
    ];
    volumes = [
    ];
    extraOptions = [
      #"--network=blank-net"
      #"--network-alias=blank"
      #"--ip=172.blank.0.2"
    ];
    environment = {
      
    };
  };

  systemd.services.docker-<blank> = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
