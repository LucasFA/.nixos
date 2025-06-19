{ ... }:
{
  services.upower = {
    enable = true;
    percentageCritical = 15;
    percentageAction = 10;
    criticalPowerAction = "PowerOff";
  };
}
