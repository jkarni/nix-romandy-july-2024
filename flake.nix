{
  description = "A template that shows all standard flake outputs";

  # The master branch of the NixOS/nixpkgs repository on GitHub.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  inputs.c-hello.url = "github:NixOS/templates?dir=c-hello";
  inputs.c-hello.inputs.nixpkgs.follows= "nixpkgs";
  inputs.rust-web-server.url = "github:NixOS/templates?dir=rust-web-server";
  inputs.rust-web-server.inputs.nixpkgs.follows= "nixpkgs";
  inputs.nix-bundle.url = "github:NixOS/bundlers";
  inputs.nix-bundle.inputs.nixpkgs.follows= "nixpkgs";

  # Work-in-progress: refer to parent/sibling flakes in the same repository
  # inputs.c-hello.url = "path:../c-hello";

  outputs = all@{ self, c-hello, rust-web-server, nixpkgs, nix-bundle, ... }: {

    # Utilized by `nix flake check`
    checks.x86_64-linux.test = c-hello.checks.x86_64-linux.test;

    # Utilized by `nix build .`
    defaultPackage.x86_64-linux = c-hello.defaultPackage.x86_64-linux;

    # Utilized by `nix build`
    packages.x86_64-linux.hello = c-hello.packages.x86_64-linux.hello;

    # Utilized by `nix run .#<name>`
    apps.x86_64-linux.hello = {
      type = "app";
      program = c-hello.packages.x86_64-linux.hello;
    };

    # Utilized by `nix bundle -- .#<name>` (should be a .drv input, not program path?)
    bundlers.x86_64-linux.example = nix-bundle.bundlers.x86_64-linux.toArx;

    # Utilized by `nix bundle -- .#<name>`
    defaultBundler.x86_64-linux = self.bundlers.x86_64-linux.example;

    # Utilized by `nix run . -- <args?>`
    defaultApp.x86_64-linux = self.apps.x86_64-linux.hello;

    # Utilized for nixpkgs packages, also utilized by `nix build .#<name>`
    legacyPackages.x86_64-linux.hello = c-hello.defaultPackage.x86_64-linux;

    # Default overlay, for use in dependent flakes
    overlay = final: prev: { };

    # # Same idea as overlay but a list or attrset of them.
    overlays = { exampleOverlay = self.overlay; };

    # Default module, for use in dependent flakes. Deprecated, use nixosModules.default instead.
    nixosModule = { config, ... }: { options = {}; config = {}; };

    # Same idea as nixosModule but a list or attrset of them.
    nixosModules = { exampleModule = self.nixosModule; };

    # Used with `nixos-rebuild --flake .#<hostname>`
    # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ ... } : {
          users.users.jkarni = {
            description = "Julian K. Arni";
            isNormalUser = true;
            openssh.authorizedKeys.keys = [
             "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVpNqdbM7uE1xkKoXztoaAtKtDHoqHS3DrzxYKsDgxa jkarni@garnix.io"
            ];
          };
          services.openssh.enable = true;
          fileSystems."/" = {
            device = "/dev/sda1";
            fsType = "ext4";
          };
          boot.loader.grub.device = "/dev/sda";
         })
      ] ;
    };

    # Utilized by Hydra build jobs
    hydraJobs.example.x86_64-linux = self.defaultPackage.x86_64-linux;

    # Utilized by `nix flake init -t <flake>`
    defaultTemplate = {
      path = c-hello;
      description = "template description";
    };

    # Utilized by `nix flake init -t <flake>#<name>`
    templates.example = self.defaultTemplate;
  };
}
