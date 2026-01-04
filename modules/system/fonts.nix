{ pkgs, ... }:

{
  # === 字体配置 ===
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      sarasa-gothic
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      font-awesome
      material-design-icons
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" "Source Han Sans SC" ];
        serif = [ "Noto Serif CJK SC" "Source Han Serif SC" ];
        monospace = [ "JetBrainsMono Nerd Font" "Sarasa Mono SC" "Noto Sans Mono CJK SC" ];
      };
    };
  };
}