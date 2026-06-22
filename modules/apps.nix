{ config, pkgs, inputs, ... }:

{
  # ====================================================
  # 应用软件大一统配置 (Apps)
  # 以后你想加什么软件，直接往这下面的列表里敲名字就行！
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
    
    # 🌟 特殊软件：Antigravity IDE (带代理注入)
    # (pkgs.symlinkJoin {
    #   name = "antigravity-ide";
    #   paths = [ inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide ];
    #   buildInputs = [ pkgs.makeWrapper ];
    #   postBuild = ''
    #     wrapProgram $out/bin/antigravity-ide \
    #       --set HTTP_PROXY "http://127.0.0.1:7890" \
    #       --set HTTPS_PROXY "http://127.0.0.1:7890" \
    #       --set ALL_PROXY "socks5://127.0.0.1:7890" \
    #       --set NO_PROXY "localhost,127.0.0.1,::1"
    #   '';
    # })
  ];

  # --- 2. 需要特殊系统级权限开启的程序 ---
  programs.fish.enable = true;
  # 允许运行非 Nix 编译的动态链接库程序
  programs.nix-ld.enable = true;
  
  # 游戏环境支持
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  # 游戏辅助包
  environment.systemPackages = with pkgs; [ mangohud gamescope lutris protonplus ];

  # --- 3. 虚拟机支持 (KVM) ---
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ (pkgs.OVMF.override { secureBoot = true; tpmSupport = true; }).fd ];
      };
    };
  };

  # --- 4. 代理与网络特殊配置 (Clash Party) ---
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # 代理软件的 TUN 模式必须
    trustedInterfaces = [ "Mihomo" "mihomo" "Meta" ];
  };

  # --- 5. 用户级软件包 (仅当前用户可见) ---
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      # 办公、开发与日常
      google-chrome
      vscode
      ghostty
      obs-studio
      mark-shot

      # 代理软件 (Clash Party)
      (inputs.my-nur.packages.${pkgs.system}.clash-party or inputs.my-nur.packages.${pkgs.system}.mihomo-party)
      
      # 自定义 NUR 软件
      inputs.my-nur.packages.${pkgs.system}.ww-manager

      # WinApps 及其依赖
      # libnotify
      # freerdp
      # inputs.winapps.packages.${pkgs.system}.winapps
      # inputs.winapps.packages.${pkgs.system}.winapps-launcher
  
      # WinApps 专属 RDP 启动脚本
      # (pkgs.writeShellScriptBin "win11-full" ''
      #   export LIBVIRT_DEFAULT_URI="qemu:///system"
      #   unset GDK_BACKEND
      #   unset WLD_CHECK
      #   ${pkgs.freerdp}/bin/xfreerdp \
      #     /v:192.168.122.180 /u:maorila /p:maorila /cert:ignore /f \
      #     /bpp:32 /gfx /kbd:layout:0x00000804 /network:lan \
      #     /scale-desktop:125 /scale-device:140 /clipboard \
      #     /audio-mode:0 /sound:sys:pulse /microphone:sys:pulse
      # '')
    ];

    # Git 的基础配置
    programs.git = {
      enable = true;
    };

    # Direnv 环境隔离
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
