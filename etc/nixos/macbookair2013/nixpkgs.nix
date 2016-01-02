{ pkgs
, ...
}:

{
  nixpkgs = {
    config = {
      chromium = {
        enablePepperFlash = true;
        enablePepperPDF = true;
        enableWideVine = true;     # needed for e.g. Netflix (DRM video)
      };
    };
  };
}
