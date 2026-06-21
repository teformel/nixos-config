{ config, pkgs, ... }: {
  # 开启 RPC 所需的防火墙端口
  networking.firewall.allowedTCPPorts = [ 6800 ];

  # 【用户层配置】
  home-manager.users.maorila = {
    programs.aria2 = {
      enable = true;
      settings = {
        dir = "${config.home-manager.users.maorila.home.homeDirectory}/Downloads";
        enable-rpc = true;
        rpc-listen-all = true;
        max-connection-per-server = 16;
        rpc-allow-origin-all = true;
        continue = true;
        split = 10;
        min-split-size = "10M";
        bt-tracker = "udp://tracker.opentrackr.org:1337/announce,udp://tracker.openbittorrent.com:6969/announce";
      };
    };
    
    systemd.user.services.aria2 = {
      Unit = {
        Description = "Aria2c download manager";
        After = [ "network.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=%h/.config/aria2/aria2.conf"; 
        Restart = "on-failure";
      };
    };
  };
}
