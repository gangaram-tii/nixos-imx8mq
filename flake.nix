# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "mesh-communicator - Ghaf based configuration";

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.vedenemo.dev"
      "https://cache.ssrcdevops.tii.ae"
    ];
    extra-trusted-public-keys = [
      "cache.vedenemo.dev:8NhplARANhClUSWJyLVk4WMyy1Wb4rhmWW2u8AejH9E="
      "cache.ssrcdevops.tii.ae:oOrzj9iCppf+me5/3sN/BxEkp5SaFkHfKTPPZ97xXQk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:gangaram-tii/nixos-hardware/pr/imx8mp-evk-platform";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ghaf = {
      url = "github:tiiuae/ghaf";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        nixos-hardware.follows = "nixos-hardware";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs = inputs @ {
    flake-parts,
    ghaf,
    ...
  }:
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {
        inherit (ghaf) lib;
      };
    } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./targets
      ];
    };
}

