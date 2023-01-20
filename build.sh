#!/bin/bash

wla-65816 -o top-gun.obj top-gun.asm
wlalink top-gun.link top-gun.smc
