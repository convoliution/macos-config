# new laptop setup

1. generate SSH key for laptop
   ```zsh
   ssh-keygen -t ed25519 -C "email@protonmail.com"
   ```
1. configure `ssh-agent` to manage key
   ```zsh
   cat > ~/.ssh/config<< EOF
   Host github.com
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_ed25519
   EOF
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```
1. add key to GitHub account at https://github.com/settings/keys
   ```zsh
   pbcopy < ~/.ssh/id_ed25519.pub
   ```
1. test connection
   ```zsh
   ssh -T git@github.com
   ```
1. [install Nix](https://zero-to-nix.com/start)
   ```zsh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
1. [install Home Manager](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone)
   ```zsh
   nix run home-manager/master -- init --switch
   ```
1. install Git (via Home Manager)
   ```zsh
   sed -i '' '4 i\
     programs.git.enable = true;\
   ' ~/.config/home-manager/home.nix
   home-manager switch
   ```
1. clone this repository
   ```zsh
   rm -r ~/.config
   git clone git@github.com:convoliution/macos-config.git ~/.config
   ```
1. apply configuration
   ```zsh
   rm ~/.ssh/config
   home-manager switch
   ```

# TODO

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

???
