// Env scrub: strips secrets from the environment passed to bash invocations.
// Replaces values with empty strings (rather than deleting keys) so apps that
// re-export the env after launching don't see stale values.
//
// Hook: shell.env

const ALLOWLIST = new Set([
  "PATH",
  "HOME",
  "USER",
  "LOGNAME",
  "SHELL",
  "TERM",
  "LANG",
  "LC_ALL",
  "LC_CTYPE",
  "LC_MESSAGES",
  "LC_COLLATE",
  "LC_NUMERIC",
  "LC_TIME",
  "LC_MONETARY",
  "LC_PAPER",
  "LC_NAME",
  "LC_ADDRESS",
  "LC_TELEPHONE",
  "LC_MEASUREMENT",
  "LC_IDENTIFICATION",
  "TZ",
  "PWD",
  "OLDPWD",
  "SHLVL",
  "_",
  "EDITOR",
  "VISUAL",
  "PAGER",
  "BROWSER",
  "XDG_CONFIG_HOME",
  "XDG_CACHE_HOME",
  "XDG_DATA_HOME",
  "XDG_STATE_HOME",
  "XDG_BIN_HOME",
  "XDG_RUNTIME_DIR",
  "TMPDIR",
  "DISPLAY",
  "WAYLAND_DISPLAY",
  "XDG_SESSION_TYPE",
  "XDG_CURRENT_DESKTOP",
  "XDG_SESSION_ID",
  "DBUS_SESSION_BUS_ADDRESS",
  "NODE_ENV",
  "NO_COLOR",
  "FORCE_COLOR",
  "CLICOLOR",
  "CLICOLOR_FORCE",
  "GIT_PAGER",
  "PAGER",
  "MANPAGER",
  "MANWIDTH",
  "LESS",
  "LS_COLORS",
  "LSCOLORS",
]);

const EXACT_DENY = new Set([
  "AWS_ACCESS_KEY_ID",
  "AWS_SECRET_ACCESS_KEY",
  "AWS_SESSION_TOKEN",
  "AWS_SECURITY_TOKEN",
  "AWS_PROFILE",
  "AWS_DEFAULT_REGION",
  "GOOGLE_APPLICATION_CREDENTIALS",
  "GCP_SERVICE_ACCOUNT_KEY",
  "AZURE_CLIENT_SECRET",
  "AZURE_TENANT_ID",
  "AZURE_CLIENT_ID",
  "GITHUB_TOKEN",
  "GH_TOKEN",
  "GITLAB_TOKEN",
  "NPM_TOKEN",
  "PYPI_TOKEN",
  "ANTHROPIC_API_KEY",
  "OPENAI_API_KEY",
  "GOOGLE_API_KEY",
  "HUGGINGFACE_TOKEN",
  "REPLICATE_API_TOKEN",
  "SSH_AUTH_SOCK",
  "GPG_AGENT_INFO",
  "GNUPGHOME",
  "KRB5CCNAME",
]);

const PATTERN_DENY = [
  /^AWS_.+/,
  /^AZURE_.+/,
  /^GCP_.+/,
  /^GOOGLE_.+_KEY$/,
  /^.*_API_KEY$/,
  /^.*_SECRET$/,
  /^.*_SECRET_KEY$/,
  /^.*_PRIVATE_KEY$/,
  /^.*_PASSWORD$/,
  /^.*_PASSWD$/,
  /^.*_TOKEN$/,
];

function shouldDeny(key) {
  if (ALLOWLIST.has(key)) return false;
  if (EXACT_DENY.has(key)) return true;
  return PATTERN_DENY.some((re) => re.test(key));
}

export const EnvScrub = async () => ({
  "shell.env": async (input, output) => {
    if (!output?.env || typeof output.env !== "object") return;
    for (const key of Object.keys(output.env)) {
      if (shouldDeny(key)) {
        output.env[key] = "";
      }
    }
  },
});
