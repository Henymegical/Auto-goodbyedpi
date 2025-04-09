Set FSO = CreateObject("Scripting.FileSystemObject")
Set F = FSO.GetFile(Wscript.ScriptFullName)
path = FSO.GetParentFolderName(F)

Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & path + "\stop.bat" & Chr(34), 0
Set WshShell = Nothing