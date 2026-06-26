
{ config, lib, pkgs, ... }:

{
  networking.nat.enable = false;
  networking.firewall.enable = false;
  networking.iproute2.enable = true;
  
  sops.templates."nftables-rules" = {
    content = ''
    table ip mangle-routing {
      chain prerouting {
        type filter hook prerouting priority mangle; policy accept;

        ip saddr 172.16.0.0/12 ip daddr != 172.16.0.0/12 ip daddr != 192.168.0.0/24 meta mark set 0x1

        # If a brand new connection arrives on vpn-in, mark the whole connection as 0x2
        iifname "vpn-in" ct mark set 0x2
      }

      chain input {
        type filter hook input priority filter; policy drop;
        
        # 1. Allow traffic on loopback (essential for local system health)
        iifname "lo" accept

        # 2. Allow established and related traffic (allows replies to things YOU started)
        ct state established,related accept

        # 3. Allow your local home/office LAN subnet to talk to the server
        ip saddr 192.168.0.0/24 accept
        
        ip saddr ${config.sops.placeholder.WIREGUARD_VPN_IN_SERVER} meta l4proto { tcp, udp } th dport { 9930 } counter accept
        iifname "vpn-in" meta l4proto tcp th dport { 80, 443 } counter accept
        ip saddr ${config.sops.placeholder.WIREGUARD_VPN_IN_SERVER} icmp type echo-request counter accept
        iifname "vpn-in" icmp type echo-request accept
      }
      
      chain forward {
        type filter hook forward priority filter; policy drop;

        # 1. Allow return traffic for connections the containers started
        ct state established,related accept
        

        # 2. LAN to DOCKER EXEMPTION: Allow your local subnet to talk to your containers
        # This allows the rewritten forwarded packets to reach Docker safely.
        ip saddr 192.168.0.0/24 ip daddr 172.16.0.0/12 accept

        # 3. ALLOW CONTAINER -> WAN: Mark and accept outbound internet traffic
        # This keeps container networks isolated from each other (No Docker -> Docker)
        ip saddr 172.16.0.0/12 ip daddr != 172.16.0.0/12 meta mark set 0x1 accept
      }
      
      chain output {
        type route hook output priority mangle; policy accept;
      
        # 1. Allow the host to talk to itself safely
        oifname "lo" accept

        # 2. Exempt local subnet traffic
        ip daddr 192.168.0.0/24 accept
        oifname "vpn-in" counter accept

        # 4. Exempt WireGuard's tunnel traffic (prevent loop)
        udp dport 9929 accept
        udp dport 9930 counter accept
        udp sport 9930 counter accept
        tcp dport 80 accept
        
        # Accept traffic from the VPN server IP to your client IP on a specific source port over TCP/UDP
        ip saddr ${config.sops.placeholder.WIREGUARD_VPN_IN_CLIENT} udp sport 9930 counter accept
        ip daddr ${config.sops.placeholder.WIREGUARD_VPN_IN_SERVER} udp dport 9930 accept

        #oifname "docker0" accept
        #oifname "br-*" accept
        ip saddr 172.17.0.0/16 accept # Default Docker subnet range
        # 5. Mark everything else for Table 100
        meta mark set 0x1
      }

      # FIX: Changed priority from 'filter' to 'srcnat'
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        # Mask the host IP with the VPN IP when traversing the tunnel
        meta mark 0x1 masquerade
        oifname "vpn-out" masquerade
      }
    }
  '';
  reloadUnits = [ "nftables.service" ];
  };
    
  networking.nftables = {
    enable = true;
    rulesetFile = config.sops.templates."nftables-rules".path;
    checkRuleset = false;
  };
  
}
