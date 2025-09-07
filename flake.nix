{
  description = "Personal-use NixOS packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = args: import ./outputs.nix args;
}
