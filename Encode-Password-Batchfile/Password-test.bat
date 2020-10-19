@echo off

rem cscript //nologo PwdToBase64.vbs PassW0rd.123
rem IgBQAGEAcwBzAFcAMAByAGQALgAxADIAMwAiAA==

cscript //nologo Base64ToPwd.vbs IgBQAGEAcwBzAFcAMAByAGQALgAxADIAMwAiAA== > %temp%\pwd
set /p pwd= < %temp%\pwd
echo %pwd%

del %temp%\pwd /Q /F