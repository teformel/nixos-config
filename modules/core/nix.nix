{ config, pkgs, ... }:

{
  nix.settings = {
    # 开启 Flakes 特性
    experimental-features = [ "nix-command" "flakes" ];

    # 替换官方的缓存源，按优先级排列：
    # 1. SJTU (上海交大) 的镜像，目前 NixOS 社区反馈在国内速度极其稳定
    # 2. USTC (中科大) 镜像，作为备用
    # 3. 官方缓存源，作为兜底
    substituters = [
      "https://attic.xuyh0120.win/lantian" # CachyOS 内核专属的二进制缓存源
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # 清华源
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];

    # 添加镜像源的公钥，Nix 才会信任它们下载的二进制包
    trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # 必须添加此公钥，否则不信任该缓存
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # 允许 wheel 组的用户信任第三方缓存
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # 允许安装非自由软件
  nixpkgs.config.allowUnfree = true;

  # 🌟 启用 nh 工具 (Nix Helper)，提供更快的构建体验和自动清理
  programs.nh = {
    enable = true;
    # 开启 nh 自动清理定时任务
    clean = {
      enable = true;
      # 每周日凌晨自动清理
      dates = "weekly"; 
      # 传递给 nh clean 的垃圾回收参数
      extraArgs = "--keep 7d --keep-since 3d";
    };
    # 指定系统的 Flake 源路径，这样你可以在任何地方运行 nh os switch
    flake = "/home/maorila/nixos-config"; 
  };

  # 为保证全终端兼容，注入全局环境变量
  environment.variables.FLAKE = "/home/maorila/nixos-config";
}
