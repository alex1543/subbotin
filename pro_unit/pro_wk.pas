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

unit pro_wk;

interface

var
  ch_out : PChar = nil;
  ch_rss : PChar = nil;
  ch_tpl : PChar = nil;
  ch_cfg : PChar = nil;

  function par_cfg_macros  (const argument_one, argument_two : string) : boolean;

  function par_cfg_address (const argument : string) : boolean;
  function par_cfg_out     (const argument : string) : boolean;
  function par_cfg_exec    (const argument : string) : boolean;
  function par_cfg_post    (const argument : string) : boolean;
  function par_cfg_delete  (const argument : string) : boolean;
  function par_cfg_create  (const argument : string) : boolean;
  function par_cfg_view    (const argument : string) : boolean;
  function par_cfg_message (const argument : string) : boolean;
  function par_cfg_code    (const argument : string) : boolean;
  function par_cfg_item    (const argument : string) : boolean;
  function par_cfg_old     (const argument : string) : boolean;
  function par_cfg_outer   (const argument : string) : boolean;
  function par_cfg_exist   (const argument : string) : boolean;
  function par_cfg_file    (const argument : string) : boolean;
  function par_cfg_window  (const argument : string) : boolean;
  function par_cfg_set     (const argument : string) : boolean;
  function par_cfg_read    (const argument : string) : boolean;
  function par_cfg_line    (const argument : string) : boolean;
  function par_cfg_list    (const argument : string) : boolean;
  function par_cfg_inc     (const argument : string) : boolean;
  function par_cfg_geter   (const argument : string) : boolean;
  function par_cfg_seter   (const argument : string) : boolean;
  function par_cfg_config  (const argument : string) : boolean;

  function par_cfg_convert (const argument_one, argument_two : string) : boolean;
  function par_cfg_convert_file (const argument_one, argument_two : string) : boolean;

  function par_cfg_all_macros (const num_macros : byte) : boolean;

implementation

