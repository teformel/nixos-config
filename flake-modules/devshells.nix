{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-config-shell";
      
      packages = with pkgs; [
        git
        nixpkgs-fmt # 代码格式化
        nil         # Nix 语言服务器 (LSP)
      ];

      shellHook = ''
        echo "🚀 欢迎进入 NixOS 配置开发环境！"
        echo "💡 提示: 运行 'nix fmt' 即可格式化所有 Nix 文件。"
      '';
    };
  };
}
