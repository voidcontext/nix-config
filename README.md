# nix-config

Darwin:

```
$ nix build .#darwinConfigurations.$HOST.system && ./result/sw/bin/darwin-rebuild switch --flake .
```

Linux:

```
$ sudo nixos-rebuild switch --flake '/opt/nix-config#$HOST'
```
