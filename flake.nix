{
  description = "Personal-use NixOS packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = args: import ./outputs.nix args;
}
