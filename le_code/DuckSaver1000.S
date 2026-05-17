#include <avr/io.h>

.global setup
.global loop
.global __vector_11

setup:
    sbi _SFR_IO_ADDR(DDRB), 5
    sbi _SFR_IO_ADDR(DDRB), 0
    sbi _SFR_IO_ADDR(DDRB), 1
    sbi _SFR_IO_ADDR(DDRD), 4
    sbi _SFR_IO_ADDR(DDRD), 5
    sbi _SFR_IO_ADDR(DDRD), 6
    sbi _SFR_IO_ADDR(DDRD), 7
    cbi _SFR_IO_ADDR(DDRC), 0

    ldi r16, 0
    sts UBRR0H, r16
    ldi r16, 103
    sts UBRR0L, r16
    ldi r16, (1 << TXEN0)
    sts UCSR0B, r16

    ldi r16, (1 << REFS0)
    sts ADMUX, r16
    ldi r16, (1 << ADEN)|(1 << ADPS2)|(1 << ADPS1)|(1 << ADPS0)
    sts ADCSRA, r16

    rcall lcd_init

    ldi r16, 0x70
    sts OCR1AL, r16
    ldi r16, 0x7A
    sts OCR1AH, r16
    ldi r16, (1 << WGM12)|(1 << CS12)|(1 << CS10)
    sts TCCR1B, r16
    ldi r16, (1 << OCIE1A)
    sts TIMSK1, r16

    sei
    ret

loop:
    ret

__vector_11:
    push r16
    push r17
    push r18
    push r19
    push r20
    push r21
    push r22
    push r23
    push r30
    push r31
    in r16, _SFR_IO_ADDR(SREG)
    push r16

    lds r16, ADCSRA
    ori r16, (1 << ADSC)
    sts ADCSRA, r16
wait_adc:
    lds r16, ADCSRA
    sbrc r16, ADSC
    rjmp wait_adc

    lds r22, ADCL
    lds r23, ADCH

    ldi r16, lo8(819)
    ldi r17, hi8(819)
    sub r16, r22
    sbc r17, r23
    brpl ntu_positive
    ldi r16, 0
    ldi r17, 0
ntu_positive:

    clr r19
    clr r20
    clr r21
    clr r18

    mov r23, r16
    mov r22, r17
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    add r19, r23
    adc r20, r22
    adc r21, r18

    mov r23, r16
    mov r22, r17
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    add r19, r23
    adc r20, r22
    adc r21, r18

    mov r23, r16
    mov r22, r17
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    add r19, r23
    adc r20, r22
    adc r21, r18

    mov r23, r16
    mov r22, r17
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    lsl r23
    rol r22
    add r19, r23
    adc r20, r22
    adc r21, r18

    add r20, r16
    adc r21, r17
    add r20, r16
    adc r21, r17
    add r20, r16
    adc r21, r17

    ldi r16, 0
    ldi r17, 0

div_loop:
    tst r21
    brne do_sub
    cpi r20, hi8(614)
    brlo div_done
    brne do_sub
    cpi r19, lo8(614)
    brlo div_done
do_sub:
    subi r19, lo8(614)
    sbci r20, hi8(614)
    sbci r21, 0
    inc r16
    brne div_loop
    inc r17
    rjmp div_loop

div_done:
    mov r20, r16
    mov r21, r17

    tst r21
    brne check_high
    rjmp status_clean

check_high:
    cpi r21, 0x03
    brsh status_dirty
    cpi r21, 0x02
    brlo check_300
    cpi r20, 188
    brsh status_dirty
    rjmp status_normal

check_300:
    cpi r20, 44
    brsh status_normal
    rjmp status_clean

status_clean:
    cbi _SFR_IO_ADDR(PORTB), 5

    ldi r30, lo8(ser_ntu_label)
    ldi r31, hi8(ser_ntu_label)
    rcall ser_print_str
    mov r16, r20
    mov r17, r21
    rcall print_ntu_serial
    rcall ser_newline

    ldi r16, 0x01
    rcall lcd_cmd
    rcall big_delay
    rcall big_delay
    ldi r30, lo8(lcd_clean1)
    ldi r31, hi8(lcd_clean1)
    rcall lcd_print
    ldi r16, 0xC0
    rcall lcd_cmd
    ldi r30, lo8(lcd_clean2)
    ldi r31, hi8(lcd_clean2)
    rcall lcd_print
    rjmp done_isr

status_normal:
    cbi _SFR_IO_ADDR(PORTB), 5

    ldi r30, lo8(ser_ntu_label)
    ldi r31, hi8(ser_ntu_label)
    rcall ser_print_str
    mov r16, r20
    mov r17, r21
    rcall print_ntu_serial
    rcall ser_newline

    ldi r16, 0x01
    rcall lcd_cmd
    rcall big_delay
    rcall big_delay
    ldi r30, lo8(lcd_normal1)
    ldi r31, hi8(lcd_normal1)
    rcall lcd_print
    ldi r16, 0xC0
    rcall lcd_cmd
    ldi r30, lo8(lcd_normal2)
    ldi r31, hi8(lcd_normal2)
    rcall lcd_print
    rjmp done_isr

