{ config, pkgs, ... }:

{
  # 定义用户账户
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    initialPassword = "maorila";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
  };
  
  # 允许使用 passwd 命令修改密码
  users.mutableUsers = true;
}
