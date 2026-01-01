{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
  ];

  # 注意：这是必须要有的基本信息
  home.username = "maorila";
  home.homeDirectory = "/home/maorila";

  # 必须和系统版本一致
  home.stateVersion = "25.11";

  # === 你的个人软件 ===
  home.packages = with pkgs; [
    fastfetch
    btop
    # 以后你想装 QQ、网易云、Spotify 都在这里加
    # === 代理工具 ===
    clash-verge-rev  # 现代化的 Clash GUI 客户端
    mihomo           # 强大的代理内核 (原 Clash Meta)
  ];

  # === 你的 Git 配置 ===
  programs.git = {
    enable = true;
    userName = "maorila";
    userEmail = "maorila@qq.com";
  };

  # === 你的 Bash 配置 ===
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch";
      ll = "ls -l";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      ms-python.python
      ms-vscode-remote.remote-ssh
    ];

    userSettings = {
      "editor.fontSize" = 16;
      "editor.fontFamily" = "'Fira Code','Droid Sans Mono','monospace'";
      "nix.enableLanguageServer" = true;
      "files.autoSave" = "onFocusChange";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;

  services.mihomo = {
    enable = true;
    
    # 自动下载并配置 Web 控制面板
    webui = pkgs.metacubexd; 

    # 这里就是你的核心配置，完全声明式！
    config = {
      mode = "rule";
      log-level = "info";
      allow-lan = true;
      external-controller = "127.0.0.1:9090";
      
      # 开启 Tun 模式 (自动接管系统流量)
      tun = {
        enable = true;
        stack = "system";
        auto-route = true;
        auto-detect-interface = true;
      };

      # 订阅管理 (这里用 providers 的方式)
      proxy-providers = {
        "MyAirport" = {
          type = "http";
          url = "https://sub-1.smjcdh.top/smjc/api/v1/client/subscribe?token=c7622162d2d8cbddca1c490493cbf7cb";
          interval = 3600;
          path = "./proxy-providers/airport.yaml";
          health-check = {
            enable = true;
            interval = 600;
            url = "http://www.gstatic.com/generate_204";
          };
        };
      };
    };
  };
}

