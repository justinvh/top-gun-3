#!/bin/bash
wla-spc700 -D DEBUG=1 -o spc700.obj engine/drivers/spc700/driver.asm
wla-65816 -D DEBUG=1 -o top-gun.obj game/main.asm
wlalink game/top-gun.link out/top-gun.smc
