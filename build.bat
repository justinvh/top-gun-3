del spc700.obj top-gun.obj out\top-gun.smc out\top-gun.sym
wla-spc700 -k -x -i -D DEBUG=1 -o spc700.obj engine\drivers\spc700\driver.asm
wla-65816 -k -x -i -D DEBUG=1 -o top-gun.obj game\main.asm
wlalink -i -S -A game\top-gun.link out\top-gun.smc
