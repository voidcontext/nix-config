{ config, ... }:

{
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
    extraConfig = ''
      workgroup = WORKGROUP
      map to guest = Never

      log level = 1
      socket options = IPTOS_LOWDELAY TCP_NODELAY SO_RCVBUF=524288 SO_SNDBUF=524288
      read raw = yes
      write raw = yes
      max xmit = 65536
      dead time = 15

      #use sendfile = true
      aio read size = 16384
      aio write size = 16384

      #getwd cache = yes
      #write cache size = 262144
    '';
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
