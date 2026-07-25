{
  writeScriptBin,
  wol,
}:
writeScriptBin "wakeup-desktop2022"
# eno1 device
''
  #! /bin/sh
  exec ${wol}/bin/wol --host 192.168.8.255 d8:5e:d3:83:ca:27
''
