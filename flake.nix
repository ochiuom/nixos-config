{
  description = "ochinix-pc NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🔥 Disko (Declarative Disk Management)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  };

  outputs = inputs@{ self, nixpkgs, lanzaboote,  home-manager, disko, nixos-hardware, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.ochinix-pc = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # 🔥 Disko must come first
        disko.nixosModules.disko
        nixos-hardware.nixosModules.lenovo-thinkpad-t480s
        ./disko.nix
        ./hardware-configuration.nix
        ./configuration.nix

        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ochinix = import ./home.nix;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
