# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ../../modules/desktop/lingmo.nix  # 挂载 Lingmo 桌面环境
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  virtualisation.vmware.guest.enable = true;

   # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "virtual-maorila"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # 开启 SSH 服务
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 系统语言与中文输入法支持 (Fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-rime
    ];
  };

  # 强制全局注入 Fcitx5 环境变量
  environment.sessionVariables = {
    GLFW_IM_MODULE = "ibus";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # ============================================================
  # COSMIC 桌面环境 (Wayland) - 取代原来的 LXQt (X11)
  # ============================================================
  services.xserver = {
    enable = true;  # 保持开启以支持 X11 应用回退

    # LXQt 已禁用 (2026-06-23)
    # desktopManager.lxqt.enable = true;

    displayManager.lightdm.enable = false;  # LightDM 关闭，由 COSMIC greeter 接管
  };

  # --- COSMIC Desktop (System76) ---
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # COSMIC 性能优化
  services.system76-scheduler.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_microhei
    wqy_zenhei
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # --- PipeWire (COSMIC 需要用于屏幕录制和音频) ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;  # PulseAudio 关闭，由 PipeWire 接管
  security.rtkit.enable = true;

  # 禁用 xserver 默认强塞的 Xterm 终端
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Define a user account.
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    initialPassword = "maorila";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtiujEFiq92tw/i73EO0ntvZfyhTkG19hwTpaQ7RMP5 maorila@Laptop-maorila"
    ];
  };
  users.mutableUsers = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    micro
    eza
    git
    bottom
  ];

  system.stateVersion = "26.05";
}
