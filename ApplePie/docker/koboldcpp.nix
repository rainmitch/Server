
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."koboldcpp" = {
    image = "koboldai/koboldcpp:latest";
    ports = [
      "8288:5001"
    ];
    volumes = [
      "/docker/koboldcpp/data:/workspace"
      "/opt/models:/models"
    ];
    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--network-alias=koboldcpp"
      "--network=ai-net"
      "--ip=172.21.0.3"
    ];
    environmentFiles = [
      config.sops.secrets.koboldcpp.path
    ];
    environment = {
      KCPP_DONT_UPDATE = "false";
      KCPP_DONT_TUNNEL = "true";
      KCPP_ARGS = "--model /models/gemma-4-12B-it-qat-q4_0-unquantized-heretic-Q4_K_M.gguf --usecuda --flashattention --useswa --gpulayers 99 --context 73728 --smartcache 2 --jinja --jinjathink true --adminpassword \"$KCPP_ADMINPASSWORD\" --admin --chat-template-kwargs \"{\"enable_thinking\": true}\"";
    };
  };

  systemd.services.docker-koboldcpp = {
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
  };
}
