[org 0x7c00]
[bits 16]

    ; 1. Настройка стека и чтение ядра с диска
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Читаем ядро по адресу 0x8000
    mov ah, 0x02                ; Функция чтения BIOS
    mov al, 1                   ; Сколько секторов читать
    mov ch, 0                   ; Цилиндр 0
    mov dh, 0                   ; Головка 0
    mov cl, 2                   ; Начать со 2-го сектора (сразу после boot)
    mov bx, 0x8000              ; Куда грузить
    int 0x13
    jc disk_error               ; Если ошибка - зависнуть

    ; 2. Переход в 32-битный Protected Mode
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:init_pm

[bits 32]
init_pm:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax

    ; 3. Настройка страничной адресации
    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd

    mov edi, cr3
    mov dword [edi], 0x2003
    add edi, 0x1000
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x00000083

    ; 4. Вход в Long Mode
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    lgdt [gdt64_descriptor]
    jmp 0x08:0x8000             ; ПРЫЖОК ПРЯМО В ЯДРО (оно уже загружено)

disk_error:
    jmp $

; Данные GDT (те же самые)
gdt_start: dq 0
gdt_code:  dw 0xffff, 0x0000, 0x9a00, 0x00cf
gdt_data:  dw 0xffff, 0x0000, 0x9200, 0x00cf
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

gdt64_start: dq 0
gdt64_code:  dq (1<<43) | (1<<44) | (1<<47) | (1<<53)
gdt64_data:  dq (1<<41) | (1<<44) | (1<<47)
gdt64_end:
gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dq gdt64_start

times 510-($-$$) db 0
dw 0xaa55