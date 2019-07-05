{ pkgs
, ...
}:

{
  programs = {
    bash = {
      enableCompletion = true; # auto-completion in bash
      interactiveShellInit = ''
        export HISTCONTROL=ignorespace;
      '';
    };
    # wireshark.enable = true;
    # wireshark.package = pkgs.wireshark-gtk;
    ssh = {
      startAgent = true;        # don't type in a password on every SSH connection that is made
      # agentTimeout = "96h";     # TODO: How long should we set this?
      # extraConfig =
      #   ''
      #   AddKeysToAgent yes

      #   Host access-point-1
      #     HostName 192.168.0.23
      #     Port 22
      #     User root
      #     IdentitiesOnly yes
      #     IdentityFile /home/me/.ssh/id_accesspoint
      #   '';

        # [ {
        #     hostNames = [ "myhost" "myhost.mydomain.com" "10.10.1.4" ];
        #     publicKeyFile = ./pubkeys/myhost_ssh_host_dsa_key.pub;
        #   }
        #   {
        #     hostNames = [ "myhost2" ];
        #     publicKeyFile = ./pubkeys/myhost2_ssh_host_dsa_key.pub;
        #   }
        # ]
      # knownHosts = [ {
      #     hostNames = [ "access-point-1" "access-point-1.home-network" "192.168.0.23" "192.168.100.135" ];
      #     publicKeyFile = /home/me/.ssh/id_accesspoint.pub;
      #   } ];
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
