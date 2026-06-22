{
  description = "maorila NixOS Flake configuration";

  inputs = {
    # 🚀 Flake-parts 驱动引擎
    flake-parts.url = "github:hercules-ci/flake-parts";

    # 🌟 主力：切换回当前的 26.05 稳定版（修改这里）
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 🌟 替补：让原先的 unstable 降级为备用
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager：显式让其对齐 26.05 分支
    home-manager = {
      url = "github:nix-community/home-manager/master"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Disko 硬盘分区工具
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Noctalia 混成器/组件
    noctalia.url = "github:noctalia-dev/noctalia-shell";

    # WinApps
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🌟 官方 NUR (Nix User Repository) 收录源
    nur.url = "github:nix-community/NUR";

    # 私人 NUR 包 (Lingmo OS 等)
    my-nur.url = "github:teformel/nur-packages";

    # CachyOS 优化内核
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    # 🌟 新增：LingmoOS Nix Edition 测试源
    # 注意：该源仍在“Rebuilding”状态
    lingmo-nix.url = "github:LingmoOS-Testing/lingmo-nix";
    
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 架构大转移：使用 flake-parts 并将所有逻辑移入 flake-modules 中
  outputs = inputs@{ flake-parts, ... }: 
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # 导入所有的子 flake 模块
      imports = [
        ./flake-modules/nixos.nix      # 主机组装逻辑
        ./flake-modules/formatter.nix  # 全局格式化工具
        ./flake-modules/devshells.nix  # 开发环境
      ];
    };
}
