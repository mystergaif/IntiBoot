# Переменные
NASM = nasm
QEMU = qemu-system-x86_64
BOOT_SRC = boot.asm
KERNEL_SRC = kernel.asm
BOOT_BIN = boot.bin
KERNEL_BIN = kernel.bin
IMAGE = os-image.bin

# Цель по умолчанию (просто сборка)
all: $(IMAGE)

# Сборка образа диска
$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)

# Компиляция загрузчика
$(BOOT_BIN): $(BOOT_SRC)
	$(NASM) -f bin $(BOOT_SRC) -o $(BOOT_BIN)

# Компиляция ядра
$(KERNEL_BIN): $(KERNEL_SRC)
	$(NASM) -f bin $(KERNEL_SRC) -o $(KERNEL_BIN)

# Запуск в QEMU
run: $(IMAGE)
	$(QEMU) -drive format=raw,file=$(IMAGE)

# Очистка временных файлов
clean:
	rm -f *.bin