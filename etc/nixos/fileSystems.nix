{
  ...
}:

{
  /* # A tmpfs file system comes in handy if you don't want files to touch */
  /* # your hard drive at all. */
  /* fileSystems."/tmp/ram" = */ 
  /*   { */
  /*     device = "tmpfs"; */
  /*     fsType = "tmpfs"; */
  /*     options = [ "size=5m" ]; */
  /*   }; */
}
