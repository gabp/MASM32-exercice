; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�
    include \masm32\include\masm32rt.inc
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
      value dd ?
      buffer dd 100 dup(?)

    .data
      item dd 0
      processWalk db "pw",0
      driveWalk db "dw",0

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

main proc

   .while 1
       cls
       print "Process Walk (pw) / Drive Walk (dw): "
       invoke crt_gets, addr buffer
   
       invoke lstrcmp, addr buffer, addr processWalk
   
       .if eax == 0
           print "pw code here", 13, 10
       .else
           invoke lstrcmp, addr buffer, addr driveWalk
           .if eax == 0
               print "dw code here", 13, 10
           .endif        
       .endif
   .endw
  
    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

end start
