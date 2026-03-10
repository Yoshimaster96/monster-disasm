# Monster In My Pocket Disassembly
### By Yoshimaster96
Disassembly of Monster In My Pocket for the NES.

# Building
Assembles with [asm6f](https://github.com/freem/asm6f).    
If that version doesn't work, you can try [morskoyzmey's asm6 build](https://github.com/morskoyzmey/asm6) instead.
## Usage
`asm6f monster.asm monster.nes`
## Versions
By default, this will build the USA version of the game.    
To build other versions, uncomment the relevant line in `monster.asm`, or specify the desired version in the command line options:    
`asm6 -d[VERSION] monster.asm monster.nes`    
See `monster.asm` for a list of available versions.

