
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."kokoro" = {
    image = "ghcr.io/remsky/kokoro-fastapi-cpu:latest";
    ports = [
      "8488:8880"
    ];
    volumes = [
      #"/docker/kokoro/models:/app/api/src/models"
    ];
    extraOptions = [
      "--network=ai-net"
      "--network=home-net"
      "--network-alias=kokoro"
    ];
    environment = {
      "PYTHONPATH" = "/app:/app/api";
      "PYTHONUNBUFFERED" = "1";
      "API_LOG_LEVEL" = "DEBUG";
      "DOWNLOAD_MODEL" = "true";
      "OUTPUT_FORMAT" = "pcm";
      "QT_AUDIO_OUT" = "true";
      "ONNX_NUM_THREADS" = "8";  # Maximize core usage for vectorized ops
      "ONNX_INTER_OP_THREADS" = "4";  # Higher inter-op for parallel matrix operations
      "ONNX_EXECUTION_MODE" = "parallel";
      "ONNX_OPTIMIZATION_LEVEL" = "all";
      "ONNX_MEMORY_PATTERN" = "true";
      "ONNX_ARENA_EXTEND_STRATEGY" = "kNextPowerOfTwo";
    };
  };

  systemd.services.docker-kokoro = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
  };
}
