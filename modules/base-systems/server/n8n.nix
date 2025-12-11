{
  lib,
  config,
  ...
}:

{
  services.n8n = {
    enable = true;
    openFirewall = false;
    environment.WEBHOOK_URL = "https://n8n.lucasfa.com/";
  };
  systemd.services.n8n.environment.N8N_LISTEN_ADDRESS = "127.0.0.1";
}
