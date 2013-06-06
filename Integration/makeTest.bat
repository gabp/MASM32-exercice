@echo off

    if exist "appTest.obj" del "appTest.obj"
    if exist "appTest.exe" del "appTest.exe"
    
    \masm32\bin\ml /c /coff "appTest.asm"
    if errorlevel 1 goto errasm

    \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "appTest.obj"
    if errorlevel 1 goto errlink
    dir "appTest.*"
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
