[bits 64]
[org 0x8000]
default abs

    ; Сложение
    mov rax, 5
    add rax, 10      ; rax = 15

    ; Перевод 15 в символы '1' и '5'
    ; 15 / 10 = 1 (остаток 5)
    mov rbx, 10
    xor rdx, rdx
    div rbx          ; rax = 1, rdx = 5

    add al, '0'      ; превращаем 1 в '1'
    add dl, '0'      ; превращаем 5 в '5'

    ; Вывод в видеопамять (белый текст на черном - 0x07)
    mov byte [0xb8000], al    ; '1'
    mov byte [0xb8001], 0x07
    mov byte [0xb8002], dl    ; '5'
    mov byte [0xb8003], 0x07

    hlt