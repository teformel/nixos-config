{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-quirks.nix
      ../../modules
    ];

  # 主机名定义
  networking.hostName = "Laptop-maorila";

  # 状态版本号，请勿随意更改
  system.stateVersion = "26.05";
}
