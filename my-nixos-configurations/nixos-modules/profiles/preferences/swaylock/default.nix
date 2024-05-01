{config, ...}: {
  programs.swaylock.settings = with config.colorScheme.palette; {
    # Color reference:`
    # https://github.com/tinted-theming/home?tab=readme-ov-file#unofficial-templates
    # https://git.michaelball.name/gid/base16-swaylock-template/tree/templates/default.mustache
    color = base00;

    bs-hl-color = base0F;

    caps-lock-bs-hl-color = base0F;
    caps-lock-key-hl-color = base0B;

    key-hl-color = base0B;

    inside-clear-color = base03;
    inside-ver-color = base03;
    inside-wrong-color = base08;

    ring-wrong-color = base08;
    ring-color = base0A;
    ring-caps-lock-color = base0A;
    ring-clear-color = base0C;
    ring-ver-color = base0D;

    text-clear-color = base0C;
    text-color = base05;
    text-caps-lock-color = base05;
    text-ver-color = base05;
    text-wrong-color = base05;
  };
}
