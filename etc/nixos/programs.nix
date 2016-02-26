{
  ...
}:

{
  programs = {
    bash.enableCompletion = true; # auto-completion in bash
    ssh.startAgent = true;        # don't type in a password on every SSH connection that is made
    # ssh.agentTimeout = "96h";     # TODO: How long should we set this?
  };
}
