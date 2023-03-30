all:
	mkdir -p bin
	java -jar glass.jar vgmplay_init.asm bin/vgmplay.rom bin/vgmplay.sym
