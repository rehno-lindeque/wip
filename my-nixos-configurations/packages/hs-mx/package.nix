{ mkDerivation, aeson, async, base, bytestring, containers
, directory, filepath, lib, network, optparse-applicative
, posix-pty, process, stm, terminal-size, text, time, unix
}:
mkDerivation {
  pname = "hs-mx";
  version = "0.1.0.0";
  src = ./src;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson async base bytestring containers directory filepath network
    optparse-applicative posix-pty process stm terminal-size text time
    unix
  ];
  description = "Remote-first persistent session manager";
  license = lib.licenses.mit;
  mainProgram = "hs-mx";
}
