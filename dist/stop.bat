@echo off
set root_path="%~dp0%"
cd /d %root_path%
echo STOP > STOP.txt
attrib +h STOP.txt
powershell -nop -c "& {sleep -m 1500}"
attrib -h STOP.txt
del STOP.txt
exit /b
