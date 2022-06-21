{
  writeScriptBin,
  wol,
}:
writeScriptBin "wakeup-desktop2022"
# eno1 device
"${wol}/bin/wol d8:5e:d3:83:ca:27"
