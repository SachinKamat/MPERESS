@echo off
 TITLE=MQPUT - PDA_PTY 1
REM
set ResultsDirectory=%1\MQputs
if "%1"=="" set ResultsDirectory=C:\Workspace\MPERESS (4)\MPERESS_new\src\Scripts\Results
set datetime=
for /f "skip=1 delims=" %%x in ('wmic os get localdatetime') do if not defined datetime set datetime=%%x
set outputLog=%ResultsDirectory%\PDA_PTY_1_%datetime:~0,8%_%datetime:~8,6%_mqputs.txt
set MQSERVER=MQSUPPORT.SVRCONN/TCP/10.106.85.21(1420)
C:\Workspace\MPERESS (4)\MPERESS_new\src\Scripts\RFHUtil\mqputsc.exe -f C:\Workspace\MPERESS (4)\MPERESS_new\src\Scripts\Paramfile_MQPUT_PDA_PTY1.txt > %outputLog%
exit
