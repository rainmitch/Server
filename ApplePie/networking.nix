
{ config, lib, pkgs, ... }:

{
  networking = {
    networkmanager.enable = true;
    hostName = "Server";
    hostId = "69beef69";
    nameservers = ["1.1.1.1"];
    interfaces.eno2 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.0.10";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eno2";
    };
  };

  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PermitRootLogin = "no";
    };
  };
}
