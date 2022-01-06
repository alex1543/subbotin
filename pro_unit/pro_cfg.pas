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
unit pro_cfg;

interface

  function GetParConf (const num_rss, num_plus, num_tplus : longint) : string;
  procedure SetParConf (const par_cfg : string; const num_rss, num_plus, num_tplus : longint);

  procedure p_read_cfg(const ch_cfg : PChar);
  procedure load_simvol_global(const ch_cfg : PChar; const str_global : string; var char_global : Char);
  function FileExpandConf(const put_cfg_file_expand : string; const num_const_cfg : longint) : string;
  function GetConstCfg : byte;
  function GetConstCfgVer (const ConstCfgVer : string) : boolean;
  procedure init_bool_const_cfg;

var
  ltest_dt : longint;
  stest_dt : string;

  procedure test (const test_fmt : string);

  procedure DeffParConf (const num_rss : longint);
implementation

uses
  crt, dos,

  pro_const, pro_lang, pro_util, pro_string, pro_ch, pro_files, pro_rss,

  UnixDate, pro_dt,

  skCommon;

  procedure DeffParConf (const num_rss : longint);

  begin
    // поддерживать ли макросы в templates
    bool_template_macros := f_boolean(GetParConf(num_rss, 24, 1));
    // по умолчанию тег новости <item>
    if (GetParConf(num_rss, 23, 1) = '') then
       SetParConf('item', num_rss, 23, 1);
    // по умолчанию определяем кодовую страницу и конвертим в dos
    if (GetParConf(num_rss, 42, 1) = '') then
       SetParConf('FALSE', num_rss, 42, 1);
    // по умолчанию определяем кол-во новых сообщений
    if (GetParConf(num_rss, 43, 1) = '') then
       SetParConf('FALSE', num_rss, 43, 1);
    if (GetParConf(num_rss, 44, 1) = '') then
       SetParConf('FALSE', num_rss, 44, 1);
    if (GetParConf(num_rss, 1, 1) = '') then
       SetParConf(rss_none_name + GetParConf(num_rss, 2, 1), num_rss, 1, 1);
    if file_exist(put_rss_out) and (GetParConf(num_rss, 31, 1) = '') then
       file_erase(put_rss_out);

  end;

  procedure init_bool_const_cfg;
  var
    num_t : byte;

  begin
    for num_t := 1 to GetConstCfg do
      bool_const_cfg[num_t] := false;
  end;

  procedure test (const test_fmt : string);

  begin
    if (test_fmt = 'start') then
    begin
      ltest_dt := Dos2UnixDate(GetDateTime);
      stest_dt := date_and_time(2);
    end;

    if (test_fmt = 'end') then
    begin
      ltest_dt := Dos2UnixDate(GetDateTime) - ltest_dt;

      WriteLn('  Statistics processing configuration file:');
      WriteLn(' -------------------------------------------');
      WriteLn(' Period: ', stest_dt, ' to ', date_and_time(2));
      WriteLn(' Seconds and the systems:');
      WriteLn('   [16]  CPU: PI-MMX/166 MGz, RAM: 80 Mb, Windows XP Proff.');
      WriteLn('   [15]  CPU: PI-MMX/150 MGz, RAM: 48 Mb, Windows 2000 SP4 Proff.');
      WriteLn('    [2]  CPU: Celeron/800 MGz, RAM: 384 Mb, Windows XP Proff.');
      WriteLn(' Your system: ', ltest_dt, ' second.');
      WriteLn(' Pause 2 sec.');
      WriteLn;
      delay(1200);
    end;

  end;

  function GetParConf (const num_rss, num_plus, num_tplus : longint) : string;

  begin
    if not (ch_lng = nil) then
       GetParConf := f_lang_re(ParConf[num_rss][num_plus][num_tplus]) else
       GetParConf := ParConf[num_rss][num_plus][num_tplus];
  end;

  procedure SetParConf (const par_cfg : string; const num_rss, num_plus, num_tplus : longint);
  var
    address_wk : TAddress;

  begin
    ParConf[num_rss][num_plus][num_tplus] := FileExpandConf(par_cfg, num_plus);
    if (num_plus = 2) then RSSAllVerAndGetURL(num_rss, num_plus, num_tplus); // address

    if (num_plus = 12) or (num_plus = 13) then
    begin
      if not StrToAddress(par_cfg, address_wk) then
        LangList(sys_id, 'err_address', true);

    end;
  end;

