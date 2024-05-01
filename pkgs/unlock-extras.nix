{pkgs, ...}:
pkgs.writeShellApplication {
  name = "unlock-extras";
  runtimeInputs = [pkgs.unstable.jujutsu];
  text = ''
    jj new
    jj desc -m "!DANGER! Exposed secrets!"
    cp -r ../nix-config-extras/default.nix extras/
    cp -r ../nix-config-extras/secrets.nix extras/
    cp -r ../nix-config-extras/hosts extras/
    touch .__DANGER__
    jj new
  '';
}
