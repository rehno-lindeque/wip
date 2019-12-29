{ stdenv, fetchFromGitHub
, wrapGAppsHook, makeWrapper, gettext
, python3Packages, gtk3, poppler_gi
, gnome3, gsettings-desktop-schemas, shared-mime-info,
}:

python3Packages.buildPythonApplication rec {
  name = "pdfshuffler-unstable-2017-02-26"; # no official release in 5 years

  src = fetchFromGitHub {
    owner = "logari81";
    repo = "pdfshuffler";
    rev = "53e6a95f228382eda347e391be68bffda7cfa8ce";
    sha256 = "1h1hsvbpvyifjczmylsxab9diqwyim8vl6q0gnm1f8vpi3w42wz8";
  };

  nativeBuildInputs = [ wrapGAppsHook gettext makeWrapper ];

  buildInputs = [
    gtk3 gsettings-desktop-schemas poppler_gi gnome3.adwaita-icon-theme
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    pycairo
    pypdf2
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  doCheck = false; # no tests

  meta = with stdenv.lib; {
    homepage = https://sourceforge.net/p/pdfshuffler/wiki/Home;
    description = "Merge or split pdf documents and rotate, crop and rearrange their pages";
    platforms = platforms.linux;
    maintainers = with maintainers; [ mic92 ];
    license = licenses.gpl3;
  };
}
