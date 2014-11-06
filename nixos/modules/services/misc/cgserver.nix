{ config, lib, pkgs, ... }:

with lib;

{

  options = {
    services.cgserver = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable cgserver.
        '';
      };

      cgroupRoot = mkOption {
        # XXX we cannot use types.path here, because it gets mangled to
        # /nix/store/AAA-cgroup
        type = types.string;
        default = "/sys/fs/cgroup";
        description = ''
          Mount point of the cgroup root.
        '';
      };

      httpPort = mkOption {
        type = types.int;
        default = 8001;
        description = ''
          TCP port number for cgserver to bind to.
        '';
      };

      cgserverPackage = mkOption {
        type = types.package;
        default = pkgs.haskellPackages.cgserver;
        description = ''
          Cgroup-server package to use.
        '';
      };

      user = mkOption {
        default = null;
        description = ''
          The user the cgserver should run as.
        '';
      };

      flushLog = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Flush log after each request.
        '';
      };


    };
  };


  config =
    let
      cfg = config.services.cgserver;
      User = if cfg.user != null then cfg.user else "cgserver";
    in
      mkIf cfg.enable {
        users.extraUsers = mkIf (cfg.user == null) [
          {
            uid = config.ids.uids.cgserver;
            name = "cgserver";
            group = "cgserver";
          }
        ];
        users.extraGroups = mkIf (cfg.user == null) [
          {
            gid = config.ids.gids.cgserver;
            name = "cgserver";
          }
        ];
        systemd.services.cgserver = {
          description = ''
            HTTP server that provides an API to manage cgroups
          '';
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          environment = {
            httpPort = toString cfg.httpPort;
            cgroupRoot = cfg.cgroupRoot;
            flushLog = if cfg.flushLog then "true" else "false";
          };
          serviceConfig = {
            ExecStart = "${cfg.cgserverPackage}/bin/cgserver";
            inherit User;
            SyslogIdentifier = "cgserver";
          };
          restartIfChanged = true;
        };
      };
}
