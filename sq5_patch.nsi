; The name of the installer
Name "Space Quest 5 Message Audio Patch"

; The file to write
OutFile "sq5_message_audio_patch.exe"

; The default installation directory
InstallDir $INSTDIR

; The text to prompt the user to enter a directory
DirText "Select the folder with the original version of Space Quest 5"

; Show details
ShowInstDetails show

!include "VPatchLib.nsh"

!macro Patch oldfile newfile patchfile
  File "/oname=${oldfile}.UPDATE" "${oldfile}"
  DetailPrint "${oldfile} + ${patchfile} -> ${newfile}"
  !insertmacro VPatchFile ${patchfile} "$INSTDIR\${oldfile}.UPDATE" "$INSTDIR\${oldfile}.TEMP"
  Delete "${oldfile}"
  Rename "${oldfile}.UPDATE" "${newfile}"
!macroend

Section
  SetOutPath $INSTDIR

  ; --- BACKUP SYSTEM START ---
  Var BackupDir
  StrCpy $BackupDir "$INSTDIR\Speechless Backup"

  Var LogFile
  StrCpy $LogFile "$BackupDir\patch_changes.txt"

  DetailPrint "Checking backup directory..."
  CreateDirectory "$BackupDir"

  DetailPrint "Backing up files..."

  ; Core resource archives
  IfFileExists "$BackupDir\RESOURCE.000" +2
  CopyFiles /SILENT "$INSTDIR\RESOURCE.000" "$BackupDir"
  
  IfFileExists "$BackupDir\RESOURCE.AUD" +2
  CopyFiles /SILENT "$INSTDIR\RESOURCE.AUD" "$BackupDir"
  
  IfFileExists "$BackupDir\RESOURCE.MAP" +2
  CopyFiles /SILENT "$INSTDIR\RESOURCE.MAP" "$BackupDir"

  ; Map and message databases
  IfFileExists "$BackupDir\65535.MAP" +2
  CopyFiles /SILENT "$INSTDIR\65535.MAP" "$BackupDir"
  
  IfFileExists "$BackupDir\MESSAGE.MAP" +2
  CopyFiles /SILENT "$INSTDIR\MESSAGE.MAP" "$BackupDir"
  
  IfFileExists "$BackupDir\RESOURCE.MSG" +2
  CopyFiles /SILENT "$INSTDIR\RESOURCE.MSG" "$BackupDir"

  ; Loose patch assets
  IfFileExists "$BackupDir\*.FON" +2
  CopyFiles /SILENT "$INSTDIR\*.FON" "$BackupDir"
  
  IfFileExists "$BackupDir\*.P56" +2
  CopyFiles /SILENT "$INSTDIR\*.P56" "$BackupDir"
  
  IfFileExists "$BackupDir\*.V56" +2
  CopyFiles /SILENT "$INSTDIR\*.V56" "$BackupDir"
  
  IfFileExists "$BackupDir\*.HEP" +2
  CopyFiles /SILENT "$INSTDIR\*.HEP" "$BackupDir"
  
  IfFileExists "$BackupDir\*.SCR" +2
  CopyFiles /SILENT "$INSTDIR\*.SCR" "$BackupDir"
  
  IfFileExists "$BackupDir\*.TEX" +2
  CopyFiles /SILENT "$INSTDIR\*.TEX" "$BackupDir"

  ; Sierra engine files
  IfFileExists "$BackupDir\SIERRA.EXE" +2
  CopyFiles /SILENT "$INSTDIR\SIERRA.EXE" "$BackupDir"
  
  IfFileExists "$BackupDir\INTERP.ERR" +2
  CopyFiles /SILENT "$INSTDIR\INTERP.ERR" "$BackupDir"
  
  IfFileExists "$BackupDir\AUDBLAST.DRV" +2
  CopyFiles /SILENT "$INSTDIR\AUDBLAST.DRV" "$BackupDir"

  ; Create the text log file inside the backup directory
  Var LogFileHandle
  FileOpen $LogFileHandle "$LogFile" "w"
  
  FileWrite $LogFileHandle "SPACE QUEST 5 MESSAGE AUDIO PATCH LOG$\r$\n"
  FileWrite $LogFileHandle "=======================================$\r$\n$\r$\n"
  
  FileWrite $LogFileHandle "[DELETED FILES]$\r$\n"
  FileWrite $LogFileHandle "- 65535.MAP$\r$\n"
  FileWrite $LogFileHandle "- MESSAGE.MAP$\r$\n"
  FileWrite $LogFileHandle "- RESOURCE.MSG$\r$\n"
  FileWrite $LogFileHandle "- Loose assets (*.FON, *.P56, *.V56, *.HEP, *.SCR, *.TEX)$\r$\n$\r$\n"
  
  FileWrite $LogFileHandle "[MODIFIED / PATCHED FILES]$\r$\n"
  FileWrite $LogFileHandle "- RESOURCE.AUD -> resource.sfx (Updated game audio)$\r$\n"
  FileWrite $LogFileHandle "- RESOURCE.000 -> resource.000 (Updated main package archive)$\r$\n"
  FileWrite $LogFileHandle "- RESOURCE.MAP -> resource.map (Updated internal asset mappings)$\r$\n"
  FileWrite $LogFileHandle "- SIERRA.EXE (Updated engine executable)$\r$\n"
  FileWrite $LogFileHandle "- INTERP.ERR (Updated interpreter error text file)$\r$\n"
  FileWrite $LogFileHandle "- AUDBLAST.DRV (Updated digital audio sound driver)$\r$\n$\r$\n"
  
  FileWrite $LogFileHandle "[ADDED FILES]$\r$\n"
  FileWrite $LogFileHandle "- GMGUS.DRV (Added General MIDI / Gravis Ultrasound driver)$\r$\n"
  
  FileClose $LogFileHandle
  ; ---- BACKUP SYSTEM END ----

  ; Update sound effects file
  !insertmacro Patch "RESOURCE.AUD" "resource.sfx" ".\patch\RESOURCE.AUD.PAT"

  ; Update non-audio package file
  !insertmacro Patch "RESOURCE.000" "resource.000" ".\patch\RESOURCE.000.PAT"

  ; Update mapping files
  !insertmacro Patch "RESOURCE.MAP" "resource.map" ".\patch\RESOURCE.MAP.PAT"
  Delete "65535.MAP"
  Delete "MESSAGE.MAP"
  Delete "RESOURCE.MSG"

  ; Remove ALL patch files
  ; Is this case-sensitive?
  Delete "$INSTDIR\*.FON"
  Delete "$INSTDIR\*.fon"
  Delete "$INSTDIR\*.P56"
  Delete "$INSTDIR\*.p56"
  Delete "$INSTDIR\*.V56"
  Delete "$INSTDIR\*.v56"
  Delete "$INSTDIR\*.HEP"
  Delete "$INSTDIR\*.hep"
  Delete "$INSTDIR\*.SCR"
  Delete "$INSTDIR\*.scr"
  Delete "$INSTDIR\*.TEX"
  Delete "$INSTDIR\*.tex"

  ; Update Sierra engine
  !insertmacro Patch "SIERRA.EXE" "SIERRA.EXE" ".\patch\SIERRA.EXE.PAT"
  !insertmacro Patch "INTERP.ERR" "INTERP.ERR" ".\patch\INTERP.ERR.PAT"
  !insertmacro Patch "AUDBLAST.DRV" "AUDBLAST.DRV" ".\patch\AUDBLAST.DRV.PAT"

  File ".\new\GMGUS.DRV"

  ; Remind the user to download the audio
  MessageBox MB_OK "Patch complete! Original files have been backed up to '$BackupDir'.$\nRemember to download and add 'RESOURCE.AUD' to hear vocals. You may also need to set 'audioDrv' to 'AUDBLAST.DRV' in your .CFG file."
SectionEnd
