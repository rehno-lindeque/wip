{
  config
, lib
, pkgs
, ...
}:

{
  # Use powertop to save battery
  # * Unfortunately this slows down startup time a lot, but it seems the best option for now
  systemd.services.power-tune = {
    description = "Power Management tunings";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.powertop}/bin/powertop --auto-tune
    '';
    serviceConfig.Type = "oneshot";
  };
}

# TODO: Automatic scaling? (see https://github.com/cstrahan/nixos-config)
# iw dev wlp3s0 set power_save on
# for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
#   echo powersave > $cpu
# done 
