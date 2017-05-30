{
  pkgs
, ...
}:

# let
#     macbook-wakeup =
#       { name = "macbook-wakeup";
#         patch = "${pkgs.arch-linux-macbook.outPath}/macbook-wakeup.service";
#       };
# in
{
  powerManagement = 
    {
      # See macbook-wakeup
      powerDownCommands =
        ''
        awk '$1 !~ /^LID/ && $3 ~ /enabled/ {print $1}' /proc/acpi/wakeup | xargs -I{} echo '{}' > /proc/acpi/wakeup
        awk '$1 ~ /^LID/ && $3 ~ /disabled/ {print $1}' /proc/acpi/wakeup | xargs -I{} echo '{}' > /proc/acpi/wakeup
        '';
    };

  # services.acpid.lidEventCommands =

}
