
{ config, lib, pkgs, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
      #connectionConfig = {
      #  # Force any connection on eno2 to have a low priority (high metric)
      #  "connection.ipv4-route-metric" = 100;
      #};
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

  services.resolved.enable = true;
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
        IP_ADDR=''$(${pkgs.iproute2}/bin/ip -4 addr show vpn-out | ${pkgs.gnugrep}/bin/grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        ${pkgs.iproute2}/bin/ip route add "$IP_ADDR" dev eno2 proto static || true
        # 1. Create the default route inside table 100
        ${pkgs.iproute2}/bin/ip route replace default dev vpn-out table 100
        
        # 2. Tell the kernel to use table 100 for marked packets
        ${pkgs.iproute2}/bin/ip rule add fwmark 0x1 table 100 || true
        
        # 3. Flush cache to make it immediate
        ${pkgs.iproute2}/bin/ip route flush cache
      '';

      # Tear down the interface
      ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down vpn-out";

      # Clean up routing rules on stop
      ExecStopPost = pkgs.writeShellScript "vpn-post-down" ''
        ${pkgs.iproute2}/bin/ip rule del fwmark 0x1 table 100 || true
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
        VPN_SERVER_IP=$(cat ${config.sops.secrets.WIREGUARD_VPN_IN_SERVER.path})
        VPN_CLIENT_IP=$(cat ${config.sops.secrets.WIREGUARD_VPN_IN_CLIENT.path})
        # 1. Clear the cache and ensure the default table 200 points to the tunnel
${pkgs.iproute2}/bin/ip route replace default dev vpn-in table 200

# 2. FIX: Pin the REMOTE VPN PROVIDER'S public gateway IP to eno2.
# This ensures the outer WireGuard encrypted packets always find the internet via your physical connection.
${pkgs.iproute2}/bin/ip route replace "$VPN_SERVER_IP" via 192.168.0.1 dev eno2 proto static

# 3. SOURCE RULE: If a packet originates FROM your local static VPN IP, force it to use Table 200
${pkgs.iproute2}/bin/ip rule add from "$VPN_CLIENT_IP" table 200 || true

# 4. INTERFACE RULES: Force anything entering or leaving vpn-in to use Table 200
${pkgs.iproute2}/bin/ip rule add iif vpn-in table 200 || true
${pkgs.iproute2}/bin/ip rule add oif vpn-in table 200 || true

${pkgs.iproute2}/bin/ip route flush cache
      '';

      # Tear down the interface
      ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down vpn-in";

      # Clean up routing rules on stop
      ExecStopPost = pkgs.writeShellScript "vpn-in-post-down" ''
        # Delete any rules pointing to table 200, regardless of dead interface names
        while ${pkgs.iproute2}/bin/ip rule show | ${pkgs.gnugrep}/bin/grep -q "table 200"; do
          ${pkgs.iproute2}/bin/ip rule del table 200
        done
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
