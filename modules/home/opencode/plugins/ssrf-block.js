// SSRF block: rejects webfetch URLs targeting localhost, private networks,
// cloud metadata endpoints, and other non-routable targets.
//
// Hook: tool.execute.before
// Effect: throws if the URL resolves to a denied target.

const DENIED_HOSTNAMES = new Set([
  "localhost",
  "ip6-localhost",
  "ip6-loopback",
  "metadata.google.internal",
  "metadata",
]);

const DENIED_HOSTNAME_SUFFIXES = [
  ".internal",
  ".local",
  ".localdomain",
  ".intranet",
  ".corp",
  ".lan",
];

const FILE_SCHEMES = new Set(["file", "gopher", "dict", "ftp", "ldap"]);

function isPrivateIPv4(ip) {
  const parts = ip.split(".").map(Number);
  if (parts.length !== 4 || parts.some((p) => Number.isNaN(p))) return false;
  const [a, b] = parts;
  if (a === 10) return true;
  if (a === 127) return true;
  if (a === 0) return true;
  if (a === 169 && b === 254) return true;
  if (a === 172 && b >= 16 && b <= 31) return true;
  if (a === 192 && b === 168) return true;
  if (a === 100 && b >= 64 && b <= 127) return true;
  if (a === 169 && b === 254) return true;
  if (a === 198 && (b === 18 || b === 19)) return true;
  if (a >= 224) return true;
  return false;
}

function isPrivateIPv6(ip) {
  const lower = ip.toLowerCase();
  if (lower === "::1" || lower === "::") return true;
  if (lower.startsWith("fc") || lower.startsWith("fd")) return true;
  if (lower.startsWith("fe8") || lower.startsWith("fe9") || lower.startsWith("fea") || lower.startsWith("feb")) return true;
  if (lower.startsWith("ff")) return true;
  return false;
}

function isDeniedHost(hostname) {
  const h = hostname.toLowerCase().replace(/\.$/, "");
  if (DENIED_HOSTNAMES.has(h)) return true;
  if (DENIED_HOSTNAME_SUFFIXES.some((s) => h.endsWith(s))) return true;
  if (/^\d+\.\d+\.\d+\.\d+$/.test(h) && isPrivateIPv4(h)) return true;
  if (h.includes(":") && isPrivateIPv6(h)) return true;
  return false;
}

export const SsrfBlock = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool !== "webfetch") return;

    const url = output?.args?.url;
    if (typeof url !== "string" || url.length === 0) return;

    let parsed;
    try {
      parsed = new URL(url);
    } catch {
      throw new Error(`[ssrf-block] refusing to fetch malformed URL: ${url}`);
    }

    if (FILE_SCHEMES.has(parsed.protocol.slice(0, -1))) {
      throw new Error(`[ssrf-block] refusing to fetch non-http(s) scheme: ${parsed.protocol}`);
    }

    if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
      throw new Error(`[ssrf-block] refusing to fetch non-http(s) scheme: ${parsed.protocol}`);
    }

    if (isDeniedHost(parsed.hostname)) {
      throw new Error(`[ssrf-block] refusing to fetch private/loopback host: ${parsed.hostname}`);
    }
  },
});
