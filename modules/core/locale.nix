{ config, pkgs, ... }:

{
  # 🌐 系统语言与本地化 (i18n)
  i18n.defaultLocale = "zh_CN.UTF-8";
  # 确保系统编译了所有需要的本地化支持库
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  # 精细化时间、货币、纸张等格式为中国标准
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
    LC_MESSAGES = "zh_CN.UTF-8";
  };
}
