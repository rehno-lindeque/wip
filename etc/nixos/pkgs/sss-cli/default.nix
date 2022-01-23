{ stdenv, fetchFromGitHub, rustPlatform }:

# https://github.com/dsprenkels/sss-cli --branch v0.1

rustPlatform.buildRustPackage rec {
  name = "sss-cli-${version}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "dsprenkels";
    repo = "sss-cli";
    rev = "v0.1";
    sha256 = "15bsg96mpkiyv6p9h6yahw2j0sm4j132iz5hp71c1x6qdjwbjb23";
  };

  cargoSha256 = "0i861lyb5a7r3gxg1bqj532pb0srskrbkxli4bcz1nah47rwil26";

  meta = with stdenv.lib; {
    description = "Command line program for secret-sharing strings";
    homepage = https://github.com/dsprenkels/sss-cli;
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}

