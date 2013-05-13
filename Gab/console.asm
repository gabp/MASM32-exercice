; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
      value dd ?
      nbrChars DWORD ?
      fileData WIN32_FIND_DATA <>
      fileName BYTE 100 dup(?)

      hFile HANDLE ?
      ErrorCode DWORD ?
      array BYTE 1 DUP (?)
      
    .data
      item dd 0
      count BYTE 0
      CurrentDirectory LPTSTR 200
      TempDirectory BYTE " "
      FindFirstFileError BYTE "FindFirstFile() failed with code %d", 0
      fileTypeAll BYTE "\*", 0
      backslash BYTE "\", 0
      tmp BYTE " ", 0
      
    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    cls
    
    invoke GetCurrentDirectory, 0, 00h
    invoke GetCurrentDirectory, eax, addr CurrentDirectory
    print addr CurrentDirectory, 13, 10
    print "-----------------------------", 13, 10

FindDirectories:
    ;invoke lstrcpy, addr temp, addr TempDirectory
    invoke lstrcpy, addr tmp, addr CurrentDirectory
    invoke lstrcat, addr tmp, addr fileTypeAll
    invoke FindFirstFile, eax, addr fileData    

    mov hFile, eax
    mov ecx, 0
    push ecx

    .while ErrorCode != ERROR_NO_MORE_FILES
        .if fileData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
            .if fileData.cFileName != 46
                              
                    invoke lstrcpy, addr tmp, addr backslash
                    invoke lstrcat, addr tmp, addr fileData.cFileName
                    pop ecx
                    push ecx
                    invoke lstrcpy, addr array[ecx], addr tmp

                    pop ecx
                    push ecx
                    print addr array[ecx], 13, 10

                    pop ecx
                    inc ecx
                    push ecx
            .endif
        .endif
        invoke FindNextFile, hFile, addr fileData
        
        invoke  GetLastError
        mov     ErrorCode, eax
    .endw

    pop ecx
    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
