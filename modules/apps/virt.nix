# modules/virt.nix
{ config, pkgs, inputs, ... }:

{
  # 开启 KVM / QEMU 满血虚拟化
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # 开启 TPM 2.0 模拟 (Win11 刚需)
      # 确保 virtiofsd 可用
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  # 关键：允许 USB 重定向
  virtualisation.spiceUSBRedirection.enable = true;
  # 启用 Virt-Manager 图形化管理工具
  # （使用 programs 模块启用，它会自动帮你处理 dconf 和 GTK 主题等依赖，不要只写在 systemPackages 里）
  programs.virt-manager.enable = true;

  # 将与 Windows 强相关的软件放到用户层
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      libnotify # 用于接收 Windows 的系统通知
      freerdp
      # 1. 恢复最纯净的官方 winapps（删掉之前的 overrideAttrs）
      inputs.winapps.packages.${pkgs.system}.winapps
      inputs.winapps.packages.${pkgs.system}.winapps-launcher
  
      #/audio-mode:2：不重定向音频（如果你不需要 Windows 发声），能省下不少带宽。
      #/compression-level:0：关闭压缩，让 CPU 负担降到最低，利用局域网的高带宽换取极低的响应延迟。
      #如果你觉得全屏太压抑，看不到 Linux 的状态栏（比如 Top Bar）导致没有安全感，可以把脚本里的 /f 换成 /workarea 和 /decorations
      #如果你希望 Linux 的快捷键永远优先级最高（即：我按 Mod + 1 永远是切工作区，而不是传给 Windows），我们可以在脚本里关掉强制抓取: -grab-keyboard
      #+grab-keyboard: 显式声明开启键盘抓取（有时默认是关闭或半开启的）。
      #/kbd:fn-key:0x5b: 这是一个冷门参数。0x5b 是 Windows 键的扫描码。这行命令是告诉 FreeRDP：“哪怕宿主机想拦，也请务必把这个键传给 Windows。”
      (pkgs.writeShellScriptBin "win11-full" ''
        export LIBVIRT_DEFAULT_URI="qemu:///system"
            
        # 清除 Wayland 强制环境变量，安稳走 XWayland
        unset GDK_BACKEND
        unset WLD_CHECK
        
        ${pkgs.freerdp}/bin/xfreerdp \
          /v:192.168.122.180 \
          /u:maorila \
          /p:maorila \
          /cert:ignore \
          /f \
          /bpp:32 \
          /gfx \
          /kbd:layout:0x00000804 \
          /network:lan \
          /scale-desktop:125 \
          /scale-device:140 \
          /clipboard \
          /audio-mode:0 \
          /sound:sys:pulse \
          /microphone:sys:pulse
      '')
    ];
  };
}
