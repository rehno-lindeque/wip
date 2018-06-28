{
  ...
}:

{
  # A tmpfs file system comes in handy if you don't want files to touch
  # your hard drive at all.
  #
  # For example:
  #
  # $ mount | grep tmp.ram
  #   tmpfs on /tmp/ram type tmpfs (rw,relatime,size=5120k)
  # $ echo "test" > /tmp/ram/test
  # $ ls /tmp/ram
  #   test
  # $ systemctl restart tmp-ram.mount
  # $ ls /tmp/ram
  #   cat: /tmp/ram/test: No such file or directory

  fileSystems."/tmp/ram" =
    {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=5m" ];
    };
}
