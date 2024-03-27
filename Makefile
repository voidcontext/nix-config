# CI fallback
ATTIC_TOKEN ?= ${PLUGIN_BINARY_CACHE_TOKEN}

drv_path = $(shell nix path-info .#cache-warmup)
paths_to_cache = $(shell nix-store --query --references ${drv_path})

check:
	nix flake check

build-cached:
	nix build .#cache-warmup

cache-warmup: build-cached
	attic login private https://cache.nix.vdx.hu ${ATTIC_TOKEN}
	attic push private:private ${paths_to_cache}

.PHONY: check build-cached cache-warmup

