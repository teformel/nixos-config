{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, kdePackages
, qt6
}:

stdenv.mkDerivation rec {
  pname = "lingmoui";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmoui";
    rev = "main";
    # TODO: 由于无法预取，首次构建将报错并提示正确的 Hash。请将报错中 "got: sha256-xxx" 的值填入此处！
    hash = lib.fakeHash; 
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtwayland
    qt6.qt5compat
    kdePackages.kwindowsystem
  ];

  cmakeFlags = [
    "-DQT_QML_GENERATE_QMLLS_INI=OFF"
    "-DBUILD_TESTING=OFF"
  ];
}
