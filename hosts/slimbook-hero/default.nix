{
  pkgs,
  ...
}:

{
  imports = [
    ../form-factor/laptop
    ./hardware
    ./software
  ];
}
