; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
      value dd ?
      fileData WIN32_FIND_DATA <>

      hFile HANDLE ?
      ErrorCode DWORD ?
      
      CurrentDirectory db ?
      
    .data
      item dd 0
      fileTypeAll BYTE "*", 0
      backslash BYTE "\", 0
      tmp BYTE 10000 dup(0)
      array BYTE 10000 DUP (0)
      counter dd 0
      nbrElem dd 0
      
      
    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    cls
    invoke lstrcpy, addr array[0], addr backslash
    invoke GetCurrentDirectory, 0, 00h
    invoke GetCurrentDirectory, eax, addr CurrentDirectory
    print addr CurrentDirectory, 13, 10
    print "-----------------------------", 13, 10

    mov edx, 0
    mov counter, edx   
    mov ecx, 1
    mov nbrElem, ecx

FindDirectories:
    ;pushad
    ;fn MessageBox,0,str$(esi),"Test",MB_OK
    ;popad
    

    invoke lstrcpy, addr tmp, addr CurrentDirectory
    ;print addr tmp, 13, 10
    mov eax, counter
    mov edx, 30
    imul edx, eax
    invoke lstrcat, addr tmp, addr array[edx]
    invoke lstrcat, addr tmp, addr fileTypeAll

    ;print addr tmp, 13, 10

    invoke FindFirstFile, addr tmp, addr fileData    
    mov hFile, eax
    ;print addr tmp, 13, 10

    invoke  GetLastError
    mov     ErrorCode, eax

    
    ;print str$(ErrorCode), 13, 10
    
    .while ErrorCode != ERROR_NO_MORE_FILES
    
        .if fileData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
        ;print str$(ErrorCode), 13, 10  
            .if fileData.cFileName != 46
                    mov edx, counter
                    mov eax, 30
                    imul eax, edx

                    push eax
                    ;print str$(eax), 13, 10
                    pop eax
 
                    invoke lstrcpy, addr tmp, addr array[eax]
                    ;print addr tmp, 13, 10
                    
                    invoke lstrcat, addr tmp, addr fileData.cFileName
                    invoke lstrcat, addr tmp, addr backslash
                    ;print addr tmp, 13, 10
                    mov ecx, nbrElem
                    mov eax, 30
                    imul eax, ecx
                    invoke lstrcpy, addr array[eax], addr tmp

                    mov ecx, nbrElem
                    inc ecx
                    mov nbrElem, ecx
            .endif
        .endif
        invoke FindNextFile, hFile, addr fileData
        
        invoke  GetLastError
        mov     ErrorCode, eax
    .endw

    mov eax, hFile
    invoke FindClose, hFile
    invoke SetLastError, 0
    
    mov eax, counter
    inc eax
    mov counter, eax
    mov ecx, nbrElem

    .if eax < ecx
        jmp FindDirectories
    .endif

GoThroughArray:
    mov ecx, nbrElem
    mov eax, 1
    push eax
    .while eax < ecx     
        pop eax
        push eax
        mov edx, 30
        imul edx, eax  

        print addr array[edx], 13, 10

        pop eax
        inc eax
        push eax
        mov ecx, nbrElem
    .endw

    pop eax
    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
