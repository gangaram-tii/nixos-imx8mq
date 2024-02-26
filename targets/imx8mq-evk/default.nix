# SPDX-License-Identifier: Apache-2.0
#
# i.MX8M Quad Evaluation Kit
{
  lib,
  ghaf,
  nixpkgs,
  nixos-hardware,
}: let
  name = "imx8mq-evk";
  system = "aarch64-linux";
  imx8mq-evk = variant: extraModules: let
    hostConfiguration = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit lib;};
      modules =
        [
          nixos-hardware.nixosModules.nxp-imx8mq-evk

          ../../modules/hardware/imx8/imx8mq-sdimage.nix

          (ghaf + "/modules/host")
          (ghaf + "/overlays/cross-compilation")
          ({pkgs, ...}: {
            ghaf = {
              host.networking.enable = true;
              profiles = {
                applications.enable = false;
                graphics.enable = false;
                release.enable = variant == "release";
                debug.enable = variant == "debug";
              };
              development = {
                debug.tools.enable = variant == "debug";
                ssh.daemon.enable = true;
              };
              firewall.kernel-modules.enable = true;
              windows-launcher.enable = false;
            };
            nixpkgs.buildPlatform.system = "x86_64-linux";
            hardware.deviceTree.name = lib.mkForce "freescale/imx8mq-evk.dtb";
            boot.loader.grub.enable = lib.mkDefault false;
            boot.kernelParams = lib.mkForce ["root=/dev/mmcblk0p2"];
            boot.consoleLogLevel = lib.mkForce 4;
            boot.loader.generic-extlinux-compatible.enable = true;
          })
        ]
        ++ (import (ghaf + "/modules/module-list.nix"))
        ++ extraModules;
    };
  in {
    inherit hostConfiguration;
    name = "${name}-${variant}";
    package = hostConfiguration.config.system.build.sdImage;
  };
  debugModules = [];
  releaseModules = [];
  targets = [
    (imx8mq-evk "debug" debugModules)
    (imx8mq-evk "release" releaseModules)
  ];
in {
  nixosConfigurations =
    builtins.listToAttrs (map (t: lib.nameValuePair t.name t.hostConfiguration) targets);
  packages = {
    x86_64-linux =
      builtins.listToAttrs (map (t: lib.nameValuePair t.name t.package) targets);
  };
}
