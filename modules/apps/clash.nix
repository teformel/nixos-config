{ config, pkgs, inputs, ... }:

let
  pname = "mihomo-party";
  version = "1.9.6";

  # 1. 从官方 GitHub 抓取 deb 实体包
  src = pkgs.fetchurl {
    url = "https://github.com/mihomo-party-org/clash-party/releases/download/v${version}/mihomo-party-linux-${version}-amd64.deb";
    sha256 = "9fc15417432eafa51dad21217f557c5c4b0292f814e76ffdc6a453a451f581ea";
  };

  # 2. 构造专属解包器与依赖修补
  mihomo-party-app = pkgs.stdenv.mkDerivation {
    inherit pname version src;

    # 解包依赖工具
    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.autoPatchelfHook
    ];

    # Electron 运行所必须的海量依赖
    buildInputs = with pkgs; [
      alsa-lib at-spi2-atk at-spi2-core cairo cups dbus expat glib gtk3
      libdrm libxkbcommon mesa nspr nss pango systemd xorg.libX11
      xorg.libXcomposite xorg.libXdamage xorg.libXext xorg.libXfixes
      xorg.libXrandr xorg.libxcb
    ];

    unpackPhase = "dpkg -x $src .";

    installPhase = ''
      mkdir -p $out/bin $out/opt
      cp -r opt/Mihomo\ Party $out/opt/
      cp -r usr/share $out/share

      # 链接启动文件
      ln -s "$out/opt/Mihomo Party/mihomo-party" $out/bin/mihomo-party

      # 修正桌面图标路径
      substituteInPlace $out/share/applications/mihomo-party.desktop \
        --replace "/opt/Mihomo Party/mihomo-party" "mihomo-party"
    '';
  };
in
{
  # 代理与网络特殊配置 (Clash Party TUN 模式防火墙放行)
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # 代理软件的 TUN 模式必须
    trustedInterfaces = [ "Mihomo" "mihomo" "Meta" ];
  };

  # 将软件安装也聚合于此，实现“装配一体”
  home-manager.users.maorila = {
    home.packages = [
      pkgs.clash-verge-rev      # 官方源的 Clash Verge Rev
      mihomo-party-app          # 刚手搓出炉的 Mihomo Party
    ];
  };
}
