#!/bin/bash
wla-spc700 -k -x -i -D DEBUG=1 -o spc700.obj engine/drivers/spc700/driver.asm
wla-65816 -k -x -i -D DEBUG=1 -o top-gun.obj game/main.asm
wlalink -i -S -A game/top-gun.link out/top-gun.smc
cp -r out/* /mnt/c/top-gun-3