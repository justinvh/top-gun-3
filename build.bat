del build\spc700.obj build\top-gun.obj build\top-gun.smc build\top-gun.sym
rem wla-spc700 -k -x -i -D DEBUG=1 -o spc700.obj engine\drivers\spc700\driver.asm
wla-65816 -v -k -x -i -D DEBUG=1 -o build\top-gun.obj game\main.asm
wlalink -v -i -S -A game\top-gun.link build\top-gun.smc
