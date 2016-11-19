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
    };
  };
} 
