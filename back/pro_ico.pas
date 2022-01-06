(*
 * Copyright (c) 2006
 *      Alexey Subbotin. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the author nor the names of contributors may
 *    be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *)
{$MODE DELPHI}
unit pro_ico;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Menus;

  procedure SetTrayIco;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    TI_Event: TLabel;
    GroupBox2: TGroupBox;
    TI_DC: TLabel;
    GroupBox3: TGroupBox;
    Icon: TImage;
    IconFile: TEdit;
    OpenDialog1: TOpenDialog;
    GroupBox4: TGroupBox;
    ToolTip: TEdit;
    AboutGroupBox: TGroupBox;
    Desk: TLabel;
    Author: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExitClick(Sender: TObject);
    procedure SetToolTipClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
   procedure IconCallBackMessage( var Mess : TMessage ); message WM_USER + 100;
   //����� �� ����� ��楤���, ����� �㤥� �믮������ ����� ࠧ, �����
   //�� ������ �㤥� �ந�室�� �����-���� ᮡ�⨥ (���� ��誨 � �.�.)
  end;

implementation



//
// Tray notification definitions
//

Type

       NOTIFYICONDATA         = record
                                   cbSize               : DWORD;
                                   hWnd                 : HWND;
                                   uID                  : UINT;
                                   uFlags               : UINT;
                                   uCallbackMessage     : UINT;
                                   hIcon                : HICON;
                                   {$ifdef IELower5}
                                    szTip               : array[0..63] of CHAR;
                                   {$else}
                                    szTip               : array[0..127] of CHAR;
                                   {$endif}
                                   {$ifdef IEhigherEqual5}
                                    dwState             : DWORD;
                                    dwStateMask         : DWORD;
                                    szInfo              : array[0..255] of CHAR;
                                    DUMMYUNIONNAME      : record
                                                           case longint of
                                                               0 : ( uTimeout : UINT );
                                                               1 : ( uVersion : UINT );
                                                              end;
                                    szInfoTitle : array[0..63] of CHAR;
                                    dwInfoFlags : DWORD;
                                   {$endif}
                                   {$ifdef IEHighEq6}
                                    guidItem : GUID;
                                   {$endif}
                                   end;


    const
       NIN_SELECT               = WM_USER + 0;
       NINF_KEY                 = $1;
       NIN_KEYSELECT            = NIN_SELECT or NINF_KEY;
// if (_WIN32_IE >= 0x0501)}

       NIN_BALLOONSHOW          = WM_USER + 2;
       NIN_BALLOONHIDE          = WM_USER + 3;
       NIN_BALLOONTIMEOUT       = WM_USER + 4;
       NIN_BALLOONUSERCLICK     = WM_USER + 5;
       NIM_ADD                  = $00000000;
       NIM_MODIFY               = $00000001;
       NIM_DELETE               = $00000002;
//if (_WIN32_IE >= 0x0500)}

       NIM_SETFOCUS             = $00000003;
       NIM_SETVERSION           = $00000004;
       NOTIFYICON_VERSION       = 3;

       NIF_MESSAGE              = $00000001;
       NIF_ICON                 = $00000002;
       NIF_TIP                  = $00000004;
// if (_WIN32_IE >= 0x0500)}
       NIF_STATE                = $00000008;
       NIF_INFO                 = $00000010;
//if (_WIN32_IE >= 0x600)}

       NIF_GUID                 = $00000020;
//if (_WIN32_IE >= 0x0500)}

       NIS_HIDDEN               = $00000001;
       NIS_SHAREDICON           = $00000002;
    { says this is the source of a shared icon }
    { Notify Icon Infotip flags }
       NIIF_NONE                = $00000000;
    { icon flags are mutually exclusive }
    { and take only the lowest 2 bits }
       NIIF_INFO                = $00000001;
       NIIF_WARNING             = $00000002;
       NIIF_ERROR               = $00000003;
       NIIF_ICON_MASK           = $0000000F;
//if (_WIN32_IE >= 0x0501)}

       NIIF_NOSOUND             = $00000010;

Function Shell_NotifyIcon( dwMessage: Dword;lpData: TNotifyIconData):Bool;external 'shell32.dll' name 'Shell_NotifyIcon';

//
// end Tray
//

  procedure SetTrayIco;
  var
    Form1 : TForm1;

  begin
    Application.Initialize;
    Application.Run;
    Application.CreateForm(TForm1, Form1);

  end;


procedure TForm1.FormCreate(Sender: TObject);
var TrayIconData : TNotifyIconData;

