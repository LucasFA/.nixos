{
  lib,
  config,
  ...
}:

{
  services.n8n = {
    enable = true;
    openFirewall = false;
    webhookUrl = "https://n8n.lucasfa.com/";
  };
}
