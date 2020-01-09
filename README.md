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

## Mac specific

To install fira code font

```bash
$ brew tap homebrew/cask-fonts
$ brew cask install font-fira-code
```


## Troubleshooting

- hie doesn't work properly -> run `nix-shell -I ~ --command 'hpack && cabal configure'`
