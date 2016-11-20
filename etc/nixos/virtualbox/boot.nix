{
  ...
}:

{
  # Boot settings.
  boot = {
    initrd = {
      # Disable journaling check on boot because virtualbox doesn't need it
      checkJournalingFS = false;
      # TODO: not sure what these do and if necessary
      availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" ];
      kernelModules =
       [
         "fbcon"    # Make it pretty (support fonts in the terminal)
                    # modprobe: FATAL: Module fbcon not found in directory /nix/store/________________________________-kernel-modules/lib/modules/4.4.2
       ];
    };
  };
} 
