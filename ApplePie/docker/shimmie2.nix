
{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."shimmie2-postgres" = {
    image = "postgres:15-alpine";
    volumes = [
      "/docker/shimmie2/postgres:/var/lib/postgresql/data"
    ];
    environmentFiles = [
      config.sops.secrets.shimmie2_postgres.path
    ];
    environment = {
      
    };
    extraOptions = [
      "--network=shimmie2-net"
      "--ip=172.20.0.2"
    ];
  };

  systemd.services.docker-shimmie2-postgres = {
    after = [ "docker.service" "init-shimmie2-network.service" ];
    requires = [ "docker.service" "init-shimmie2-network.service" ];
  };
  
  virtualisation.oci-containers.containers."shimmie2-server" = {
    image = "shish2k/shimmie2:2";
    ports = [
      "7102:8000"
    ];
    dependsOn = [ "shimmie2-postgres" ];
    volumes = [
      "/docker/shimmie2/server/data:/app/data"
      "/docker/shimmie2/server/theme:/app/themes/mysitetheme"
      "/docker/shimmie2/server/ext:/app/ext/mysiteext"
    ];
    environmentFiles = [
      config.sops.secrets.shimmie2_postgres.path
    ];
    environment = {
      POSTGRES_HOST = "172.20.0.2";
    };
    extraOptions = [
      "--network=shimmie2-net"
      "--ip=172.20.0.3"
    ];
  };
  
  systemd.services.docker-shimmie2-server = {
    after = [ "docker.service" "init-shimmie2-network.service" ];
    requires = [ "docker.service" "init-shimmie2-network.service" ];
  };
}
