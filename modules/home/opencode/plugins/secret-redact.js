// Secret redact: scans tool output for common secret patterns and replaces
// them with [REDACTED]. Runs on tool.execute.after for read/bash/grep/glob.
//
// Hook: tool.execute.after
// Effect: mutates output.output (string) in place.

const MIN_OUTPUT_LENGTH = 50;

const PATTERNS = [
  { name: "aws-access-key", re: /\bAKIA[0-9A-Z]{16}\b/g },
  { name: "github-pat", re: /\bgh[pousr]_[A-Za-z0-9]{36,}\b/g },
  { name: "github-fine-grained", re: /\bgithub_pat_[A-Za-z0-9_]{22,}\b/g },
  { name: "gitlab-pat", re: /\bglpat-[A-Za-z0-9_\-]{20,}\b/g },
  { name: "openai-key", re: /\bsk-(?:proj-)?[A-Za-z0-9_\-]{20,}\b/g },
  { name: "anthropic-key", re: /\bsk-ant-[A-Za-z0-9_\-]{20,}\b/g },
  { name: "slack-token", re: /\bxox[abprs]-[A-Za-z0-9\-]{10,}\b/g },
  { name: "npm-token", re: /\bnpm_[A-Za-z0-9]{36}\b/g },
  { name: "jwt", re: /\beyJ[A-Za-z0-9_\-]{10,}\.eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\b/g },
  {
    name: "pem-block",
    re: /-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]+?-----END [A-Z ]*PRIVATE KEY-----/g,
  },
  {
    name: "bearer-header",
    re: /(Bearer\s+)[A-Za-z0-9_\-\.=]{20,}/g,
    replace: "$1[REDACTED]",
  },
  {
    name: "basic-auth-url",
    re: /:\/\/[A-Za-z0-9_\-]{1,40}:[A-Za-z0-9_\-]{1,80}@/g,
    replace: "://[REDACTED]:[REDACTED]@",
  },
];

function redact(text) {
  let result = text;
  for (const { re, replace } of PATTERNS) {
    result = result.replace(re, replace ?? "[REDACTED]");
  }
  return result;
}

const TARGET_TOOLS = new Set(["bash", "read", "grep", "glob", "webfetch"]);

export const SecretRedact = async () => ({
  "tool.execute.after": async (input, output) => {
    if (!TARGET_TOOLS.has(input.tool)) return;
    if (typeof output?.output !== "string") return;
    if (output.output.length < MIN_OUTPUT_LENGTH) return;

    const redacted = redact(output.output);
    if (redacted !== output.output) {
      output.output = redacted;
    }
  },
});
