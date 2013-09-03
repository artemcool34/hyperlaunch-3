MEmu = PCSXR
MEmuV =  r87054
MURL = http://pcsxr.codeplex.com/
MAuthor = djvj
MVersion = 2.0.3
MCRC = 2B3C8180
iCRC = 60E37EB3
MID = 635038268913822158
MSystem = "Sony PlayStation"
;----------------------------------------------------------------------------
; Notes:
; To use CUE files: (NOTE: no other file types are tested with this module)
; In the emu, set your Cdrom plugin to P.E.OpS CDR Driver 1.4 and press configure
; I set Interface to "W2K/XP - IOCTL scsi commands"
; Set Drive to match your Daemon Tools scsi drive letter and mount a PSX disc in it, then click "Try auto-detection" and Read Mode should be filled for you.
; I set Caching to Async, but haven't done much testing. If something else is better please let me know.
; Module supports sending cue files directly to the emu simply by turning off Daemon Tools in HLHQ
;
; Sound
; I had to change the Sound mode to High Compatibility to get rid of scratchy sounds
;
; Graphics
; If you have no video with OpenGL Driver, try using Pete's OpenGL2 plugin
; Fullscreen is controlled by the setting in HLHQ to give quick access to testing and bezel support
; Resolution can changed in the emu's GPU Plugin config.
;
; MultiGame
; Module only supports swapping discs when using Daemon Tools
;
; Emu settings are stored in the registry @ HKEY_CURRENT_USER\Software\Pcsxr
; GPU settings are stored in the registry @ HKEY_CURRENT_USER\Software\Vision Thing\PSEmu Pro\GPU\
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
NoEmuGUI := IniReadCheck(settingsFile, "Settings", "NoEmuGUI","true",,1)			; Remove all GUI elements from the emu
sysParams := IniReadCheck(settingsFile, "Settings", "Params", A_Space,,1)
romParams := IniReadCheck(settingsFile, romName, "Params", A_Space,,1)

If Fullscreen = true
	WriteReg("WindowMode", 0)	; changes fullscreen setting for all 3 gpu plugins
Else
	WriteReg("WindowMode", 1)

7z(romPath, romName, romExtension, 7zExtractPath)

noEmuGUI := If NoEmuGUI = "true" ? "-nogui" : ""
cdType := If dtEnabled = "true" ? "-runcd" : "-cdfile"
cdPath := If dtEnabled = "true" ? "" : """" . romPath . "\" . romName . romExtension . """"
sysParams := If sysParams != ""  ? sysParams : ""
romParams := If romParams != ""  ? romParams : ""

; Mount the CD using DaemonTools
If dtEnabled = true
	DaemonTools("mount", romPath . "\" . romName . romExtension)

Run(executable . A_Space .  noEmuGUI . A_Space . sysParams . A_Space . romParams . A_Space . cdType . A_Space .  cdPath, emuPath)

WinWait("ahk_class PCSXR Main")
WinWaitActive("ahk_class PCSXR Main")

FadeInExit()
Process("WaitClose", executable)

If dtEnabled = true
	DaemonTools("unmount")

7zCleanUp()
FadeOutExit()
ExitModule()


; ReadReg(var1) {
	; RegRead, regValue, HKEY_CURRENT_USER, Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2, %var1%
	; Return %regValue%
; }

WriteReg(var1, var2) {
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Vision Thing\PSEmu Pro\GPU\PeteOpenGL2, %var1%, %var2%
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Vision Thing\PSEmu Pro\GPU\PeteTNT, %var1%, %var2%
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Vision Thing\PSEmu Pro\GPU\DFXVideo, %var1%, %var2%
}

MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from DaemonTools
	DaemonTools("unmount")
	Sleep, 500	; Required to prevent  DT from bugging
	; Mount the CD using DaemonTools
	DaemonTools("mount",selectedRom)
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class PCSXR Main")
Return
