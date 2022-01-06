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
   //Здесь мы объявлем процедуру, которая будет выполнятся каждый раз, когда
   //на иконке будет происходит какое-либо событие (клик мышки и т.п.)
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
  //Добавляем иконку в трей при старте программы:

    TrayIconData. cbSize := SizeOf( TNotifyIconData ); //Размер все структуры
    TrayIconData. uID := 1;            //Идентификатор иконки
    TrayIconData. uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
                                                  //Обозначаем то, что в
                                                  //параметры входят:
                                                  //Иконка, сообщение и текст
                                                  //подсказки (хинта).
    TrayIconData. uCallbackMessage := WM_USER + 100;
                                                  //Здесь мы указываем, какое
                                                  //сообщение должна  высылать
                                                  //иконочка нашей главной форме,
                                                  //в тот момент, когда на ней
                                                  //(иконке)  происходят
                                                  //какие-либо события
    TrayIconData. hIcon := Application.Icon.Handle;
                                                  //Указываем на Handle
                                                  //иконки (изображения)
                                                  //(в данной случае берем
                                                  //иконку основной формы
                                                  //приложения. Ниже Вы увидите
                                                  //как можно ее изменить)
  TrayIconData. szTip := 'Программа Mega Rulez';

  Shell_NotifyIcon(NIM_ADD, TrayIconData);
  //Собственно добавляем иконку в трей:)
  //Обратите внимание, что здесь мы исползуем константу
  //NIM_ADD (добавление иконки).
  IconFile.Text:=Application.ExeName;
  //Выводим на главной форме пусть к файлу, который содержит
  //иконку (изображение):)
  Icon.Picture.Icon:=Application.Icon;
  //Теперь выводим на главной форме изображение
  //иконки (изображения) в увеличенном виде
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var TrayIconData : TNotifyIconData;

begin

  TrayIconData. cbSize := SizeOf( TNotifyIconData );
  TrayIconData. uID := 1;
  TrayIconData. uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  TrayIconData. uCallbackMessage := WM_USER + 100;
  TrayIconData. hIcon := Application.Icon.Handle;
  TrayIconData. szTip := 'Программа Mega Rulez';

  Shell_NotifyIcon(NIM_DELETE, TrayIconData);
  //Удаляем иконку из трея. Параметры мы вводим для того,
  //чтобы функция точно знала, какую именно иконку надо удалять.
  //Обратите внимание, что здесь мы исползуем константу
  //NIM_DELETE (удаление иконки).
end;

procedure TForm1.IconCallBackMessage( var Mess : TMessage );

begin
  case Mess.lParam of
    //Здесь Вы можете обрабатывать все события, происходящие на иконке:)
    //На главнй форме я специально расположил две метки, в которых,
    //при возникновении какого-либо события будет писаться что именно произошло:)
    //Но, теперь во второй части во время некоторых событий будут происходит
    //реальные процессы.
    WM_LBUTTONDBLCLK  : TI_DC.Caption   := 'Двойной щелчок левой кнопкой'       ;
    WM_LBUTTONDOWN    : TI_Event.Caption:= 'Нажатие левой кнопки мыши'          ;
    WM_LBUTTONUP      : TI_Event.Caption:= 'Отжатие левой кнопки мыши'          ;
    WM_MBUTTONDBLCLK  : TI_DC.Caption   := 'Двойной щелчок средней кнопкой мыши';
    WM_MBUTTONDOWN    : TI_Event.Caption:= 'Нажатие средней кнопки мыши'        ;
    WM_MBUTTONUP      : TI_Event.Caption:= 'Отжатие средней кнопки мыши'        ;
    WM_MOUSEMOVE      : TI_Event.Caption:= 'Перемещение мыши'                   ;
    WM_MOUSEWHEEL     : TI_Event.Caption:= 'Вращение колесика мыши'             ;
    WM_RBUTTONDBLCLK  : TI_DC.Caption   := 'Двойной щелчок правой кнопкой'      ;
    WM_RBUTTONDOWN    : TI_Event.Caption:= 'Нажатие правой кнопки мыши'         ;
    WM_RBUTTONUP      : TI_Event.Caption:= 'Отжатие правой кнопки мыши'         ;
  end;
end;


procedure TForm1.ExitClick(Sender: TObject);
begin
  //Закрываем приложение. 
  Close;
end;

procedure TForm1.SetToolTipClick(Sender: TObject);
var TrayIconData : TNotifyIconData;


begin
  //Здесь мы назначаем всплывающую посказу:)
  //Здесь все тоже самое, что и в предыдущей процедуре.
  //Только иконка (изображение) берется из компонента Icon,
  //который назодится на главной форме:)
  //А текст всплывающей посказки берем из
  //компонента ToolTip (который расположен на главной форме)

  TrayIconData. cbSize := SizeOf( TNotifyIconData );
  TrayIconData. uID := 1;
  TrayIconData. uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  TrayIconData. uCallbackMessage := WM_USER + 100;
  TrayIconData. hIcon := Icon.Picture.Icon.Handle;
  TrayIconData. szTip := 'Программа Mega Rulez';

  Shell_NotifyIcon(NIM_MODIFY, TrayIconData);
  //.. и снова меням иконку:)
end;

end.