
{ config, lib, pkgs, ... }:

{
  imports = [
    ./docker/portainer.nix
    ./docker/comfyui.nix
    ./docker/koboldcpp.nix
    ./docker/sillytavern.nix
    ./docker/shimmie2.nix
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
  
  # Define custom networks
  systemd.services.init-shimmie2-network = {
    description = "Create Shimmie2 Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect shimmie2-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create --driver bridge --subnet 172.20.0.0/16 shimmie2-net
    '';
  };
  
  systemd.services.init-ai-network = {
    description = "Create AI Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect ai-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create --driver bridge --subnet 172.21.0.0/16 ai-net
    '';
  };
}
