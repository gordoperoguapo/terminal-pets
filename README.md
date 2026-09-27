# terminal-pets

A tiny pixel-art pet for your PowerShell terminal. It greets you with a bounce and a blink when you open a new window, and it can bob around your screen whenever you want some company.

The pets are Mote and friends from the upcoming Kuni app.

![The eight skins, eyes open and blinking](skins.png)

## Install

### Quick install

Paste this into PowerShell and press Enter:

```powershell
irm https://raw.githubusercontent.com/gordoperoguapo/terminal-pets/main/web-install.ps1 | iex
```

It downloads terminal-pets to `%LOCALAPPDATA%\terminal-pets` and adds it to your PowerShell profile. Run it again any time to update. Like any command that runs code from the internet, feel free to read [web-install.ps1](web-install.ps1) first.

### Manual install

1. Get the files, either way:
   - Click **Code → Download ZIP** and unzip it somewhere you'll keep it, such as Documents. The unzipped folder is called `terminal-pets-main`.
   - Or clone it: `git clone https://github.com/gordoperoguapo/terminal-pets`
2. Open that folder in File Explorer, right-click an empty space and choose **Open in Terminal**.
3. Run the installer:
   ```powershell
   .\install.ps1
   ```
4. Open a new PowerShell window.

Your profile loads the pet from this folder, so leave it where it is.

### Good to know

- Windows PowerShell 5.1 and PowerShell 7 keep separate profiles. Install once in each one you use.
- If PowerShell says running scripts is disabled, run this once, then try again:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
  ```

## Use

| Command | What it does |
|---|---|
| `pet` | Your pet bobs around the terminal. Press any key to stop. |
| `pet -Skin Ember` | Same, with a different skin just this once |
| `pet -Speed 60` | Faster (milliseconds per frame, default 110) |
| `Get-PetSkin` | List the skins |
| `Set-PetSkin Rumble` | Switch skins. Your choice is remembered. |
| `Show-PetBanner` | Show the welcome banner again |

To keep the commands but skip the banner when PowerShell starts, add `$PetBanner = $false` to your profile above the terminal-pets line.

## Skins

| Skin | |
|---|---|
| Mote | the original |
| Mint, Pink, Lavender | Mote in other colors |
| Rumble | a tough little kaiju |
| Drizzle | a little rain cloud |
| Ember | a cozy flame |
| Puff | a sleepy cloud |

## Requirements

- Windows PowerShell 5.1 or PowerShell 7
- A terminal with true-color support, such as Windows Terminal or the VS Code terminal

## Uninstall

Run `uninstall.ps1` from the terminal-pets folder. If you used the quick install, that's:

```powershell
& "$env:LOCALAPPDATA\terminal-pets\uninstall.ps1"
```

This removes the terminal-pets line from your profile and leaves everything else alone. Then you can delete the folder.

## License

The code is MIT licensed. Mote and the other character designs are not; see [LICENSE](LICENSE).
