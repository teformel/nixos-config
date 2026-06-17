{
  perSystem = { pkgs, ... }: {
    # 使用 nixpkgs-fmt 作为默认格式化工具
    formatter = pkgs.nixpkgs-fmt;
  };
}
