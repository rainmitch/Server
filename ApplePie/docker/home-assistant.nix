
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."home-assistant" = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    ports = [
      
    ];
    volumes = [
      "/docker/homeAssistant/config:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];
    privileged = true;
    extraOptions = [
      "--network=host"
    ];
    environment = {
      TZ = "Europe/Madrid";
    };
  };

  systemd.services.docker-home-assistant = {
    after = [ "docker.service" "dbus-broker.service" "bluetooth.service" ];
    requires = [ "docker.service" "dbus-broker.service" "bluetooth.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];

  # Optional: If you plan to use Home Assistant's built-in HomeKit integration later, 
  # you will also need to open UDP port 5353 for mDNS/Discovery.
  networking.firewall.allowedUDPPorts = [ 5353 ];
}
