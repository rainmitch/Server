
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."comfyui" = {
    image = "yanwk/comfyui-boot:cu130-megapak-pt211";
    ports = [
      "8188:8188"
    ];
    volumes = [
      "/docker/comfyUI:/root"
    ];
    extraOptions = [
      #"--tty"
      #"--interactive"         # Replaces stdin_open: true
      "--device=nvidia.com/gpu=all"
      #"--config=/var/lib/docker"
    ];
  };

  systemd.services.docker-comfyui = {
    after = [ "docker.service" "nvidia-container-toolkit-cdi-generator.service" ];
    requires = [ "docker.service" "nvidia-container-toolkit-cdi-generator.service" ];
    environment = {
      CDI_SPEC_DIRS = "/var/run/cdi";
    };
    serviceConfig = {
    DeviceAllow = [
        "/dev/nvidia* rwm"
        "/dev/nvidia-uvm rwm"
        "/dev/nvidia-uvm-tools rwm"
        "/dev/nvidiactl rwm"
      ];
    };
    # Gives the Docker daemon 3 seconds to fully release the GPU from the old container instance
    #preStart = "${pkgs.coreutils}/bin/sleep 3";
  };
}
