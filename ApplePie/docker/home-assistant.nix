
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."home-assistant" = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    ports = [
      "8123:8123"
      "5353:5353"
    ];
    volumes = [
      "/docker/homeAssistant/config:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];
    privileged = true;
    extraOptions = [
      "--network=home-net"
      "--network-alias=home-assistant"
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

  virtualisation.oci-containers.containers."zigbee2mqtt" = {
    image = "ghcr.io/koenkk/zigbee2mqtt:latest";
    ports = [
      "8124:8080"
    ];
    volumes = [
      "/docker/zigbee2mqtt/data:/app/data"
      "/run/udev:/run/udev:ro"
    ];
    extraOptions = [
      "--network=home-net"
      "--network-alias=zigbee2mqtt"
      "--device=/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_fa378100ecffef11924991256d9880ab-if00-port0:/dev/ttyUSB0"
    ];
    environment = {
      TZ = "Europe/Madrid";
    };
  };

  systemd.services.docker-zigbee2mqtt = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
 
  virtualisation.oci-containers.containers."eclipse-mosquitto" = {
    image = "eclipse-mosquitto:latest";
    ports = [
      "1883:1883"
    ];
    volumes = [
      "/docker/eclipse-mosquitto/config:/mosquitto/config"
      "/docker/eclipse-mosquitto/data:/mosquitto/data"
      "/docker/eclipse-mosquitto/log:/mosquitto/log"
    ];
    extraOptions = [
      "--network=home-net"
      "--network-alias=eclipse-mosquitto"
    ];
    
    environment = {
    };
  };

  systemd.services.docker-eclipse-mosquitto = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };

  virtualisation.oci-containers.containers."matter-server" = {
    image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
    ports = [
    ];
    volumes = [
      "/docker/matter-server/data:/data"
    ];
    extraOptions = [
      #"--network=host"
      "--network=home-net"
      "--network-alias=matter-server"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];

    environment = {
      CHIP_CONFIG_FORCE_FOUR_WAY_HANDSHAKE = "1"; 
      MATTER_SERVER_HOST = "0.0.0.0";
    };
  };

  systemd.services.docker-matter-server = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
