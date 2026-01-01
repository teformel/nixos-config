{
  description = "Maorila's NixOS Flake Configuration";

  # === 输入：这里定义了你的软件源 ===
  inputs = {
    # NixOS 官方软件源 (Unstable 分支，对应你之前的 25.11)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager 源
    home-manager = {
      url = "github:nix-community/home-manager";
      # 关键：强制 Home Manager 使用和系统一致的 nixpkgs 版本，避免版本冲突
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # === 输出：这里定义了你的系统配置 ===
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      
      # 注意：这里的名字必须和你的 hostname (maorila-laptop) 一致
      "maorila-laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        # 将 inputs 传递给所有模块，这样你在 configuration.nix 里也能用 inputs
        specialArgs = { inherit inputs; };

        modules = [
          # 导入你的系统配置
          ./configuration.nix

          # 导入 Home Manager 模块 (这就替代了之前那个 imports <...>)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            # 同样把 inputs 传给 home-manager
            home-manager.extraSpecialArgs = { inherit inputs; };
            
            # 这里告诉系统去哪里找用户的配置
            # 注意：configuration.nix 里那句 import ./home.nix 依然有效，
            # 但为了清晰，你也可以在这里直接指定（看你喜好，目前保持不动即可）
          }
        ];
      };
    };
  };
}
