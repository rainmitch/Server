
{ config, lib, pkgs, ... }:

{
  imports = [
    ./docker/portainer.nix
  ];
  
  hardware.nvidia-container-toolkit.enable = true;
  # Enable Docker virtualization
  virtualisation.docker = {
    enable = true;
  };
  systemd.services.docker = {
    after = [ "zfs-mount.service" ];
    wants = [ "zfs-mount.service" ];
  };
  
  
}
