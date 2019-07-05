{ lib, linux_5_0, buildLinux, fetchFromGitHub, ... } @args:

linux_5_0.override (old: args // {
  buildLinux = a: buildLinux (a // rec {
    version = "${modDirVersion}";
    modDirVersion = "5.1.0"; # -rc4

    src = builtins.fetchurl {
      url = https://github.com/torvalds/linux/archive/v5.1-rc4.tar.gz;
      sha256 = "1cqr80b3jfr4g48fpni0pj2p5zs9930q6k6m9xjjdnsrhax1isr6";
    };
    # src = fetchFromGitHub {
    #   owner = "trovalds";
    #   repo = "linux";
    #   # rev = "15ade5d2e7775667cf191cf2f94327a4889f8b9d";
    #   rev = "v5.1-rc4";
    #   sha256 = "1cqr80b3jfr4g48fpni0pj2p5zs9930q6k6m9xjjdnsrhax1isr6";
    #   # https://github.com/torvalds/linux/archive/v5.1-rc4.tar.gz
    #   # https://github.com/trovalds/linux/archive/v5.1-rc4.tar.gz
    # };
  });
})
