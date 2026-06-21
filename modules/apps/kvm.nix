{ config, pkgs, ... }:

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
  programs.virt-manager.enable = true;
}
