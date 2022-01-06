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

unit pro_rss;

interface

  procedure p_new_add_in_one_msg(const ch_rss, ch_tpl : PChar; var ch_out : PChar; const num_msg : byte);
  function teg_rss_ver (const ch_rss : PChar; const teg_id : string) : boolean;
  procedure p_rss_verif (const put_file_rss : string);
  procedure load_bool_template_macros (const par_cfg_bool_template_macros : string);


implementation

uses
  crt, dos,

  pro_lang, pro_util, pro_const, pro_ch, pro_item;

var
  num_tw, temp_num, num_t2 : longint;
  num_str : byte;
  load_str : Array[1..255] of string;
  mega_num_tpl_fix, mega_num_tpl_in_fix : byte;
  str_start_wr, str_end_wr : string;
  tpl_tstr : string;
  line : string;
  end_out : longint;

  procedure load_bool_template_macros (const par_cfg_bool_template_macros : string);

  begin
    if (UpCase(par_cfg_bool_template_macros) = 'TRUE') or
       (UpCase(par_cfg_bool_template_macros) = 'YES') or
       (par_cfg_bool_template_macros = '1') then
      bool_template_macros := true else
      bool_template_macros := false;
  end;

  procedure p_rss_verif (const put_file_rss : string);

  begin

    if (put_file_rss = '') or (pos('://', put_file_rss) = 0) then
    begin
      p_lang('error_RSS');
      pro_const. bool_exit := true;
      p_lang('error_exit');
    end;
  end;



  function teg_rss_ver (const ch_rss : PChar; const teg_id : string) : boolean;
  var
    teg_id_t : string;

  begin
    teg_id_t := '<' + teg_id + '>';
    temp_num := 1;
    while (not f_pos_ch (ch_rss, teg_id_t, temp_num)) and
          (not eof_ch(ch_rss, temp_num + length(teg_id_t))) do
      inc (temp_num);
    if eof_ch(ch_rss, temp_num + length(teg_id_t)) then
    begin
      p_lang('error_item');
      teg_rss_ver := false;
    end else
      teg_rss_ver := true;
  end;


  procedure p_news_add(const ch_item, ch_tpl : PChar; var ch_out : PChar);
  var
    temp_num_dec_read : byte;


  function f_teg_ver(teg_in, teg_out : string) : boolean;

  begin
    f_teg_ver := false; temp_num := 0;
    while (not f_pos_ch(ch_item, teg_in, temp_num)) and 
          (not eof_ch(ch_item, temp_num)) do
      inc (temp_num);

    if (f_pos_ch (ch_item, teg_in, temp_num)) then
    begin
      while (not f_pos_ch(ch_item, teg_out, temp_num)) and
            (not eof_ch(ch_item, temp_num)) do
        inc (temp_num);
      if (f_pos_ch (ch_item, teg_out, temp_num)) then
        f_teg_ver := true;
    end;
  end;


  procedure p_news_add_append (str_pnaa1, str_pnaa2 : string; num_pnaa1 : byte);
  var
      bool_inc_wrstr : boolean;
      temp_num_dec1 : word;
      num_str_del : byte;

      procedure p_re_sim_in_file_news (in_re_sim_in_file_news, out_re_sim_in_file_news : string);

      begin
        if (f_pos_ch (ch_item, in_re_sim_in_file_news, temp_num)) then
        begin
          load_str[num_str] := load_str[num_str] + out_re_sim_in_file_news;
          bool_inc_wrstr := false;
          temp_num := temp_num + length(in_re_sim_in_file_news);
          temp_num_dec_read := temp_num_dec_read + length(out_re_sim_in_file_news);
        end;
      end;

  begin
    num_str := 1;
    while (num_str < 255) do
    begin
      load_str[num_str] := '';
      inc(num_str);
    end;

    temp_num := 0;
    while (not f_pos_ch (ch_item, str_pnaa1, temp_num)) and (not eof_ch(ch_item, temp_num)) do
      inc (temp_num);
    if (eof_ch(ch_item, temp_num)) then exit;
    p_lang('news_add');

    num_str := 0;
    temp_num := temp_num + length (str_pnaa1);
    while (not f_pos_ch (ch_item, str_pnaa2, temp_num)) and
          (not f_pos_ch (ch_item, str_pnaa1, temp_num)) and (not eof_ch(ch_item, temp_num)) do
    begin
      inc(num_str);
      load_str[num_str] := str_start_wr;
      temp_num_dec_read := 1;
      while (not f_pos_ch (ch_item, str_pnaa2, temp_num)) and
            (not f_pos_ch (ch_item, str_pnaa1, temp_num)) and (not eof_ch(ch_item, temp_num)) and
        (temp_num_dec_read < mega_num_tpl_fix - mega_num_tpl_in_fix) do
      begin
        bool_inc_wrstr := true;

        if (f_pos_ch (ch_item, chr($0A), temp_num)) or
           ((f_pos_ch (ch_item, '&lt;br', temp_num)) and (not f_pos_ch (ch_item, '&lt;br /&gt;' + chr($0A), temp_num)) and (not f_pos_ch (ch_item, '&lt;br /&gt;' + chr($0D), temp_num))) or
           (f_pos_ch (ch_item, '&lt;b&gt;', temp_num)) then
        begin
          // нашли Enter
          f_string_fix(load_str[num_str], mega_num_tpl_fix - mega_num_tpl_in_fix);
          load_str[num_str] := load_str[num_str] + ' ' + str_end_wr;
          num_str := num_str +1;
          load_str[num_str] := str_start_wr;
          temp_num_dec_read := 1;
          if (f_pos_ch (ch_item, chr($0A), temp_num)) then 
          begin
            temp_num := temp_num + length(chr($0A));
            bool_inc_wrstr := false;
          end;
        end;

          // вместо '&quot;' будут записаны кавычки
        p_re_sim_in_file_news ('&quot;', '"');
          // вместо '&amp;nbsp;' будет пробел
        p_re_sim_in_file_news ('&amp;nbsp;', ' ');
          // вместо '&apos;' будет #39 (')
        p_re_sim_in_file_news ('&apos;', #39);
        p_re_sim_in_file_news ('&amp;trade;', ' (TM)');

      if (f_pos_ch (ch_item, '&lt;', temp_num)) then
      begin
        // не записываем в файл все то, что заключено между '&lt;' и '&gt;'
        temp_num_dec1 := 1;
        while (not f_pos_ch (ch_item, str_pnaa2, temp_num + temp_num_dec1)) and
              (not f_pos_ch (ch_item, '&gt;', temp_num + temp_num_dec1)) and
              (not f_pos_ch (ch_item, '&lt;', temp_num + temp_num_dec1)) do
        begin
          inc(temp_num_dec1);
        end;
        if (f_pos_ch (ch_item, '&gt;', temp_num + temp_num_dec1)) then
        begin
          temp_num := temp_num + temp_num_dec1 + length('&gt;');
          bool_inc_wrstr := false;
        end;
      end;
      if (f_pos_ch (ch_item, '&amp;lt;', temp_num)) then
      begin
        // не записываем в файл все то, что заключено между '&amp;lt;' и '&amp;gt;'
        temp_num_dec1 := 1;
        while (not f_pos_ch (ch_item, str_pnaa2, temp_num + temp_num_dec1)) and
              (not f_pos_ch (ch_item, '&amp;gt;', temp_num + temp_num_dec1)) and
              (not f_pos_ch (ch_item, '&lt;', temp_num + temp_num_dec1)) do
        begin
          inc(temp_num_dec1);
        end;
        if (f_pos_ch (ch_item, '&amp;gt;', temp_num + temp_num_dec1)) then
        begin
          temp_num := temp_num + temp_num_dec1 + length('&amp;gt;');
          bool_inc_wrstr := false;
        end;
      end;

        if bool_inc_wrstr then
        begin
          load_str[num_str] := load_str[num_str] + ch_item[temp_num];
          // если в файл что-то не записывалось, 
          // то круг считается не пройденным
          inc(temp_num_dec_read);
          inc(temp_num);
        end;
      end;

      if (f_pos_ch (ch_item, str_pnaa2, temp_num)) then
        load_str[num_str] := load_str[num_str] + ' ';
      load_str[num_str] := load_str[num_str] + str_end_wr;
    end;


    if num_pnaa1 = 1 then 
    begin
      // переносить по словам
      num_str := 1;
      while load_str[num_str] <> '' do
      begin
        num_tw := 1; num_str_del := 0;
        while (ord(load_str[num_str][num_tw]) <> 0) and
              (num_tw <= length(load_str[num_str]) - length(str_end_wr)) do
        begin
          if (load_str[num_str][num_tw] = ' ') then
            num_str_del := num_tw;
          inc(num_tw);
        end;
        if num_str_del <> 0 then
        begin
          if (load_str[num_str] <> str_start_wr) and
             (load_str[num_str] <> '') then
          begin
            load_str[num_str +1] := str_start_wr + Copy(load_str[num_str], num_str_del +1, length(load_str[num_str]) - num_str_del - length(str_end_wr)) + copy(load_str[num_str +1], length(str_start_wr) +1, length(load_str[num_str +1]) - length(str_start_wr));
            if (load_str[num_str +1] = str_start_wr) then load_str[num_str +1] := '';
            load_str[num_str] := f_string_fix(Copy(load_str[num_str], 1, num_str_del -1), mega_num_tpl_fix) + str_end_wr;
          end;
        end;
        inc(num_str);
      end;

    end;

    if num_pnaa1 >= 1 then 
    begin
     // переносить

      num_str := 1;
      while load_str[num_str] <> '' do
      begin
        p_add_ch(ch_out, end_out, load_str[num_str]);
        inc(num_str);
      end;
    end;

    if num_pnaa1 = 0 then
    begin
      // не переносить по словам
      if length(load_str[1]) > mega_num_tpl_fix - length('...' + str_end_wr) then
      begin
        load_str[1] := Copy(load_str[1], 1, mega_num_tpl_fix - length('...' + str_end_wr) +1) + '...' + str_end_wr;
      end;
      if (str_end_wr <> '') then
        load_str[1] := f_string_fix(Copy(load_str[1], 1, length(load_str[1]) - length(str_end_wr) -1), mega_num_tpl_fix) + str_end_wr;
      p_add_ch(ch_out, end_out, load_str[1]);
    end;

  end;


  begin
    p_add_ch(ch_out, end_out, #01 + 'PID: ' + by_Rain);
    num_t2 := 0;
    line := readLn_ch_enter(ch_tpl, num_t2);
    if (bool_template_macros) then
      line := f_lang_re(line);
    while (line <> '') do
    begin
      if (pos(sim_lang_id, (line)) <> 0) and
         (pos(',[', (line)) <> 0) and
         (pos(']', (line)) <> 0) and
         (pos(',', (line)) <> 0) then
      begin
        pro_const. str_teg := Copy(line, pos(sim_lang_id, (line)) +1, length(line) - (pos(sim_lang_id, (line))));
        pro_const. str_teg := Copy(pro_const. str_teg, 1, pos(',', pro_const. str_teg) -1);

        mega_num_tpl_in_fix := pos(UpCase(sim_lang_id + pro_const. str_teg + ','), UpCase(line)) -1;
        pro_const. num_re_str := f_str2num(Copy(line, pos(UpCase(sim_lang_id + pro_const. str_teg + ','), UpCase(line)) + length(sim_lang_id + pro_const. str_teg + ','), 1));
        tpl_tstr := Copy(line, pos(UpCase(sim_lang_id + pro_const. str_teg + ','), UpCase(line)) + length(sim_lang_id + pro_const. str_teg + ',') + 3, length((line)) - (pos(UpCase(sim_lang_id + pro_const. str_teg + ','), UpCase(line)) + length(sim_lang_id + pro_const. str_teg + ',') + 3) +1);
        tpl_tstr := Copy(tpl_tstr, 1, pos(']', tpl_tstr) -1);
        mega_num_tpl_fix := f_str2num(tpl_tstr);
        if mega_num_tpl_fix < mega_num_tpl_in_fix then
          mega_num_tpl_fix := mega_num_tpl_in_fix;
        str_start_wr := Copy(line, 1, mega_num_tpl_in_fix);
        str_end_wr := Copy(line, pos(UpCase(sim_lang_id + pro_const. str_teg + ','), UpCase(line)) + length(sim_lang_id + pro_const. str_teg + ',') + 1 + length(tpl_tstr) + 3, length(line) - ( pos(UpCase(sim_lang_id + pro_const. str_teg + ','), UpCase(line)) + length(sim_lang_id + pro_const. str_teg + ',') + length(tpl_tstr) + 3));

        if f_teg_ver ('<' + pro_const. str_teg + '>', '</' + pro_const. str_teg + '>') then
          p_news_add_append ('<' + pro_const. str_teg + '>', '</' + pro_const. str_teg + '>', pro_const. num_re_str)
                                                                   else
        begin
          p_add_ch(ch_out, end_out, f_string_fix(str_start_wr, mega_num_tpl_in_fix) + str_end_wr);
          p_lang('error_news');
        end;
        inc(num_t2);
        line := readLn_ch_enter(ch_tpl, num_t2);
        if (bool_template_macros) then
          line := f_lang_re(line);
        continue;
      end;
      if (line[1] <> sim_comment) and (line <> '') then
        p_add_ch(ch_out, end_out, line);
      inc(num_t2);
      line := readLn_ch_enter(ch_tpl, num_t2);
      if (bool_template_macros) then
        line := f_lang_re(line);
    end;

  end;

  procedure p_new_add_in_one_msg(const ch_rss, ch_tpl : PChar; var ch_out : PChar; const num_msg : byte);

  var
    num_msg_t : byte;
    ch_item : PChar;

  begin
    num_msg_t := 1; end_out := 0;
     while (num_msg_t <= num_msg) and (num_msg_t <= q_item) do
    begin
      load_item(ch_rss, num_msg_t, ch_item, false);
      p_news_add(ch_item, ch_tpl, ch_out);
      inc(num_msg_t);
    end;
    ch_item := nil;
    p_ch_end(ch_out, end_out);
  end;


end.