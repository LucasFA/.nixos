{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.shellcheck.enable = true;
  # Enable the terraform formatter
  #programs.terraform.enable = true;
  # Override the default package
  #programs.terraform.package = pkgs.terraform_1;
  # Override the default settings generated by the above option
  #settings.formatter.terraform.excludes = [ "hello.tf" ];
}
