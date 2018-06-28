{
  ...
}:

{
  powerManagement =
    {
      enable = true;

      # Advice given by powertop: Enable SATA link power management for host0;echo 'min_power' > '/sys/class/scsi_host/host0/link_power_management_policy';
      # * However, this is cannot be used together with tlp.
      #   tlp automatically switches between performance and min_power depending on whether we are connected to power or on battery.
      # scsiLinkPolicy = "min_power";

      # This must not be used with tlp, see CPU_SCALING_GOVERNOR_ON_AC, CPU_SCALING_GOVERNOR_ON_BAT
      # cpuFreqGovernor = _;
    };
}
