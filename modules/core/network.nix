{ config, pkgs, ... }:

{
  # 启用网络管理器
  networking.networkmanager.enable = true;

  # 设置时区
  time.timeZone = "Asia/Shanghai";
  services.timesyncd.enable = true;

  # 启用 Chrony 守护进程
  services.chrony.enable = true;

  # 修改 NTP 服务器为国内常见的高速源
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp.tencent.com"
    "cn.pool.ntp.org"
  ];
}
