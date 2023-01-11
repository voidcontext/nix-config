# nix-config

To build or switch configurations on local macOS or nixos machines run the `rebuild` script
(available in the `devShell`). The script will delegate the command to `darwin-rebuild` or `nixos-
rebuild` to rebuild this flake, optionally forcing the given hostname.

```bash
$ rebuild [cmd] [host]
```

Deploy nixos systems remotely using [deploy-rs](https://github.com/serokell/deploy-rs)

```bash
deploy .[nixos host]
````