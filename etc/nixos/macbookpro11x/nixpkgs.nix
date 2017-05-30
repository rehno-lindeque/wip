{
  ...
}:

{

  /* { pkgs, lib, platform }: */
  /* let */
  /*   kernelPatches = */
  /*     pkgs.callPackage ../../../../../pkgs/os-specific/linux/kernel/patches.nix { }; */

  /* in */
  /* pkgs.callPackage ../../../../../pkgs/os-specific/linux/kernel/linux-4.3.nix { */
  /*   kernelPatches = [ kernelPatches.bridge_stp_helper ] */
  /*     ++ lib.optionals ((platform.kernelArch or null) == "mips") */
  /*     [ kernelPatches.mips_fpureg_emu */
  /*       kernelPatches.mips_fpu_sigill */
  /*       kernelPatches.mips_ext3_n32 */
  /*     ]; */
  /*   extraConfig = '' */
  /*     DEBUG_INFO y */
  /*     IP_MULTIPLE_TABLES y */
  /*     IPV6_MULTIPLE_TABLES y */
  /*     LATENCYTOP y */
  /*     SCHEDSTATS y */
  /*   '' */


  /*   apple-gmux = */
  /*     { name = "apple-gmux"; */
  /*       patch = ./apple-gmux.patch; */
  /*     }; */

  nixpkgs = {};
}
