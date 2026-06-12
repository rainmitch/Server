
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."gluetun-in" = {
    image = "qmcgaw/gluetun:latest";
    ports = [
      "8101:8118"
    ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      #"--device=/dev/net/tun-in:/dev/net/tun"
      "--network=vpn-in-net"
      "--network-alias=vpn-in"
    ];
    environment = {
      VPN_SERVICE_PROVIDER = "custom";
      VPN_TYPE = "wireguard";
      DOT = "off";
    };
    environmentFiles = [
      config.sops.secrets.vpn_in.path
    ];
  };

  systemd.services.docker-gluetun-in = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };

  
  virtualisation.oci-containers.containers."gluetun-out" = {
    image = "qmcgaw/gluetun:latest";
    ports = [
      "8102:8118"
    ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      #"--device=/dev/net/tun-out:/dev/net/tun"
      "--network=vpn-out-net"
      "--network-alias=vpn-out"
      "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
    ];
    environment = {
      VPN_SERVICE_PROVIDER = "custom";
      VPN_TYPE = "wireguard";
      DOT = "off";
    };
    environmentFiles = [
      config.sops.secrets.vpn_out.path
    ];
  };

  systemd.services.docker-gluetun-out = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
