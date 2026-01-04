{ pkgs, lib, config, ... }:

let
  # 启动脚本
  antigravity-script = pkgs.writeShellScriptBin "antigravity" ''
    # 1. 确保配置目录存在且权限正确
    mkdir -p ~/.gemini/antigravity
    chmod -R 755 ~/.gemini

    # 2. 启动 FHS 版本
    # --password-store=basic: 既然 Keyring 有问题，我们继续坚持用文件存密码
    # --proxy-server: 指定代理
    # --proxy-bypass-list: 🌟 关键！告诉它不要代理本地回环流量
    # --ozone-platform=x11: 🌟 强制使用 X11 模式，防止 Wayland 下协议通信失败
    
    exec ${pkgs.antigravity-fhs}/bin/antigravity \
      --password-store=basic \
      --proxy-server="http://127.0.0.1:7897" \
      --proxy-bypass-list="<-loopback>" \
      --ozone-platform=x11 \
      "$@"
  '';

in
{
  home.packages = [ antigravity-script ];

  # 目录双保险
  home.activation.fixAntigravityConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p ${config.home.homeDirectory}/.gemini/antigravity
  '';
}