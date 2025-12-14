{ inputs, ... }:
let
  inherit (inputs.neovim.packages."x86_64-linux") nvim;
in
{
  home.packages = [ nvim ];
}
