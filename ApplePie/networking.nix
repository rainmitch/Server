
{ config, lib, pkgs, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
      #connectionConfig = {
      #  # Force any connection on eno2 to have a low priority (high metric)
      #  "connection.ipv4-route-metric" = 100;
      #};
      dns = "systemd-resolved";
    };
    hostName = "Server";
    hostId = "69beef69";
    nameservers = ["1.1.1.1"];
    enableIPv6 = true;
    interfaces.eno2 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.0.10";
        prefixLength = 24;
      }];
      #ipv6.addresses = [
      #{
      #  address = "2001:db8::2";
      #  prefixLength = 64;
      #}
      #];
    };
    defaultGateway = {
      interface = "eno2";
      address = "192.168.0.1";
    };
  };
  services.resolved = {
    enable = true;
    settings = {
    Resolve = {
      # Pass the sops paths straight to systemd's dynamic include processor
      # systemd-resolved will cleanly parse these values on boot
      DNS = [
        "${builtins.readFile config.sops.secrets.WIREGUARD_DNS_1.path}"
        "${builtins.readFile config.sops.secrets.WIREGUARD_DNS_2.path}"
      ];
      Domains = [ "~." ];
    };
    };
  };
  systemd.services.wg-quick-vpn-out = {
    description = "WireGuard Tunnel Client vpn-out";
    after = [ "network.target" "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      
      # Bring up the interface (reads your separate config file)
      ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up vpn-out";

      # ExecStartPost runs IMMEDIATELY after ExecStart succeeds.
      # This is where we configure Table 100 safely.
      ExecStartPost = pkgs.writeShellScript "vpn-post-up" ''
        VPN_SERVER_IP=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.WIREGUARD_VPN_OUT_SERVER.path})
        ${pkgs.iproute2}/bin/ip route add "$VPN_SERVER_IP" via 192.168.0.1 dev eno2 proto static || true
        # Create the default route inside table 100
        ${pkgs.iproute2}/bin/ip route replace default dev vpn-out table 100
        
        # Tell the kernel to use table 100 for marked packets
        ${pkgs.iproute2}/bin/ip rule add fwmark 0x1 table 100 || true
        
        # Flush cache to make it immediate
        ${pkgs.iproute2}/bin/ip route flush cache
      '';

      # Tear down the interface
      ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down vpn-out";

      # Clean up routing rules on stop
      ExecStopPost = pkgs.writeShellScript "vpn-post-down" ''
        VPN_SERVER_IP=$(cat ${config.sops.secrets.WIREGUARD_VPN_OUT_SERVER.path})
        ${pkgs.iproute2}/bin/ip rule del fwmark 0x1 table 100 || true
        ${pkgs.iproute2}/bin/ip route flush table 100 || true
        ${pkgs.iproute2}/bin/ip route del "$VPN_SERVER_IP" via 192.168.0.1 dev eno2 proto static || true
        ${pkgs.iproute2}/bin/ip route flush cache
      '';
    };
  };
  
  systemd.services.wg-quick-vpn-in = {
    description = "WireGuard Tunnel Client vpn-in";
    after = [ "network.target" "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      # Bring up the interface (reads your separate config file)
      ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up vpn-in";

      # ExecStartPost runs IMMEDIATELY after ExecStart succeeds.
      # This is where we configure Table 100 safely.
      ExecStartPost = pkgs.writeShellScript "vpn-in-post-up" ''
        VPN_SERVER_IP=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.WIREGUARD_VPN_IN_SERVER.path})
        ${pkgs.iproute2}/bin/ip route add "$VPN_SERVER_IP" via 192.168.0.1 dev eno2 proto static || true
        # Create the default route inside table 200
        ${pkgs.iproute2}/bin/ip route replace default dev vpn-out table 200

        # Tell the kernel to use table 200 for marked packets
        ${pkgs.iproute2}/bin/ip rule add fwmark 0x2 table 200 || true

        # Flush cache to make it immediate
        ${pkgs.iproute2}/bin/ip route flush cache
      '';


      # Tear down the interface
      ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down vpn-in";

      # Clean up routing rules on stop
      ExecStopPost = pkgs.writeShellScript "vpn-in-post-down" ''
        VPN_SERVER_IP=$(cat ${config.sops.secrets.WIREGUARD_VPN_IN_SERVER.path})
        ${pkgs.iproute2}/bin/ip rule del fwmark 0x2 table 200 || true
        ${pkgs.iproute2}/bin/ip route flush table 200 || true
        ${pkgs.iproute2}/bin/ip route del "$VPN_SERVER_IP" via 192.168.0.1 dev eno2 proto static || true
        ${pkgs.iproute2}/bin/ip route flush cache
      '';
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
