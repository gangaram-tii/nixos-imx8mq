# SPDX-License-Identifier: Apache-2.0
{
  inputs,
  lib,
  ...
}: {
  flake = with inputs; (
    import ./imx8mq-evk {
      inherit lib ghaf nixpkgs nixos-hardware;
    }
  );
}
