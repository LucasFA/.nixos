{
  lib,
  config,
  ...
}:

{
  services.n8n = {
    enable = true;
    webhookUrl = "https://n8n.lucasfa.com/";
  };
}
