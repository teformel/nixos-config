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
    pkgs.google-chrome
    # 以后你想装 QQ、网易云、Spotify 都在这里加
  ];

  # === Google Chrome 插件配置 ===
  # 原理：在 ~/.config/google-chrome/policies/managed/ 下写入策略文件
  xdg.configFile."google-chrome/policies/managed/extension_policy.json".text = builtins.toJSON {
    ExtensionSettings = {
      # 1. Bitwarden
      "nngceckbapebfimnlniiiahkandclblb" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
      
      # 2. Raindrop.io
      "kdfieneakcjfaiglcfcgkidlkmljjgpl" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };

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

