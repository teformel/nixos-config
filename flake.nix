{
  description = "maorila NixOS Flake configuration";

  inputs = {
    # 🚀 Flake-parts 驱动引擎
    flake-parts.url = "github:hercules-ci/flake-parts";

    # 🌟 主力：切换为 unstable 分支
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 🌟 替补：保留 25.11 稳定版备用
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
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

    # 🌟 个人的 NUR 仓库
    my-nur = {
      url = "github:teformel/nur-packages"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    # CachyOS 优化内核
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    # 🌟 新增：LingmoOS Nix Edition 测试源
    # 注意：该源仍在“Rebuilding”状态
    lingmo-nix.url = "github:LingmoOS-Testing/lingmo-nix";
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
