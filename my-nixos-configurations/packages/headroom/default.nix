{
  headroom,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "headroom";
  text = ''
    set -euo pipefail

    export HEADROOM_TELEMETRY=off
    export HEADROOM_TELEMETRY_WARN=off
    export HEADROOM_NO_SUBSCRIPTION_TRACKING=true
    export HEADROOM_STATELESS=true
    export HEADROOM_LOG_MESSAGES=false
    export HEADROOM_DISABLE_KOMPRESS=1
    export HF_HUB_OFFLINE=1
    export HF_HUB_DISABLE_IMPLICIT_TOKEN=1
    export HF_HUB_DISABLE_PROGRESS_BARS=1

    unset HEADROOM_LICENSE_KEY

    export ANTHROPIC_TARGET_API_URL="''${ANTHROPIC_TARGET_API_URL:-https://api.anthropic.com}"
    export OPENAI_TARGET_API_URL="''${OPENAI_TARGET_API_URL:-https://api.openai.com}"

    exec ${lib.getExe' headroom "headroom"} proxy \
      --host 127.0.0.1 \
      --port "''${HEADROOM_PORT:-8787}" \
      --no-telemetry \
      --no-subscription-tracking \
      --stateless \
      "$@"
  '';
}
