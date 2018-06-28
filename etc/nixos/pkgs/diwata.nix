{ stdenv, fetchFromGitHub, rustPlatform, elmPackages, closurecompiler, gnused, rsync, makeWrapper }:

rustPlatform.buildRustPackage rec {
  name = "diwata-${version}";
  version = "0.1.0";

  buildInputs = [ elmPackages.elm closurecompiler gnused rsync makeWrapper ];

  src = fetchFromGitHub {
    owner = "ivanceras";
    repo = "diwata";
    rev = "c46dcebd52181378eaff21c14947fb6b779147f2";
    sha256 = "039mwvmdxly1jk4skigb6sn2wl39vq2qvbqjdrkkmilnk93w10gq";
    fetchSubmodules = true;
  };

  postInstall = ''
    mkdir -p $out/public
    substituteInPlace "webclient/compile.sh" \
        --replace "../public" "$out/public"
    substituteInPlace "webclient/compile_release.sh" \
        --replace "../public" "$out/public" \
        --replace "google-closure-compiler-js" "closure-compiler"
    cd webclient
    HOME=$out ELM_HOME=$out ./compile_release.sh
    wrapProgram $out/bin/diwata \
      --run "cd $out"
  '';

  cargoSha256 = "18zrj6fxn6pyllxrzkzy9qn1smbf6gwfyf8kdhr0389babkpaqcz";
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A user-friendly database interface";
    homepage = https://github.com/ivanceras/diwata;
    license = licenses.apache;
    maintainers = [];
    platforms = platforms.all;
  };
}
