{ config, pkgs, ... }:

{
  # 🌟 启用 nix-ld 动态链接库兼容层
  programs.nix-ld = {
    enable = true;
    
    libraries = (with pkgs; [
      stdenv.cc.cc
      openssl
      libx11
      libxext
      libxcursor
      libxrandr
      libxi
    ]) 
    ++ (pkgs.steam.run.args.nativeBuildInputs or [])
    ++ (pkgs.steam.run.args.buildInputs or []);
  };
}