begin
  //������塞 ������ � �३ �� ���� �ணࠬ��:

    TrayIconData. cbSize := SizeOf( TNotifyIconData ); //������ �� ��������
    TrayIconData. uID := 1;            //�����䨪��� ������
    TrayIconData. uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
                                                  //������砥� �, �� �
                                                  //��ࠬ���� �室��:
                                                  //������, ᮮ�饭�� � ⥪��
                                                  //���᪠��� (娭�).
    TrayIconData. uCallbackMessage := WM_USER + 100;
                                                  //����� �� 㪠�뢠��, �����
                                                  //ᮮ�饭�� ������  ���뫠��
                                                  //�����窠 ��襩 ������� �ଥ,
                                                  //� �� ������, ����� �� ���
                                                  //(������)  �ந�室��
                                                  //�����-���� ᮡ���
    TrayIconData. hIcon := Application.Icon.Handle;
                                                  //����뢠�� �� Handle
                                                  //������ (����ࠦ����)
                                                  //(� ������ ��砥 ��६
                                                  //������ �᭮���� ���
                                                  //�ਫ������. ���� �� 㢨���
                                                  //��� ����� �� ��������)
  TrayIconData. szTip := '�ணࠬ�� Mega Rulez';

  Shell_NotifyIcon(NIM_ADD, TrayIconData);
  //����⢥��� ������塞 ������ � �३:)
  //����� ��������, �� ����� �� �ᯮ��㥬 ����⠭��
  //NIM_ADD (���������� ������).
  IconFile.Text:=Application.ExeName;
  //�뢮��� �� ������� �ଥ ����� � 䠩��, ����� ᮤ�ন�
  //������ (����ࠦ����):)
  Icon.Picture.Icon:=Application.Icon;
  //������ �뢮��� �� ������� �ଥ ����ࠦ����
  //������ (����ࠦ����) � 㢥��祭��� ����
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var TrayIconData : TNotifyIconData;

begin

  TrayIconData. cbSize := SizeOf( TNotifyIconData );
  TrayIconData. uID := 1;
  TrayIconData. uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  TrayIconData. uCallbackMessage := WM_USER + 100;
  TrayIconData. hIcon := Application.Icon.Handle;
  TrayIconData. szTip := '�ணࠬ�� Mega Rulez';

  Shell_NotifyIcon(NIM_DELETE, TrayIconData);
  //����塞 ������ �� ���. ��ࠬ���� �� ������ ��� ⮣�,
  //�⮡� �㭪�� �筮 �����, ����� ������ ������ ���� 㤠����.
  //����� ��������, �� ����� �� �ᯮ��㥬 ����⠭��
  //NIM_DELETE (㤠����� ������).
end;

procedure TForm1.IconCallBackMessage( var Mess : TMessage );

begin
  case Mess.lParam of
    //����� �� ����� ��ࠡ��뢠�� �� ᮡ���, �ந�室�騥 �� ������:)
    //�� ������ �ଥ � ᯥ樠�쭮 �ᯮ����� ��� ��⪨, � ������,
    //�� ������������� ������-���� ᮡ��� �㤥� ������� �� ������ �ந��諮:)
    //��, ⥯��� �� ��ன ��� �� �६� �������� ᮡ�⨩ ���� �ந�室��
    //ॠ��� ������.
    WM_LBUTTONDBLCLK  : TI_DC.Caption   := '������� 饫箪 ����� �������'       ;
    WM_LBUTTONDOWN    : TI_Event.Caption:= '����⨥ ����� ������ ���'          ;
    WM_LBUTTONUP      : TI_Event.Caption:= '�⦠⨥ ����� ������ ���'          ;
    WM_MBUTTONDBLCLK  : TI_DC.Caption   := '������� 饫箪 �।��� ������� ���';
    WM_MBUTTONDOWN    : TI_Event.Caption:= '����⨥ �।��� ������ ���'        ;
    WM_MBUTTONUP      : TI_Event.Caption:= '�⦠⨥ �।��� ������ ���'        ;
    WM_MOUSEMOVE      : TI_Event.Caption:= '��६�饭�� ���'                   ;
    WM_MOUSEWHEEL     : TI_Event.Caption:= '��饭�� ����ᨪ� ���'             ;
    WM_RBUTTONDBLCLK  : TI_DC.Caption   := '������� 饫箪 �ࠢ�� �������'      ;
    WM_RBUTTONDOWN    : TI_Event.Caption:= '����⨥ �ࠢ�� ������ ���'         ;
    WM_RBUTTONUP      : TI_Event.Caption:= '�⦠⨥ �ࠢ�� ������ ���'         ;
  end;
end;


procedure TForm1.ExitClick(Sender: TObject);
begin
  //����뢠�� �ਫ������. 
  Close;
end;

procedure TForm1.SetToolTipClick(Sender: TObject);
var TrayIconData : TNotifyIconData;


begin
  //����� �� �����砥� �ᯫ뢠���� ��᪠��:)
  //����� �� ⮦� ᠬ��, �� � � �।��饩 ��楤��.
  //���쪮 ������ (����ࠦ����) ������ �� ��������� Icon,
  //����� ��������� �� ������� �ଥ:)
  //� ⥪�� �ᯫ뢠�饩 ��᪠��� ��६ ��
  //��������� ToolTip (����� �ᯮ����� �� ������� �ଥ)

  TrayIconData. cbSize := SizeOf( TNotifyIconData );
  TrayIconData. uID := 1;
  TrayIconData. uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  TrayIconData. uCallbackMessage := WM_USER + 100;
  TrayIconData. hIcon := Icon.Picture.Icon.Handle;
  TrayIconData. szTip := '�ணࠬ�� Mega Rulez';

  Shell_NotifyIcon(NIM_MODIFY, TrayIconData);
  //.. � ᭮�� ���� ������:)
end;

end.