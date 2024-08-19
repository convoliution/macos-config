# Nix Journey

## `nix`

Using Determinate Systems's [Zero to Nix](https://zero-to-nix.com/start) guide.

### Installation

```zsh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### Commands

- `run $package` - download, install, and run a package
- `develop $environment` - download and activate a development environment
    - `--command`/`-c` - use the environment to run a command
- `search $flake $package`
    - https://search.nixos.org/
- `flake update` - update `flake.lock` inputs


## [`nix-darwin`](https://github.com/LnL7/nix-darwin)

System-level configuration management.

### [Installation](https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes)

```zsh
mkdir -p ~/.config/nix-darwin
cd ~/.config/nix-darwin
nix flake init -t nix-darwin
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
sed -i '' "s/x86_64-darwin/aarch64-darwin/" flake.nix
nix run nix-darwin -- switch --flake ~/.config/nix-darwin
```

### [Configuration](https://daiderd.com/nix-darwin/manual/index.html)

## [`home-manager`](https://github.com/nix-community/home-manager)

User-level configuration management

- a declarative alternative to the imperative `nix-env`

### [Installation](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone)

```zsh
nix run home-manager/master -- init --switch
```

### [Configuration](https://nix-community.github.io/home-manager/options.xhtml)

### Usage

1. Amend `~/.config/home-manager/home.nix`.
1. Run `home-manager switch` from anywhere.
