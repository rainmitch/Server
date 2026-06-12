{ config, lib, pkgs, ... }:

{
  users.users.rain = {
    isNormalUser = true;
    extraGroups = [ "wheel" "media" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      zsh
    ];
    shell = pkgs.zsh;
    home = "/home/rain";
  };
  
  users.groups.media = {
    gid = 1001;
  };

  users.users.media = {
    isSystemUser = true;
    uid = 1001;
    group = "media";     # Sets 'media' as the primary group
    description = "Service user for media containers";
  };
}
