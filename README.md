# nix-config

## Basics

To update arbitrary host run

```bash
$ bin/hm-switch.sh
```

To update work laptop run

```bash
$ HM_HOST=work bin/hm-switch.sh
```

## Troubleshooting

- hie doesn't work properly -> run `nix-shell -I ~ --command 'hpack && cabal configure'`
