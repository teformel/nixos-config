{ config, pkgs, inputs, ... }:

{
  imports = [
    # ./apps/steam.nix
    # ./apps/libvirt.nix
    ./apps/clash.nix
    ./apps/git.nix
    ./apps/direnv.nix
    # ./apps/antigravity-ide.nix
    # ./apps/winapps.nix
  ];

  # ====================================================
  # 应用软件大一统清单 (Apps)
  # 以后你想加什么软件，直接往这下面的列表里敲名字就行！
  # 需要特殊配置的软件，请去 modules/apps/ 目录下新建模块。
  # ====================================================

  # --- 1. 系统级软件包 (所有用户可用，开机即存在) ---
  environment.systemPackages = with pkgs; [
    # 基础命令行工具
    wget
    curl
    git
    micro
    vim
    neovim
    p7zip
    eza
    bottom
    fastfetch
    yazi
    bash
    
    # 系统与硬件工具
    android-tools
    resources
    mission-center
    
    # 网络与媒体
    aria2
    cava
    musicfox
    
    # 其他通用软件
    file-roller
    localsend
  ];

  # --- 2. 基础系统权限与运行库 ---
  programs.fish.enable = true;
  programs.nix-ld.enable = true; # 允许运行非 Nix 编译的动态链接库程序
  
  # --- 3. 用户级软件包 (仅 maorila 可见) ---
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      # 办公、开发与日常
      google-chrome
      vscode
      ghostty
      obs-studio
      mark-shot

      # 自定义 NUR 软件
      (import inputs.nur { inherit pkgs; }).repos.teformel.ww-manager
    ];
  };
}
