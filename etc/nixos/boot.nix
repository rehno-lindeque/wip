{
  ...
}:

{
  boot = {
    /* initrd = { */
    /*   kernelModules = */
    /*    [ */
    /*      # "evdev"    # TEMPORARY: Is this necessary for actkbd to work properly? */
    /*                   # TODO: Doesn't appear to be necessary... */
    /*    ]; */
    /* }; */
    # Start a root shell if something goes wrong during stage 1 of the boot process (there is no authentiatcation for the root shell)
    kernelParams = [ "boot.shell_on_fail" ];

    # Don't hold onto /tmp
    cleanTmpDir = true;
  };
}

