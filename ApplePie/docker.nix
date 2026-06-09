
{ config, lib, pkgs, ... }:

{
  imports = [
    ./docker/portainer.nix
    ./docker/comfyui.nix
  ];
  
  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = true;
  };
  environment.etc."cdi/nvidia-container-toolkit.json".source = "/var/run/cdi/nvidia-container-toolkit.json";
  # Enable Docker virtualization
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features = {
        cdi = true;
      };
      cdi-spec-dirs = [ "/var/run/cdi" "/etc/cdi" ];
    };
  };
  virtualisation.oci-containers.backend = "docker";
  systemd.services.docker = {
    after = [ "zfs-mount.service" ];
    wants = [ "zfs-mount.service" ];
  };
  
  
}