var
  num_t2, num_temp : longint;
  line : string;
  bool_start_rss, bool_start : boolean;

  function FileExpandConf(const put_cfg_file_expand : string; const num_const_cfg : longint) : string;

  begin
    if (put_cfg_ver[num_const_cfg]) and (put_cfg_file_expand <> '') then
      FileExpandConf := f_expand(put_cfg_file_expand) else
      FileExpandConf := put_cfg_file_expand;

  end;

  procedure p_cfg_rss_init;

  begin
    bool_start := true;
  end;

  function f_cfg_rss_end (in_rss_line : string) : boolean;

  begin
    f_cfg_rss_end := false;
    if (not bool_start) then
    begin
      f_cfg_rss_end := (in_rss_line = '');
      if (((UpCase(Copy(in_rss_line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) and (not bool_start_rss)) or
         (UpCase(Copy(in_rss_line, 1, length('[end_rss]'))) = UpCase('[end_rss]'))) then
      begin
        bool_start_rss := false;
        f_cfg_rss_end := true;
        bool_start := true;
      end;
      if (UpCase(Copy(in_rss_line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) then
        bool_start_rss := false;
    end;
  end;

  function f_cfg_rss_start (in_rss_line : string) : boolean;

  begin
    f_cfg_rss_start := false;
    if (bool_start) then
    begin
      if (UpCase(Copy(in_rss_line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) or
         (UpCase(Copy(in_rss_line, 1, length('[start_rss]'))) = UpCase('[start_rss]')) then
      begin
        if (UpCase(Copy(in_rss_line, 1, length('[start_rss]'))) = UpCase('[start_rss]')) then
          bool_start_rss := true else bool_start_rss := false;
        f_cfg_rss_start := true;
        bool_start := false;
      end;
    end;
  end;

  function f_cfg_const_start (in_const_line : string) : boolean;
  begin
    f_cfg_const_start := (UpCase(Copy(in_const_line, 1, length('[start_const]'))) = UpCase('[start_const]'));
  end;
  function f_cfg_const_end (in_const_line : string) : boolean;
  begin
    f_cfg_const_end := (UpCase(Copy(in_const_line, 1, length('[end_const]'))) = UpCase('[end_const]'));
  end;

  procedure load_simvol_global(const ch_cfg : PChar; const str_global : string; var char_global : Char);
  var
    num_str : longint;
    bool_load_simvol_global : boolean;

  begin
    num_str := 0;
    bool_load_simvol_global := false;
    while ((num_str <= read_ch_enter_all(ch_cfg)) and (not bool_load_simvol_global)) do
    begin
      line := readLn_ch_to_enter(ch_cfg, num_str);
      line := f_start_end_del_str_simvol(line, ' ');
      if (UpCase(copy(line, 1, length('global '))) = UpCase('global ')) then
      begin
        line := f_in_per_end(line, 'global ');
        if (UpCase(copy(line, 1, length(str_global + ' '))) = UpCase(str_global + ' ')) then
        begin
          char_global := f_in_per_end(line, str_global + ' ')[1];
          bool_load_simvol_global := true;
        end;
      end;
    end;

  end;

  function GetConstCfg : byte;
  var
    num_t : byte;

  begin
    num_t := 1;
    while not (const_cfg[num_t] = '') do
      inc(num_t);

    GetConstCfg := num_t;
  end;

  function GetConstCfgVer (const ConstCfgVer : string) : boolean;
  var
    num_t : byte;

  begin
    GetConstCfgVer := false;
    for num_t := 1 to GetConstCfg do
    begin
      if Upcase(ConstCfgVer) = UpCase(const_cfg[num_t]) then
        GetConstCfgVer := true;
    end;
  end;

  procedure new_const (const line : string);
  var
    num_new_const : byte;
    str_new_const : string;

  begin
    if not (pos(' ', line) = 0) then
    begin
      str_new_const := f_re_string_pos_start(line, ' ');
      num_new_const := f_str2num(str_new_const);
      str_new_const := f_in_per_end(line, str_new_const);
      if (not (num_new_const = 0)) and
         (num_new_const <= GetConstCfg) and (not (str_new_const = '')) then
        const_cfg[num_new_const] := str_new_const;
    end;
  end;

  procedure p_read_cfg(const ch_cfg : PChar);

  var
    num_str : longint;
    num_const_cfg : byte;
    str_def_cfg : string;
    num_def_cfg : byte;
    str_def_set : string;
    str_set_t : string;
    num_const_cfg_plus, num_def_cfg_plus_max : byte;
    default_cfg : Array of string;

  begin

    SetLength(default_cfg, GetConstCfg +1);
    for num_def_cfg := 1 to GetConstCfg do
      default_cfg[num_def_cfg] := '';

    num_str := 0;
    p_cfg_rss_init;
    pro_const. num_rss := 1;
    SetLength(ParConf, pro_const. num_rss +1);
    repeat
      line := readLn_ch_to_enter(ch_cfg, num_str);
      line := f_start_end_del_str_simvol(line, ' ');

        // переименовываем переменные конфиг файла,
        // заключенные между [start_const] и [end_const]
        // и пропускаем все другие переменные
        if f_cfg_const_start(line) then
        begin
          // читаем следующую строку после [start_const]
          line := readLn_ch_to_enter(ch_cfg, num_str);
          line := f_start_end_del_str_simvol(line, ' ');
          while (not f_cfg_const_end(line)) and
          (not f_cfg_rss_start(line)) and (not f_cfg_rss_end(line)) do
          begin
            new_const(line);
            // читаем следующую строку
            line := readLn_ch_to_enter(ch_cfg, num_str);
            line := f_start_end_del_str_simvol(line, ' ');
          end;
        end;
        // А можно и не пропуская другие переменные
        new_const(line);

        if (UpCase(Copy(line, 1, length('default '))) = UpCase('default ')) then
        begin
          str_def_cfg := f_in_per_end(line, 'default ');
          num_def_cfg := 1;
          while (const_cfg[num_def_cfg] <> '') do
          begin
            if (UpCase(Copy(str_def_cfg, 1, length(const_cfg[num_def_cfg] + ' '))) = UpCase(const_cfg[num_def_cfg] + ' ')) then
              default_cfg[num_def_cfg] := f_in_per_end(str_def_cfg, const_cfg[num_def_cfg]);

            inc(num_def_cfg);
          end;
        end;

        if (UpCase(Copy(line, 1, length('set '))) = UpCase('set ')) then
        begin
          str_def_set := f_in_per_end(line, 'set ');
          if (pos(' ', str_def_set) <> 0) and
             (str_def_set[1] = sim_lang_id) then
          begin
            str_set_t := Copy(str_def_set, 2, pos(' ', str_def_set) -2);
            lang_re_set(str_set_t, f_in_per_end(str_def_set, sim_lang_id + str_set_t));
          end;
        end;

        f_cfg_rss_start(line);

        num_const_cfg := 1;
        while (const_cfg[num_const_cfg] <> '') do
        begin
          if (UpCase(Copy(line, 1, length(const_cfg[num_const_cfg] + ' '))) = UpCase(const_cfg[num_const_cfg] + ' ')) then
          begin
            num_const_cfg_plus := 1;
            while (ParConf[pro_const. num_rss][num_const_cfg][num_const_cfg_plus] <> '') do
              inc(num_const_cfg_plus);
            SetParConf(f_in_per_end(line, const_cfg[num_const_cfg]), pro_const. num_rss, num_const_cfg, num_const_cfg_plus);

          end;
          inc(num_const_cfg);
        end;

        if f_cfg_rss_end(line) then
        begin
          num_const_cfg := 1;
          if (ParConf[pro_const. num_rss][8][1] = '') and
             (ParConf[pro_const. num_rss][3][1] = '') then
            // если post_base не задано, то post будет задано из default
            SetParConf(default_cfg[3], pro_const. num_rss, 3, 1);
          num_def_cfg := 1;
          num_t2 := 2; num_def_cfg_plus_max := 1;
          while (const_cfg[num_def_cfg] <> '') do
          begin
             // Если параметр в группе не задан
            if (ParConf[pro_const. num_rss][num_def_cfg][1] = '') and
               (default_cfg[num_def_cfg] <> '') then
              begin
                // если внутренний постер не задан, будет использоваться внешний
                if (UpCase(const_cfg[3]) <> UpCase(const_cfg[num_def_cfg])) then
                  SetParConf(default_cfg[num_def_cfg], pro_const. num_rss, num_def_cfg, 1);
              end;
            // если задано параметров для значения в группе больше, чем один
            while (ParConf[pro_const. num_rss][num_def_cfg][num_t2] <> '') and
                  (pos('_', const_cfg[num_def_cfg]) <> 0) do
            begin
              // нашли максимальный
              if (num_def_cfg_plus_max < num_t2) then
                num_def_cfg_plus_max := num_t2;
              inc(num_t2);
            end;
            inc(num_def_cfg);
          end;
          num_def_cfg := 1;
          while (const_cfg[num_def_cfg] <> '') do
          begin
            // Если в переменных типа "post_" что-то недописано,
            // то будет дописано из default или предыдущего значения 
            if (pos('_', const_cfg[num_def_cfg]) <> 0) then
            begin
               // Если параметры в группе не заданы до максимального значения,
              num_t2 := 2;
              while (num_t2 <= num_def_cfg_plus_max) do
              begin
              // то присваиваются значения из default
                if (ParConf[pro_const. num_rss][num_def_cfg][num_t2] = '') and
                   (default_cfg[num_def_cfg] <> '') then
                begin
                  if (UpCase(const_cfg[3]) <> UpCase(const_cfg[num_def_cfg])) then
                    SetParConf(default_cfg[num_def_cfg], pro_const. num_rss, num_def_cfg, num_t2);
                end;
                // если default не задано, то присваивается последнее значение порядка
                if (ParConf[pro_const. num_rss][num_def_cfg][num_t2] = '') and
                   (default_cfg[num_def_cfg] = '') then
                begin
                  num_temp := 1;
                  // нашли последнее заданное значение
                  while (ParConf[pro_const. num_rss][num_def_cfg][num_temp] <> '') do
                    inc(num_temp);
                  num_temp := outc(num_temp);

                   // если пследнее значение все-таки есть
                  if (ParConf[pro_const. num_rss][num_def_cfg][num_temp] <> '') then
                    SetParConf(ParConf[pro_const. num_rss][num_def_cfg][num_temp], pro_const. num_rss, num_def_cfg, num_t2);

                end;
                inc(num_t2);
              end;
            end;
            inc(num_def_cfg);
          end;
         // переходим к новой группе
          inc(pro_const. num_rss);
          SetLength(ParConf, pro_const. num_rss +1);

        end;
    until (line = '');
    pro_const. num_rss_end := pro_const. num_rss -1;
    pro_const. num_rss := 1;
  end;

end.