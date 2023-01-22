;==LoRom==      ; We'll get to HiRom some other time.

.MEMORYMAP                      ; Begin describing the system architecture.
  SLOTSIZE $8000                ; The slot is $8000 bytes in size. More details on slots later.
  DEFAULTSLOT 0
  SLOT 0 $8000                  ; Defines Slot 0's starting address.
.ENDME          ; End MemoryMap definition

.ROMBANKSIZE $8000              ; Every ROM bank is 32 KBytes in size
.ROMBANKS 2                     ; 2 Mbits - Tell WLA we want to use 8 ROM Banks

.BANK 0 SLOT 0                  ; Defines the ROM bank and the slot it is inserted in memory.
.ORG 0                          ; .ORG 0 is really $8000, because the slot starts at $8000

.EMPTYFILL $00                  ; fill unused areas with $00, opcode for BRK.  
                                ; BRK will crash the snes if executed.