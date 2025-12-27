{
  lib,
  config,
  ...
}:

{
  users.groups.mediacenter = {
    gid = 13000;
    members = [ "sftpgo" ];
  };

  services.sftpgo = {
    enable = true;
    group = "mediacenter";
    dataDir = "/mnt/WD_8tb/server/data/sftpgo";
    # extraReadWriteDirs = [ "/mnt/WD_8tb/server/data/syncthing" ];
    settings =
      let
        defaultOpts = {
          address = "localhost";
          port = 800;
        };
      in
      {
        ftpd.bindings = [
          {
            address = "localhost";
            port = 801;
          }
        ];
        httpd.bindings = [
          defaultOpts
        ];
      };
  };
}
