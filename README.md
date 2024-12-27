# bloodborne-sound-repack-linux
A utility script to repack encrypted Bloodborne FSB files to get sound working for emulators.

## Dependencies

* `lame`
* `vgmstream`
* `wine`
* `fsbankcl` (see below)

I've only tested this on Arch and don't have other distros hanging about to
test. Please refer to your package manager or the source of the listed requirements
to install.

### Arch Linux (using an AUR helper)

```bash
yay -S lame vgmstream-git wine jq
```

### Fmod `fsbankcl` install.

This tool is needed to repack the MP3s we unpack from the original files into
the FSB format again. Unfortuantely, it's licensed software.
[The license](https://www.fmod.com/legal) permits for unrestricted hobbyist use
, but not distribution, so you'll need to grab it yourself.

On top of this, the version of fsbankctl we need (<=1.08.30) is Windows-only.
This is where the Wine dependency comes from.

To get the tool, make an account at `https://www.fmod.com`, navigate to
`Download`, then open the `FMOD Engine` dropdown, select `Older` above
the version picker, and select `1.08.30 (Unsupported)`. Download the
`Windows 10 UWP` version of FMOD engine.

From this repo's root, run the following:

```bash
# Assumes the downloaded file is also in the repo root.
WINEPREFIX="$(pwd)/fsmod_wineprefix/" wine fmodstudioapi10830uwp-installer.exe
```

This will open a Windows installer, just follow the prompts. After it succeeds,
you should be ready to roll.

This sucks, I know. I'm very new to this Fmod business so if there is a better
way, please let me know.

### Usage

To run the tool, issue the following command from the repo root:

```bash
./bloodborne-sound-repack.sh <game_install_directory>/CUSA<xxxx>/dvdroot_ps4/sound/
```

This will take some time, just be patient. If you can see the terminal
continuing to provide new output, the script is still at work.


Once completed, the repacked sound files will be stored in `repacked_fsb`. They
can either be copied into `<game_install_directory>/CUSA<xxxx>/dvdroot_ps4/sound/`
(backup the existing sound files first), or, you can pack them into something
[GME](https://www.nexusmods.com/bloodborne/mods/48?tab=description) can install
for you.
