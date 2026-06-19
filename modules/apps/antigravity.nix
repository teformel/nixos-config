# modules/desktop/antigravity.nix
{ config, pkgs, lib, ... }:

let
  # 1. 定义原版 Antigravity 的下载和包裹行为
  antigravity-app = pkgs.appimageTools.wrapType2 rec {
    pname = "antigravity";
    version = "3.0.0"; # 可以写你当前下载的版本号

    # 从你本地的绝对路径读取官方解压出来的二进制文件或 AppImage
    # 提示：你可以提前把官方包下载好，放到你的本地硬盘里
    src = /home/maorila/Downloads/Antigravity.AppImage; 

    # 如果官方给的是通用 tar.gz 压缩包而不是 AppImage，可以换成下面这种 FHS 环境包裹：
    # （这里先以最省心的 AppImage 包裹为例，它会自动处理动态链接库问题）
  };
in
{
  environment.systemPackages = [
    # 2. 将我们自己包裹好的专属包注入系统
    antigravity-app
  ];

  # 3. 完美照顾你的 Dendritic 树突多分支并发模式，为它单独穿上代理外衣
  # 这样既不会污染你整个 GNOME 系统的环境变量，又能保证 AI 智能体请求顺畅出海
  systemd.user.services.antigravity-proxy = {
    description = "Wrap Antigravity with dedicated proxy environment";
    # 如果你想通过 desktop 条目启动时直接带代理，也可以采用下面的 wrapper 方式：
  };

  # 强迫症专属：直接在系统层用 makeWrapper 强行给可执行文件塞入代理参数
  # 这样你在 GNOME 抽屉里双击图标启动时，智能体网络就是直接打通的
  nixpkgs.config.packageOverrides = pkgs: {
    antigravity = pkgs.symlinkJoin {
      name = "antigravity-proxied";
      paths = [ antigravity-app ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/antigravity \
          --set HTTP_PROXY "http://127.0.0.1:7890" \
          --set HTTPS_PROXY "http://127.0.0.1:7890" \
          --set ALL_PROXY "socks5://127.0.0.1:7890"
      '';
    };
  };
}
