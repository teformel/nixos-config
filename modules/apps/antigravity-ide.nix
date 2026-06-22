{ config, pkgs, inputs, ... }:

{
  # 🌟 特殊软件：Antigravity IDE (带代理注入)
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "antigravity-ide";
      paths = [ inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide ];
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
