{config, ...}: {
  environment.systemPackages = [
    config.services.samba.package
  ];

  users.users = {
    # Additional user example
    # foobar = {
    #   isSystemUser = true;
    #   group = "foobar";
    #   extraGroups = [ "geeksnest" ];
    # };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    # extraConfig = ''
    #   workgroup = WORKGROUP
    #   map to guest = Never

    #   log level = 1
    # '';
    shares = {
      gabor = {
        path = "/Volumes/raid/gabor";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "valid users" = "vdx";
      };
      geeksnest = {
        path = "/Volumes/raid/geeksnest";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "valid users" = "vdx";
      };
    };
  };
}
