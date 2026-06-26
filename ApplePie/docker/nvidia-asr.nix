
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."nvidia-asr" = {
    image = "nemotron-speech-docker-cpu:latest";
    ports = [
      "8588:8000"
    ];
    volumes = [
    ];
    extraOptions = [
      "--network=ai-net"
      "--network=home-net"
      "--network-alias=nvidia-asr"
    ];
    environment = {
      
    };
  };

  systemd.services.docker-nvidia-asr = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
