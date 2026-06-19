# modules/desktop/antigravity.nix
{ config, pkgs, lib, inputs, ... }:

let
  antigravity-base = inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide;
in
{
  # 2. 塞入系统包，顺手织入代理环境
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "antigravity-ide";
      # name = "antigravity-default";
      paths = [ antigravity-base ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/antigravity-ide \
          --set HTTP_PROXY "http://127.0.0.1:7890" \
          --set HTTPS_PROXY "http://127.0.0.1:7890" \
          --set ALL_PROXY "socks5://127.0.0.1:7890" \
          --set NO_PROXY "localhost,127.0.0.1,::1"
      '';
    })
  ];
}
