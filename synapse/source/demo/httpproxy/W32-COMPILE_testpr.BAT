
set put_libs=D:\hpt\RSS2FIDO\synapse\source\
set put_prog=%put_libs%demo\httpproxy\testpr
set pr_str=http://ya.ru

:next
D:\PROG_ING\FPC\bin\i386-win32\fpc.exe -Fu%put_libs%lib\ %put_prog%.pas
del %put_prog%.o
pause
%put_prog%.exe %pr_str%
pause
goto next