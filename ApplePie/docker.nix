
{ config, lib, pkgs, ... }:

{
  imports = [
    #./docker/gluetun.nix
    #./docker/wireguard.nix
    ./docker/portainer.nix
    ./docker/nginx-proxy-manager.nix
    #./docker/comfyui.nix
    ./docker/kokoro.nix
    ./docker/nvidia-asr.nix
    ./docker/koboldcpp.nix
    ./docker/sillytavern.nix
    ./docker/openWebUI.nix
    ./docker/shimmie2.nix
    ./docker/jellyfin.nix
    ./docker/home-assistant.nix
    ./docker/qbittorrent.nix
  ];
  
  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = true;
  };
  environment.etc."cdi/nvidia-container-toolkit.json".source = "/var/run/cdi/nvidia-container-toolkit.json";
  # Enable Docker virtualization
  virtualisation.docker = {
    enable = true;
    extraOptions = "--iptables=false --ipv6 --fixed-cidr-v6=\"fd00:ffff::/64\"";
    daemon.settings = {
      features = {
        cdi = true;
      };
      cdi-spec-dirs = [ "/var/run/cdi" "/etc/cdi" ];
      dns = [
      "${builtins.replaceStrings ["\n"] [""] (builtins.readFile config.sops.secrets.WIREGUARD_DNS_1.path)}"
      "${builtins.replaceStrings ["\n"] [""] (builtins.readFile config.sops.secrets.WIREGUARD_DNS_2.path)}"
    ];
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
  
  systemd.services.init-media-network = {
    description = "Create Media Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect media-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create --driver bridge --subnet 172.22.0.0/16 media-net
    '';
  };
  
  systemd.services.init-home-network = {
    description = "Create Home Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect home-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create --driver bridge --subnet 172.23.0.0/16 --ipv6 home-net
    '';
  };
  
  systemd.services.init-services-network = {
    description = "Create Services Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect services-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create --driver bridge --subnet 172.24.0.0/16 services-net
    '';
  };

  /*
  # VPN NETWORKS
  systemd.services.init-vpn-in = {
    description = "Create VPN In Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect vpn-in-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create --driver bridge --subnet 172.51.0.0/16 vpn-in-net --opt com.docker.network.bridge.name=vpn-in-br
    '';
  };
  */

  systemd.services.init-vpn-out = {
    description = "Create VPN Out Private Docker Network";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect vpn-out-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create -d ipvlan --subnet 172.52.0.0/16 -o parent=vpn-out -o ipvlan_mode=l3 vpn-out-net
    '';
  };
}
