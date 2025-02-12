{ ... }:
{
  services.upower = {
    enable = true;
    percentageCritical = 10;
    percentageAction = 8;
    criticalPowerAction = "PowerOff";
  };
}
