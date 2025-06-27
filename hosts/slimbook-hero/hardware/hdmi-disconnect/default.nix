{
  pkgs,
  ...
}:

{
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.ddcutil ];
  # Turn on external monitor:
  # ddcutil setvcp D6 0x01
  # Turn off external monitor:
  # ddcutil setvcp D6 0x05
}
