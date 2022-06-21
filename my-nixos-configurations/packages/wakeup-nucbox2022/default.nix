{
  writeScriptBin,
  wol,
}:
writeScriptBin "wakeup-nucbox2022"
# enp0s21f0u2u1 device
"${wol}/bin/wol 00:e0:4c:68:0f:e8"