status_dirty:
    sbi _SFR_IO_ADDR(PORTB), 5

    ldi r30, lo8(ser_ntu_label)
    ldi r31, hi8(ser_ntu_label)
    rcall ser_print_str
    mov r16, r20
    mov r17, r21
    rcall print_ntu_serial
    rcall ser_newline

    ldi r16, 0x01
    rcall lcd_cmd
    rcall big_delay
    rcall big_delay
    ldi r30, lo8(lcd_dirty1)
    ldi r31, hi8(lcd_dirty1)
    rcall lcd_print
    ldi r16, 0xC0
    rcall lcd_cmd
    ldi r30, lo8(lcd_dirty2)
    ldi r31, hi8(lcd_dirty2)
    rcall lcd_print

done_isr:
    pop r16
    out _SFR_IO_ADDR(SREG), r16
    pop r31
    pop r30
    pop r23
    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
    reti

print_ntu_serial:
    push r16
    push r17
    push r18
    push r19
    push r30
    push r31

    cpi r17, 0x04
    brsh ntu_ovf_s
    cpi r17, 0x03
    brlo ntu_ok_s
    cpi r16, 0xE8
    brsh ntu_ovf_s
    rjmp ntu_ok_s
ntu_ovf_s:
    ldi r30, lo8(ser_overflow)
    ldi r31, hi8(ser_overflow)
    rcall ser_print_str
    rjmp pns_done

ntu_ok_s:
    ldi r18, 0
hu_s:
    cpi r17, 0x01
    brsh hu_sub_s
    cpi r16, 100
    brlo hu_end_s
hu_sub_s:
    subi r16, 100
    sbci r17, 0
    inc r18
    rjmp hu_s
hu_end_s:
    ldi r19, '0'
    add r19, r18
    push r16
    push r17
    mov r16, r19
    rcall ser_send
    pop r17
    pop r16

    ldi r18, 0
te_s:
    cpi r16, 10
    brlo te_end_s
    subi r16, 10
    inc r18
    rjmp te_s
te_end_s:
    ldi r19, '0'
    add r19, r18
    push r16
    mov r16, r19
    rcall ser_send
    pop r16

    ldi r19, '0'
    add r19, r16
    mov r16, r19
    rcall ser_send

pns_done:
    pop r31
    pop r30
    pop r19
    pop r18
    pop r17
    pop r16
    ret

ser_send:
    lds r17, UCSR0A
    sbrs r17, UDRE0
    rjmp ser_send
    sts UDR0, r16
    ret

ser_print_str:
    lpm r16, Z+
    cpi r16, 0
    breq ser_done
    rcall ser_send
    rjmp ser_print_str
ser_done:
    ret

ser_newline:
    ldi r16, '\r'
    rcall ser_send
    ldi r16, '\n'
    rcall ser_send
    ret

send_nibble:
    in r17, _SFR_IO_ADDR(PORTD)
    andi r17, 0x0F
    mov r18, r16
    andi r18, 0xF0
    or r17, r18
    out _SFR_IO_ADDR(PORTD), r17
    rcall small_delay
    sbi _SFR_IO_ADDR(PORTB), 1
    rcall small_delay
    rcall small_delay
    cbi _SFR_IO_ADDR(PORTB), 1
    rcall small_delay
    ret

lcd_cmd:
    cbi _SFR_IO_ADDR(PORTB), 0
    push r16
    rcall send_nibble
    pop r16
    swap r16
    rcall send_nibble
    rcall small_delay
    ret

lcd_data:
    sbi _SFR_IO_ADDR(PORTB), 0
    push r16
    rcall send_nibble
    pop r16
    swap r16
    rcall send_nibble
    rcall small_delay
    ret

lcd_print:
    lpm r16, Z+
    cpi r16, 0
    breq lcd_print_done
    rcall lcd_data
    rjmp lcd_print
lcd_print_done:
    ret

lcd_init:
    rcall big_delay
    rcall big_delay
    rcall big_delay
    cbi _SFR_IO_ADDR(PORTB), 0
    ldi r16, 0x30
    rcall send_nibble
    rcall big_delay
    ldi r16, 0x30
    rcall send_nibble
    rcall big_delay
    ldi r16, 0x30
    rcall send_nibble
    rcall big_delay
    ldi r16, 0x20
    rcall send_nibble
    rcall big_delay
    ldi r16, 0x28
    rcall lcd_cmd
    rcall big_delay
    ldi r16, 0x0E
    rcall lcd_cmd
    rcall big_delay
    ldi r16, 0x01
    rcall lcd_cmd
    rcall big_delay
    rcall big_delay
    ldi r16, 0x06
    rcall lcd_cmd
    rcall big_delay
    ret

small_delay:
    ldi r19, 255
sd1:
    nop
    nop
    nop
    dec r19
    brne sd1
    ret

big_delay:
    ldi r20, 255
bd1:
    ldi r19, 255
bd2:
    nop
    dec r19
    brne bd2
    dec r20
    brne bd1
    ret

ser_ntu_label:
    .ascii "NTU: "
    .byte 0
ser_overflow:
    .ascii "> 999"
    .byte 0
lcd_clean1:
    .ascii "Water Quality:  "
    .byte 0
lcd_clean2:
    .ascii "Status: CLEAN   "
    .byte 0
lcd_normal1:
    .ascii "Water Quality:  "
    .byte 0
lcd_normal2:
    .ascii "Status: NORMAL  "
    .byte 0
lcd_dirty1:
    .ascii "Water Quality:  "
    .byte 0
lcd_dirty2:
    .ascii "Status: DIRTY   "
    .byte 0