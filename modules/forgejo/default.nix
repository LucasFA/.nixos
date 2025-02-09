{
  ...
}:
{
  services.forgejo = {
    enable = true;
    stateDir = "/mnt/WD_8tb/server/data/forgejo";
    useWizard = false;
    settings = {
      server.DOMAIN = "git.lucasfa.com";
      session.COOKIE_SECURE = true;
    };
  };
}
