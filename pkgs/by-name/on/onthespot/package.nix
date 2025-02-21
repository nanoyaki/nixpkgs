{
  lib,
  copyDesktopItems,
  fetchFromGitHub,
  makeDesktopItem,
  python3,
  libsForQt5,
  ffmpeg,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "onthespot";
  version = "0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "casualsnek";
    repo = "onthespot";
    tag = "v${version}";
    hash = "sha256-VaJBNsT7uNOGY43GnzhUqDQNiPoFZcc2UaIfOKgkufg=";
  };

  pythonRemoveDeps = [
    "PyQt5-Qt5"
    "PyQt5-stubs"
    # Doesn't seem to be used in the sources and causes
    # build issues
    "PyOgg"
  ];

  pythonRelaxDeps = true;

  nativeBuildInputs = with python3.pkgs; [
    copyDesktopItems
    libsForQt5.wrapQtAppsHook
  ];

  dependencies = with python3.pkgs; [
    async-timeout
    charset-normalizer
    defusedxml
    ffmpeg
    librespot
    music-tag
    packaging
    pillow
    protobuf
    pyqt5
    pyqt5-sip
    pyxdg
    requests
    setuptools
    show-in-file-manager
    urllib3
    zeroconf
  ];

  postInstall = ''
    install -Dm444 $src/src/onthespot/resources/icon.png $out/share/icons/hicolor/256x256/apps/onthespot.png
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Onthespot";
      exec = "onthespot_gui";
      icon = "onthespot";
      desktopName = "Onthespot";
      comment = meta.description;
      categories = [ "Audio" ];
    })
  ];

  meta = {
    description = "QT based Spotify music downloader written in Python";
    homepage = "https://github.com/casualsnek/onthespot";
    changelog = "https://github.com/casualsnek/onthespot/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
    mainProgram = "onthespot_gui";
  };
}
