{
  ...
}:

{
  programs = {
    bash = {
      enableCompletion = true; # auto-completion in bash
      interactiveShellInit = ''
        export HISTCONTROL=ignorespace;
      '';
    };
    ssh = {
      startAgent = true;        # don't type in a password on every SSH connection that is made
      # agentTimeout = "96h";     # TODO: How long should we set this?
      extraConfig =
        ''
          AddKeysToAgent yes
        '';

        # [ {
        #     hostNames = [ "myhost" "myhost.mydomain.com" "10.10.1.4" ];
        #     publicKeyFile = ./pubkeys/myhost_ssh_host_dsa_key.pub;
        #   }
        #   {
        #     hostNames = [ "myhost2" ];
        #     publicKeyFile = ./pubkeys/myhost2_ssh_host_dsa_key.pub;
        #   }
        # ]
    };

    # TODO: 17.09
    # gnupg.agent = {
    #   enable = true;
    #   # enableSSHSupport = true; # TODO
    # };

    # TODO: 17.09
    # command-not-found = {
    #   enable = true;
    # };
  };
}
