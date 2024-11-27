{ config, home-manager, lib, pkgs, ... }:

let
  students = import ../../bits/student_list.nix;
  public_keys = import ../../secrets/aws_public.nix;
  studentAgeSecrets = lib.mkMerge (map (studentName: {
    "${studentName}_ssh_key" = {
      file = ../../secrets/markus/aws/${studentName};
      owner = "${studentName}";
    };
  }) students);
  homeManagerStudentUsers = lib.mkMerge (map (studentName: {
    "${studentName}" = { config, pkgs, ... }: {
      home.stateVersion = "24.05";
      home.file.".ssh/id".source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/${studentName}_ssh_key";
      home.file.".ssh/id.pub".text = public_keys.${studentName};
    };
  }) students);
  studentUsers = lib.mkMerge (map (studentName: {
    "${studentName}" = {
      isNormalUser = true;
      extraGroups = [ "keys" ];
      openssh.authorizedKeys.keys = [
        public_keys.${studentName}
      ];
    };
  }) students);
in
{
  config = {
    age.secrets = studentAgeSecrets;
    home-manager.users = homeManagerStudentUsers;
    users.users = studentUsers;
    systemd.user.slices = {
      "user.slice" = {
        enable = true;
        sliceConfig = {
          MemoryMax = "2G";
        };
      };
    };
    boot.kernel.sysctl = {
      "vm.oom_kill_allocating_task" = "1";
      "kernel.memory_failure_early_kill" = "1";
    };

    environment.systemPackages = with pkgs; [
      git
      htop
      vim
      screen
      haskellPackages.cabal-install
      haskell-language-server
      ghc
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    services.vscode-server.enable = true;
    services.openssh.knownHosts.bu-ki = {
      hostNames = [ "bu-ki.at" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSmez8ptgD4v7A1rMLs+UQNP+Ks4NOphM2UgwpbZfQp";
    };
    services.autossh.sessions = [
      {
        name = "reverse-proxy";
        user = "root";
        extraArguments = "-i /etc/ssh/ssh_host_ed25519_key -N -R 0.0.0.0:2222:localhost:22 root@bu-ki.at";
      }
    ];
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}
