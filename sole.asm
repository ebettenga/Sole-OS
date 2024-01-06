  .org $8000

reset:
  ; Init Stack
  ldx #$ff
  txs
  ; Main
  jsr LCD_init
  jsr display_splash_screen
  lda #3
  jsr TIME_delay_s
  jsr LCD_clear_display
  lda #5
  jsr TIME_delay_ts 

loop:
  lda #0 
  sta MATH_FIB_A
  sta MATH_FIB_A + 1
  sta MATH_FIB_OLD
  sta MATH_FIB_OLD + 1
  sta MATH_FIB_B + 1
  lda #1
  sta MATH_FIB_B
  lda #23
  sta MATH_FIB_LIMIT
display_loop:
  jsr LCD_clear_display
  jsr MATH_fibonacci

  lda MATH_FIB_OLD
  sta MATH_HEXDEC_VAL
  lda MATH_FIB_OLD + 1
  sta MATH_HEXDEC_VAL + 1
  jsr convert_and_print_num

  lda #"+"
  jsr LCD_print_char

  lda MATH_FIB_A
  sta MATH_HEXDEC_VAL
  lda MATH_FIB_A + 1
  sta MATH_HEXDEC_VAL + 1
  jsr convert_and_print_num

  lda #"="
  jsr LCD_print_char

  lda #$41
  jsr LCD_goto_address

  lda MATH_FIB_B
  sta MATH_HEXDEC_VAL
  lda MATH_FIB_B + 1
  sta MATH_HEXDEC_VAL + 1
  jsr convert_and_print_num

  lda #1
  jsr TIME_delay_s
  dec MATH_FIB_LIMIT
  lda MATH_FIB_LIMIT
  beq loop
  jmp display_loop

message_1:      .asciiz "This is ShoeBox"  
message_2:      .asciiz "Running Sole OS"

convert_and_print_num:
  jsr MATH_hexdec_convert

  lda #<MATH_HEXDEC_OUT    ; #< Means low byte of the address of a label.  
  sta LCD_STRING_PTR       ; Save to pointer  
  lda #>MATH_HEXDEC_OUT    ; #> Means high byte of the address of a label.  
  sta LCD_STRING_PTR + 1   ; Save to pointer + 1  

  jsr LCD_print_string
  rts

display_splash_screen:
  ; Load message_1 into the LCD_STRING_PTR
  lda #<message_1         ; #< Means low byte of the address of a label.  
  sta LCD_STRING_PTR      ; Save to pointer  
  lda #>message_1         ; #> Means high byte of the address of a label.  
  sta LCD_STRING_PTR + 1  ; Save to pointer + 1  
  jsr LCD_print_string    ; Go print the string

  lda #$40                ; Second line of LCD display
  jsr LCD_goto_address

  ; Load message_2 into the LCD_STRING_PTR
  lda #<message_2            ; #< Means low byte of the address of a label.  
  sta LCD_STRING_PTR         ; Save to pointer  
  lda #>message_2            ; #> Means high byte of the address of a label.  
  sta LCD_STRING_PTR + 1     ; Save to pointer + 1  
  jsr LCD_print_string       ; Go print the string

  rts

nmi:
  rti
  
irq:
  rti

  .include "address_map.asm"
  .include "lib/lcd.asm"
  .include "lib/math.asm"
  .include "lib/time.asm"

  .org $fffa    ; Vector Sector
  .word nmi     ; NMI Destination
  .word reset   ; Reset Destination
  .word irq     ; IRQ Destination
  