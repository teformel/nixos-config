{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-python.python
        ms-vscode-remote.remote-ssh
      ];
      userSettings = {
        "editor.fontSize" = 16;
        "editor.fontFamily" = "'Fira Code','Droid Sans Mono','monospace'";
        "nix.enableLanguageServer" = true;
        "files.autoSave" = "onFocusChange";
      };
    };
  };
}