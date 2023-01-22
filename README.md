# TOP-GUN-3

Like you flew into a dream, but had to eject into a nightmare.

# Build

This project heavily uses [wla-dx](https://wla-dx.readthedocs.io/)

```
$ ./build.sh
```

# Design

No one on this team has ever looked at 65816 or SPC-700, but we're going
to hack away like it is 1991 and soar into the heavens of assembly.

## `engine/`

The engine is responsible for the core interactions with the SNES and its
peripherals. It does not provide game logic, but instead for handling
bootup, sound driver initialization, renderer, input, and interrupts.

## `game/`

The logic of the game is handled in this folder.