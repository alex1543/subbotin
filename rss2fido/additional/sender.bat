

rem ��� ������ 䠩� ������ ����᪠�� �ணࠬ�� RSS2FIDO (ᠬ�)
rem ��� ������ 䠩� �㤥� ����᪠���� ⮫쪮 � ⮬ ��砥, �᫨
rem ������ ����� ᮮ�饭�� � ���� �����⥩ RSS
rem �������� ��室�饣� 䠩��: [⥪��� �������]CP866_out.txt
rem �� ��⠫�� ��ࠬ���� �� ��� �ᬮ�७��
D:\hpt\hpt post -nf "Ilya 'FileJunkie' Ershov" -nt "All" -af "2:5030/1538" -s "��" -e "YET.ANOTHER.LOCAL" -f loc -x CP866_out.txt

rem feutil.exe POST D:\hpt\RSS2FIDO\CP866_~1.txt YET.ANOTHER.LOCAL -from "Ilya 'FileJunkie' Ershov" -to All -subj "RSS test"



rem ��� ��室�饣� 䠩�� ����� ����� �� ��६����� ���㦥���
set out=%1
D:\hpt\hpt post -nf "Ilya 'FileJunkie' Ershov" -nt "All" -af "2:5030/1538" -s "��" -e "YET.ANOTHER.LOCAL" -f loc -x %out%

rem ����-�...
pause

