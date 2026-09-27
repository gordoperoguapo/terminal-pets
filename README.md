# terminal-pets

A tiny pixel-art pet for your terminal. It greets you with a bounce and a blink when you open a new window, and it can bob around your screen whenever you want some company. Works in PowerShell on Windows and in bash or zsh on Mac, Linux, Git Bash and WSL.

The pets are Mote and friends from the upcoming Kuni app.

![The eight skins, eyes open and blinking](skins.png)

## Install

### Windows (PowerShell)

Paste this into PowerShell and press Enter:

```powershell
irm https://raw.githubusercontent.com/gordoperoguapo/terminal-pets/main/web-install.ps1 | iex
```

It installs to `%LOCALAPPDATA%\terminal-pets`. Windows PowerShell 5.1 and PowerShell 7 keep separate profiles, so run it in each one you use. If PowerShell says running scripts is disabled, run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once, then try again.

### Mac, Linux, Git Bash, WSL (bash or zsh)

Paste this into your terminal and press Enter:

```sh
curl -fsSL https://raw.githubusercontent.com/gordoperoguapo/terminal-pets/main/web-install.sh | bash
```

It installs to `~/.terminal-pets` and adds itself to `~/.zshrc` and/or `~/.bashrc`.

Run either command again any time to update. Like any command that runs code from the internet, feel free to read [web-install.ps1](web-install.ps1) or [web-install.sh](web-install.sh) first.

### Manual install

Click **Code → Download ZIP** and unzip it somewhere you'll keep it (the folder is called `terminal-pets-main`), or `git clone https://github.com/gordoperoguapo/terminal-pets`. Open a terminal in that folder, then:

```powershell
Get-ChildItem | Unblock-File
.\install.ps1
```

```sh
bash install.sh
```

Windows marks downloaded files as untrusted, and `Unblock-File` clears that so PowerShell will run them. Your shell loads the pet from this folder, so leave it where it is.

## Use

| PowerShell | bash / zsh | What it does |
|---|---|---|
| `pet` | `pet` | Your pet bobs around the terminal. Press any key to stop. |
| `pet -Skin Ember` | `pet --skin Ember` | Same, with a different skin just this once |
| `pet -Speed 60` | `pet --speed 60` | Faster (milliseconds per frame, default 110) |
| `Get-PetSkin` | `pet skins` | List the skins |
| `Set-PetSkin Rumble` | `pet skin Rumble` | Switch skins. Your choice is remembered. |
| `Show-PetBanner` | `pet banner` | Show the welcome banner again |

To skip the banner when your shell starts, set `$PetBanner = $false` (PowerShell) or `PET_BANNER=0` (bash/zsh) in your profile above the terminal-pets line.

## Skins

| Skin | |
|---|---|
| Mote | the original |
| Mint, Pink, Lavender | Mote in other colors |
| Rumble | a tough little kaiju |
| Drizzle | a little rain cloud |
| Ember | a cozy flame |
| Puff | a sleepy cloud |

All skins live in [skins.txt](skins.txt), shared by both versions.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7, or bash 3.2+ / zsh
- A terminal with true-color support, such as Windows Terminal, VS Code, iTerm2, WezTerm, Kitty or Ghostty

## Uninstall

Run the uninstaller from the terminal-pets folder, then delete the folder:

```powershell
& "$env:LOCALAPPDATA\terminal-pets\uninstall.ps1"
```

```sh
bash ~/.terminal-pets/uninstall.sh
```

It removes the terminal-pets line from your profile and leaves everything else alone.

## License

The code is MIT licensed. Mote and the other character designs are not; see [LICENSE](LICENSE).
