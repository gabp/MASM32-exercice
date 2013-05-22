; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                     Build this console app with
                  "MAKEIT.BAT" on the PROJECT menu.
        ----------------------------------------------------- *

    .data?
      value dd ?
      hFile dd ?
      hMapping dd ?
      pMapping dd ?
      buffer dd 10000 dup(?)
      temp dd 512 dup(?)

    .data
      item dd 0
      fileName db "console.exe", 0
      bcnt dd 10000
      var dd ?
      NameTemplate db "%u %s",0 
      OrdinalTemplate db "%u (ord.)",0 

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

RVAToOffset PROC uses edi esi edx ecx pFileMap:DWORD,RVA:DWORD 
   mov esi,pFileMap 
   assume esi:ptr IMAGE_DOS_HEADER 
   add esi,[esi].e_lfanew 
   assume esi:ptr IMAGE_NT_HEADERS 
   mov edi,RVA ; edi == RVA 
   mov edx,esi 
   add edx,sizeof IMAGE_NT_HEADERS 
   mov cx,[esi].FileHeader.NumberOfSections 
   movzx ecx,cx 
   assume edx:ptr IMAGE_SECTION_HEADER 
   .while ecx>0 ; check all sections 
     .if edi>=[edx].VirtualAddress 
       mov eax,[edx].VirtualAddress 
       add eax,[edx].SizeOfRawData 
       .if edi<eax ; The address is in this section 
         mov eax,[edx].VirtualAddress 
         sub edi,eax
         mov eax,[edx].PointerToRawData 
         add eax,edi ; eax == file offset 
         ret 
       .endif 
     .endif 
     add edx,sizeof IMAGE_SECTION_HEADER 
     dec ecx 
   .endw 
   assume edx:nothing 
   assume esi:nothing 
   mov eax,edi 
   ret 
RVAToOffset endp 

main proc
        ;invoke GetLastError
        ;print str$(eax), 13, 10
    cls
    
    invoke CreateFile,addr fileName,GENERIC_READ,NULL,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL ;ouverture du fichier
    .if eax != INVALID_HANDLE_VALUE
      mov hFile, eax
      invoke CreateFileMapping, hFile, NULL, PAGE_READONLY,0,0,0  ;cree un objet de type fileMap
      .if eax != NULL
        mov hMapping, eax
        invoke MapViewOfFile,hMapping,FILE_MAP_READ,0,0,0   ;load l'objet de type fileMap dans la plage d'addresse de notre process
        .if eax!=NULL 
          mov pMapping,eax
          mov edi, pMapping
          assume edi:ptr IMAGE_DOS_HEADER
          .if [edi].e_magic==IMAGE_DOS_SIGNATURE  ;if MZ (== exe ou dll)
            add edi, [edi].e_lfanew 
            assume edi:ptr IMAGE_NT_HEADERS
            .if [edi].Signature==IMAGE_NT_SIGNATURE
              mov edi, [edi].OptionalHeader.DataDirectory[sizeof IMAGE_DATA_DIRECTORY].VirtualAddress
              invoke RVAToOffset, pMapping, edi
              mov edi, eax
              add edi, pMapping
              assume edi:ptr IMAGE_IMPORT_DESCRIPTOR
              invoke RVAToOffset, pMapping, [edi].Name1
              mov edx,eax 
              add edx,pMapping
              pushad
              print edx, 13, 10
              popad

              .if [edi].OriginalFirstThunk==0 
                 mov esi,[edi].FirstThunk 
              .else 
                 mov esi,[edi].OriginalFirstThunk 
              .endif

              invoke RVAToOffset,pMapping,esi 
              add eax,pMapping 
              mov esi,eax

              .while dword ptr [esi]!=0 
                 test dword ptr [esi],IMAGE_ORDINAL_FLAG32 
                 jnz ImportByOrdinal 
                 invoke RVAToOffset,pMapping,dword ptr [esi] 
                 mov edx,eax 
                 add edx,pMapping 
                 assume edx:ptr IMAGE_IMPORT_BY_NAME 
                 mov cx, [edx].Hint 
                 movzx ecx,cx 
                 invoke wsprintf,addr temp,addr NameTemplate,ecx,addr [edx].Name1 
                 jmp ShowTheText 
          ImportByOrdinal: 
                 mov edx,dword ptr [esi] 
                 and edx,0FFFFh 
                 invoke wsprintf,addr temp,addr OrdinalTemplate,edx  
          ShowTheText: 
                 pushad
                 print addr temp, 13, 10
                 popad
                 add esi,4 
              .endw

              ;print "true", 13, 10
            .endif
          .endif
        .endif
      .endif
    .endif

    ret

main endp



; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
