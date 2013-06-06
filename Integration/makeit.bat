@echo off

    if exist "FirstApp.obj" del "FirstApp.obj"
    if exist "FirstApp.exe" del "FirstApp.exe"
    if exist "Sample1.exe" del "Sample1.exe"
    copy "Sample1C.exe" .\Sample1.exe
    \masm32\bin\ml /c /coff "FirstApp.asm"
    if errorlevel 1 goto errasm

    \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "FirstApp.obj"
    if errorlevel 1 goto errlink
    dir "FirstApp.*"
    goto TheEnd

  :errlink
    echo _
    echo Link error
    goto TheEnd

  :errasm
    echo _
    echo Assembly Error
    goto TheEnd
    
  :TheEnd

pause
