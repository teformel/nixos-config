{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "maorila";
        email = "maorila@qq.com";
      };
    };
  };
}