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
    font-awesome          # 常用图标字体
    nerd-fonts.jetbrains-mono # 你的主力字体
    # 如果想显示更多怪奇图标，可以加上 material-design-icons
    material-design-icons
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
}

