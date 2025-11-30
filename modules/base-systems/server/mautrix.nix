{
  lib,
  pkgs,
  config,
  ...
}:

let
 mautrix-signalGoolm = pkgs.mautrix-signal.override { withGoolm = true; };
in 
{
  services.mautrix-signal = {
    enable = true;
    package = mautrix-signalGoolm;
  };
  environment.systemPackages = with pkgs; [
    mautrix-signalGoolm
  ];

}
