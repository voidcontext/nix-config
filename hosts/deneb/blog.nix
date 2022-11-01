{ pkgs, blog, blog-beta, ... }:

{
  services.nginx.virtualHosts."gaborpihaj.com" = {
    forceSSL = true;
    enableACME = true;
    root = "${blog.defaultPackage."x86_64-linux"}";
  };
  
  services.nginx.virtualHosts."beta.gaborpihaj.com" = {
    forceSSL = true;
    enableACME = true;
    root = "${blog-beta.defaultPackage."x86_64-linux"}";
    basicAuthFile = "/opt/secrets/nginx/blog-beta.htpasswd";
  };
}
