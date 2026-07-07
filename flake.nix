{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.vim
          pkgs.helix
        ];

      users.users.klarka = {
        home = /Users/klarka;
        # extraGroups = [ "docker" ];
      };

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      # Run intel binaries as well
      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
      # Run linux binaries as well
      nix.linux-builder.enable = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # virtualisation.docker = {
      #   enable = true;
      # };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };

    homemanager = { pkgs, ... }: {
      # Dont change without reading!
      home.stateVersion = "25.11";

      # User packages
      home.packages = with pkgs; [
        devenv

        lf

        pandoc
        typst

        
      ];

      
    };

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Klara-MBA" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.klarka = homemanager;
        }
      ];
    };
  };
}