uses
  crt, dos,

  pro_string, pro_ch, pro_const, pro_files,
  pro_util, pro_pkt, pro_msg, pro_bso,
  pro_lang, pro_loader, pro_uue, pro_cfg,
  pro_utf, pro_coder, pro_dtb, pro_rss, pro_par;

  function par_macros_cfg_wr (const num_macros : byte; const argument_two : string) : boolean;

  begin
    par_macros_cfg_wr := false;

    // показываем лист в начале выполнения макроса
    LangList(action_id, const_cfg[num_macros], false);

    if (num_macros =  2) then
       par_macros_cfg_wr := par_cfg_address(argument_two);
    if (num_macros =  3) then
       par_macros_cfg_wr := par_cfg_post(argument_two);
    if (num_macros =  4) then
       par_macros_cfg_wr := par_cfg_out(argument_two);
    if (num_macros =  8) then
       par_macros_cfg_wr := par_cfg_message(argument_two);
    if (num_macros = 18) then
       par_macros_cfg_wr := par_cfg_exec(argument_two);
    if (num_macros = 19) then
       par_macros_cfg_wr := par_cfg_create(argument_two);
    if (num_macros = 23) then
       par_macros_cfg_wr := par_cfg_item(argument_two);
    if (num_macros = 25) then
       par_macros_cfg_wr := par_cfg_delete(argument_two);
    if (num_macros = 26) then
       par_macros_cfg_wr := par_cfg_view(argument_two);
    if (num_macros = 37) then
       par_macros_cfg_wr := par_cfg_convert('', argument_two);
    if (num_macros = 41) then
       par_macros_cfg_wr := par_cfg_convert_file(argument_two, '');
    if (num_macros = 42) then
       par_macros_cfg_wr := par_cfg_code(argument_two);
    if (num_macros = 43) then
       par_macros_cfg_wr := par_cfg_old(argument_two);
    if (num_macros = 44) then
       par_macros_cfg_wr := par_cfg_outer(argument_two);
    if (num_macros = 45) then
       par_macros_cfg_wr := par_cfg_exist(argument_two);
    if (num_macros = 46) then
       par_macros_cfg_wr := par_cfg_file(argument_two);
    if (num_macros = 47) then
       par_macros_cfg_wr := par_cfg_window(argument_two);
    if (num_macros = 48) then
       par_macros_cfg_wr := par_cfg_set(argument_two);
    if (num_macros = 49) then
       par_macros_cfg_wr := par_cfg_read(argument_two);
    if (num_macros = 50) then
       par_macros_cfg_wr := par_cfg_line(argument_two);
    if (num_macros = 51) then
       par_macros_cfg_wr := par_cfg_list(argument_two);
    if (num_macros = 52) then
       par_macros_cfg_wr := par_cfg_inc(argument_two);
    if (num_macros = 53) then
       par_macros_cfg_wr := par_cfg_seter(argument_two);
    if (num_macros = 54) then
       par_macros_cfg_wr := par_cfg_geter(argument_two);
    if (num_macros = 55) then
       par_macros_cfg_wr := par_cfg_config(argument_two);

    bool_const_cfg[num_macros] := par_macros_cfg_wr;

    // показываем лист в конце выполнения макроса
    if not (par_macros_cfg_wr) then
      LangList(error_id, const_cfg[num_macros], false) else
      LangList(normal_id, const_cfg[num_macros], false);

    LangList(end_id, const_cfg[num_macros], false);
  end;

  function par_cfg_all_macros (const num_macros : byte) : boolean;

  begin
    par_cfg_all_macros := false;
    pro_const. num_tplus := 1;
    while (GetParConf(pro_const. num_rss, num_macros, pro_const. num_tplus) <> '') do
    begin
      par_cfg_all_macros := par_macros_cfg_wr(num_macros, GetParConf(pro_const. num_rss, num_macros, pro_const. num_tplus));
      inc(pro_const. num_tplus);
    end;
    pro_const. num_tplus := 1;

  end;

  function par_cfg_macros (const argument_one, argument_two : string) : boolean;
  var
    num_t : byte;

  begin
    num_t := 1; par_cfg_macros := false;

    while (not (const_cfg[num_t] = '')) and (not par_cfg_macros) do
    begin
      if (UpCase(argument_one) = UpCase(const_cfg[num_t]) + sim_exec) then
        par_cfg_macros := par_macros_cfg_wr(num_t, argument_two);

      if (UpCase(argument_one) = UpCase(const_cfg[num_t] + all_id)) then
        par_cfg_macros := par_cfg_all_macros(num_t);

      inc(num_t);
    end;
  end;

  function par_cfg_config (const argument : string) : boolean;

  begin
    if IOFile(argument) then
    begin

      multi := true;
      if not (f_distest(ParamStr(3))) then test('start');
      load_file_ch_fast(ch_cfg, argument, sim_comment, true, true); // ch_cfg := nil;
      load_file_ch_include_fast(ch_cfg, 'include', sim_comment);
      p_read_cfg(ch_cfg); ch_cfg := nil;
      if not (f_distest(ParamStr(3))) then test('end');

      par_cfg_config := true;
    end else
      par_cfg_config := false;
  end;

  function par_cfg_seter (const argument : string) : boolean;
  var
    lang_arg_str : string;

  begin

    if (argument[1] = sim_lang_id) then
    begin
      // отделили от собаки
      lang_arg_str := f_lang_wr(argument, sim_lang_id);
      // установили значение
      par_cfg_seter := GeterSeter(lang_arg_str, false);

    end else
      par_cfg_seter := false;

  end;

  function par_cfg_geter (const argument : string) : boolean;
  var
    lang_arg_str : string;

  begin

    if (argument[1] = sim_lang_id) then
    begin
      // отделили от собаки
      lang_arg_str := f_lang_wr(argument, sim_lang_id);
      // извлекли значение
      par_cfg_geter := GeterSeter(lang_arg_str, true);

    end else
      par_cfg_geter := false;

  end;

  function par_cfg_inc (const argument : string) : boolean;
  var
    lang_arg, lang_arg_err : longint;

  begin

    if (argument[1] = sim_lang_id) then
    begin
      Val(f_lang_re(argument), lang_arg, lang_arg_err);
      if (lang_arg_err = 0) then
      begin
        inc(lang_arg);
        lang_re_set(f_lang_wr(argument, sim_lang_id), f_num2str(lang_arg));
        par_cfg_inc := true;
      end else
        par_cfg_inc := false;

    end else
      par_cfg_inc := false;

  end;

  function par_cfg_list (const argument : string) : boolean;
  var
    lang_arg_str : string;

  begin

    par_cfg_list := true;
    lang_arg_str := f_lang_re(argument);
    if (not (lang_arg_str = '')) then
      par_cfg_list := LangList(list_id, lang_arg_str, false) else
      par_cfg_list := false;

  end;

  function par_cfg_line (const argument : string) : boolean;
  var
    lang_arg1 : longint;
    lang_arg_str : string;

  begin
    if not (pos(',', argument) = 0) then
    begin
      // отделили все от запятой
      lang_arg1 := f_str2num(f_lang_re(f_in_per_end(f_re_string_pos_start(argument, ','), '')));
      // и после
      lang_arg_str := f_lang_re(f_in_per_end(argument, ','));

      WriteLnX(lang_arg1, lang_arg_str);

      par_cfg_line := true;
    end else
      par_cfg_line := false;

  end;

  function par_cfg_read (const argument : string) : boolean;
  var
    line_read : string;

  begin

    if (argument[1] = sim_lang_id) then
    begin
      bool_read := true;
      line_read := f_lang_re(argument);
      bool_read := false;
      ReadLnSt(line_read, length_read_string);
      line_read := f_lang_re(f_in_per_end(line_read, ''));
      // установили
      lang_re_set(f_lang_wr(argument, sim_lang_id), line_read);

      par_cfg_read := true;

    end else
      par_cfg_read := false;

  end;

  function par_cfg_set (const argument : string) : boolean;
  var
    lang_arg_str, line_read : string;

  begin
    if (argument[1] = sim_lang_id) then
    begin
      // отделили от собаки
      lang_arg_str := f_lang_wr(argument, sim_lang_id);
      // что после
      line_read := f_lang_re(f_in_per_end(argument, lang_arg_str));
      // установили
      lang_re_set(lang_arg_str, line_read);

      par_cfg_set := true;
    end else
      par_cfg_set := false;
  end;

  function par_cfg_window (const argument : string) : boolean;

  begin
    SetWindowSt(f_lang_re(f_in_per_end(argument, '')));
    par_cfg_window := true;
  end;

  function par_cfg_convert_file (const argument_one, argument_two : string) : boolean;

  begin
    par_cfg_convert_file := par_cfg_convert(argument_one, GetParConf(pro_const. num_rss, 37, num_tplus));

  end;

  function par_cfg_convert (const argument_one, argument_two : string) : boolean;
  var
    ch_t : PChar;
    path_file : string;

  begin
    path_file := argument_one;

    if (path_file = '') then
       path_file := GetParConf(pro_const. num_rss, 41, num_tplus);

    if not (path_file = '') then
       p_load_file_ch_all(ch_t, path_file) else
       ch_t := ch_out;

    if (UpCase(argument_two) = 'UUE') then
       UUEncodeCh(ch_t, ch_t) else
       convert_ch(ch_t, argument_two, true);

    if not (path_file = '') then
       file_create(ch_t, path_file) else
       ch_out := ch_t;

    par_cfg_convert := true;
  end;

  function par_cfg_file (const argument : string) : boolean;
  var
    put_file_lang_wr : string;
    file_lang_wr : text;
    line : string;

  begin
    line := argument;
    if (pos('>', argument) <> 0) then
    begin
      put_file_lang_wr := f_in_per_end(f_re_string_pos_start(argument, '>'), '');
      line := f_lang_re(f_in_per_end(line, '>'));
      put_file_lang_wr := f_expand(put_file_lang_wr);

      Assign(file_lang_wr, put_file_lang_wr);
      if (line[1] = '>') then
      begin
        erase(file_lang_wr);
        line := f_in_per_end(line, '>');
      end;
      if (line[1] = '^') then
      begin
        line := f_in_per_end(line, '^');
        StrReFileText(put_file_lang_wr, line);
      end else
      begin
        if not file_exist(put_file_lang_wr) then
           rewrite(file_lang_wr) else
        begin
           p_io_file(put_file_lang_wr);
           append(file_lang_wr);
        end;
        Write(file_lang_wr, line + f_enter_wr);
        close(file_lang_wr);
      end;
      par_cfg_file := true;
    end else
      par_cfg_file := false;
  end;

  function par_cfg_exist (const argument : string) : boolean;

  begin
    par_cfg_exist := file_exist(f_expand(argument));
  end;

  function par_cfg_outer (const argument : string) : boolean;

  begin
    if (not (ch_rss = nil)) and (not (ch_tpl = nil)) and (not (q_news = 0)) then
    begin
      p_new_add_in_one_msg (ch_rss, ch_tpl, ch_out, q_news);
      par_cfg_outer := true;
    end else
      par_cfg_outer := false;
  end;

  function par_cfg_old (const argument : string) : boolean;

  begin
    if (not (ch_rss = nil)) then
    begin
      par_cfg_old := rss_old(ch_rss, q_news);
    end else
      par_cfg_old := false;
  end;

  function par_cfg_item (const argument : string) : boolean;

  begin
    par_cfg_item := teg_rss_ver(ch_rss, argument);

  end;

  function par_cfg_code (const argument : string) : boolean;

  begin
    if not (f_boolean(argument)) then
    begin

  auto_code(ch_rss, pro_lang. convert_code);
  p_lang('code', false);
  if (pro_lang. convert_code = 'UTF-8') then
    convert_ch_utf2dos(ch_rss);
  if (pro_lang. convert_code = 'WINDOWS-1251') or
     (pro_lang. convert_code = 'NONE_CODE') then
    convert_ch(ch_rss, 'win', false);
  if (pro_lang. convert_code = 'ISO-8859-1') then
    convert_ch(ch_rss, 'iso', false);
  if (pro_lang. convert_code = 'KOI8-R') then
    convert_ch(ch_rss, 'koi', false);
  if (pro_lang. convert_code = 'KOI8-U') then
    convert_ch(ch_rss, 'uni', false);

      par_cfg_code := true;
    end else
      par_cfg_code := false;
  end;

  function par_cfg_view (const argument : string) : boolean;

  begin
    p_io_file(argument);
    view_file(argument);
    par_cfg_view := true;
  end;

  function par_cfg_out (const argument : string) : boolean;

  begin
    // создаем out файлы, заданные переменной "out"
    file_create(ch_out, argument);
    par_cfg_out := true;
  end;

  function par_cfg_exec (const argument : string) : boolean;

  begin
    // запускаем приложения, определённые макросом "exec"
    exec(argument, '');
    par_cfg_exec := true;
  end;

  function par_cfg_delete (const argument : string) : boolean;

  begin
    // удаляем файлы, определённые макросом "delete"
    file_erase(argument);
    par_cfg_delete := true;
  end;

  function par_cfg_post (const argument : string) : boolean;
  var
    str_t : string;

  begin
    // по-любому создаем out файл при параметре post
    if (GetParConf(pro_const. num_rss, 4, pro_const. num_tplus) = '') then
    begin
      str_t := get_file_cp_out('');
      par_cfg_out (f_expand(str_t));
      exec(argument, f_expand(str_t));
    end else
    begin
   //   par_cfg_out (par_cfg[pro_const. num_rss][4][pro_const. num_tplus]);
      exec(argument, GetParConf(pro_const. num_rss, 4, pro_const. num_tplus));
    end;
    // удаляем out файл, если он не был задан
    if (GetParConf(pro_const. num_rss, 4, pro_const. num_tplus) = '') then
      file_erase(f_expand(str_t));

    par_cfg_post := true;
  end;

  function par_cfg_create (const argument : string) : boolean;
  var
    num_t : byte;
    file_post_create_file : text;

  begin
    par_cfg_create := false;
    Assign(file_post_create_file, argument);
    // Создаем флаги и записываем туда имена почтовых баз
    {$I-} rewrite(file_post_create_file); {$I+}
    if (IOResult = 0) then
      begin
      num_t := 1;
      while (GetParConf(pro_const. num_rss, 8, num_t) <> '') do
      begin
        {$I-} writeLn(file_post_create_file, f_file_name(GetParConf(pro_const. num_rss, 8, num_t))); {$I+}
        inc(num_t);
      end;
      {$I-} close(file_post_create_file); {$I+}
      par_cfg_create := true;
    end;
  end;

  function par_cfg_message (const argument : string) : boolean;
  var
    put_post_message_base : string;

  begin
    par_cfg_message := false;
    // если это pkt
    if (Upcase(GetParConf(pro_const. num_rss, 9, pro_const. num_tplus)) = UpCase(def_base[4])) then
    begin
      p_pkt_create(ch_out, argument);
      par_cfg_message := true;
    end;
    // если это text
    if (Upcase(GetParConf(pro_const. num_rss, 9, pro_const. num_tplus)) = UpCase(def_base[5])) then
    begin
      par_cfg_out(get_file_cp_out(argument));
      par_cfg_message := true;
    end;
    // если это bso
    if (Upcase(GetParConf(pro_const. num_rss, 9, pro_const. num_tplus)) = UpCase(def_base[6])) then
    begin
      send_bso_file(argument);
      par_cfg_message := true;
    end;

    //  почтовая база сообщений
    if (not par_cfg_message) then
    begin
      put_post_message_base := argument;
      send_message_base(ch_out, put_post_message_base);
    end;
    par_cfg_message := true;
  end;

  function par_cfg_address (const argument : string) : boolean;
  var
    put_file_rss_out : string;

  begin
    if (GetParConf(pro_const. num_rss, 31, pro_const. num_tplus) <> '') then
      put_file_rss_out := GetParConf(pro_const. num_rss, 31, pro_const. num_tplus) else
      put_file_rss_out := put_rss_out;

    if (GetParConf(pro_const. num_rss, 5, pro_const. num_tplus) <> '') and
       (UpCase(f_file_ext(f_expand(GetParConf(pro_const. num_rss, 5, pro_const. num_tplus)))) <> 'LOG') then
    begin
      SetParConf(f_expand(GetParConf(pro_const. num_rss, 5, pro_const. num_tplus)), pro_const. num_rss, 5, pro_const. num_tplus);
      if (UpCase(f_file_ext(GetParConf(pro_const. num_rss, 5, pro_const. num_tplus))) = 'EXE') then
        exec(GetParConf(pro_const. num_rss, 5, pro_const. num_tplus), argument + ' --output-document=' + put_file_rss_out)
                                                       else
        exec(GetParConf(pro_const. num_rss, 5, pro_const. num_tplus), argument + ' ' + put_file_rss_out);
    end else
      get_inet_file(argument, put_file_rss_out, GetParConf(pro_const. num_rss, 5, pro_const. num_tplus));

    if (not file_exist(put_file_rss_out)) or
       (f_file_size(put_file_rss_out) = 0) then
      par_cfg_address := false else
    begin
      p_load_file_ch_all(ch_rss, put_file_rss_out);

      if not (GetParConf(pro_const. num_rss, 31, 1) <> '') then
        file_erase(put_file_rss_out);

      par_cfg_address := true;
    end;

  end;

end.