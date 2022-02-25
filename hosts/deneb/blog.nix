{pkgs, blog-beta, ...}:

{
  services.nginx.virtualHosts."beta.gaborpihaj.com" = {
    forceSSL = true;
    enableACME = true;
    root = "${blog-beta.defaultPackage."x86_64-linux"}";
    basicAuthFile = "/opt/secrets/nginx/blog-beta.htpasswd";
  };
}
