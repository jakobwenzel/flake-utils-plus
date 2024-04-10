{ lib, config, inputs, ... }:

let
  inherit (lib) mkIf filterAttrs mapAttrsToList mapAttrs' mkOption types;
  mkFalseOption = description: mkOption {
    inherit description;
    default = false;
    example = true;
    type = types.bool;
  };

  flakes = filterAttrs (name: value: value ? outputs) inputs;

  nixRegistry = builtins.mapAttrs
    (name: v: { flake = v; })
    flakes;

  cfg = config.nix;
in
{
  options = {
    nix.generateRegistryFromInputs = mkFalseOption "Generate Nix registry from available inputs.";
  };

  config = {

    nix.registry =
      if cfg.generateRegistryFromInputs
      then nixRegistry
      else { self.flake = flakes.self; };
  };
}

