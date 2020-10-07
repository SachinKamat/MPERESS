@echo off
REM
CD "C:\Program Files (x86)\WinSCP"
"C:\Program Files (x86)\WinSCP\WinSCP.exe" /log="C:\Workspace\MPERESS (4)\MPERESS_new\src\Scripts\Winscp_output.log" /ini=nul /script="C:\Workspace\MPERESS (4)\MPERESS_new\src\Scripts\winSCP_uploadScript.txt"
