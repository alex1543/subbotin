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

unit pro_lang;

interface

uses
   pro_const;

var convert_code : string = ('Unknown');

var
// длинна строки в макросе @read: по дефолту
  length_read_string : byte = 60;
  bool_read : boolean = false;

  function f_lang_re (in_lang_re : string) : string;
  function lang_re_set(const in_str_set, in_str_reset : string) : boolean;

  function f_lang_wr (line_wr, lang_wr : string) : string;
  procedure DelayLang(const num_sec_enter : longint; const lang_id, list_id : string; const bool_sec_enter : boolean);
 var bool_exit : boolean = (false);
  function LangList (const lang_id, list_id : string; const bool_error_exit : boolean) : boolean;

  function GetFirstFile (const ft_in : FirstFile) : string;
  procedure p_io_lang_file(const put_io_lang_file : string);
  procedure err_cfg (const put_file_cfg : string);

var lng_sv, tpl_sv : A2St;  // Array Of String
  function load_file_save (var ch_sv : PChar; const num_in_sv : byte; var in_sv : A2St) : string;
  procedure init_load_file (var in_sv : A2St);

implementation

uses
  crt, dos,

  pro_util, pro_string, pro_dt,
  pro_ch, pro_files, pro_par, pro_wk, pro_dtb, pro_cfg, pro_rss;

  procedure init_load_file (var in_sv : A2St);
  var
    num_t : byte;

  begin
    SetLength(in_sv, 2);
    for num_t := 0 to 2 do
      in_sv[num_t] := '';
  end;

  function load_file_save (var ch_sv : PChar; const num_in_sv : byte; var in_sv : A2St) : string;
  var
    ch_t : PChar;
    num_sv : longint;
    path_file : A2St;
    num_t : byte;
    bool_new : boolean;

  begin

    pro_const. num_tplus := 1;
    SetLength(path_file, pro_const. num_tplus +2);
    path_file[pro_const. num_tplus] := GetParConf(pro_const. num_rss, num_in_sv, pro_const. num_tplus);
    path_file[pro_const. num_tplus +1] := '';
    // если текущий и предыдущий ничему не равны...
    if (in_sv[pro_const. num_tplus] = '') and (path_file[pro_const. num_tplus] = '') then
    begin
      if (num_in_sv = 6) then
         // если template не указан, то будет найден первый с расширением tpl.
         path_file[pro_const. num_tplus] := f_open_first_file ('tpl', 'err_tpl');
      if (num_in_sv = 7) then
         path_file[pro_const. num_tplus] := GetFirstFile (ft_lng);
      SetParConf(path_file[pro_const. num_tplus], pro_const. num_rss, num_in_sv, pro_const. num_tplus);
    end;
    while not (GetParConf(pro_const. num_rss, num_in_sv, pro_const. num_tplus) = '') do
    begin
      SetLength(path_file, pro_const. num_tplus +2);
      path_file[pro_const. num_tplus] := GetParConf(pro_const. num_rss, num_in_sv, pro_const. num_tplus);
      path_file[pro_const. num_tplus +1] := '';
      inc(pro_const. num_tplus);
    end;
    pro_const. num_tplus := 1; bool_new := (in_sv[1] = '');
    while (not (path_file[pro_const. num_tplus] = '')) and (not bool_new) do
    begin // ищем новые template or language
      num_t := 1;
      while (not (in_sv[num_t] = '')) and (not (UpCase(in_sv[num_t]) = UpCase(path_file[pro_const. num_tplus]))) do
        inc(num_t);
      // если не одно значение из группы не найдено
      bool_new := (in_sv[num_t] = '');
      inc(pro_const. num_tplus);
    end;

    if (bool_new) then
    begin // если новые или первые
      pro_const. num_tplus := 1; ch_sv := nil; num_sv := 0;
      while not (path_file[pro_const. num_tplus] = '') do
      begin
 // writeLn('new=', path_file[pro_const. num_tplus]);ok;
        p_io_lang_file(path_file[pro_const. num_tplus]);
        load_file_ch_fast(ch_t, path_file[pro_const. num_tplus], sim_comment, false, false);
        p_add_ch_ch(ch_sv, num_sv, ch_t);
        SetLength(in_sv, pro_const. num_tplus +2);
        in_sv[pro_const. num_tplus] := f_expand(path_file[pro_const. num_tplus]);
        in_sv[pro_const. num_tplus +1] := '';
        inc(pro_const. num_tplus);
      end;
      p_ch_end_fast(ch_sv, num_sv);

    end;
    pro_const. num_tplus := 1;
  end;


  function par_cfg_in_str_macros (const str_par_cfg_in_str_macros : string; const num_par_cfg_in_str_macros : byte) : boolean;
  var
    num_t : byte;

  begin
    num_t := 1;
    while (UpCase(GetParConf(pro_const. num_rss, num_par_cfg_in_str_macros, num_t)) <> UpCase(str_par_cfg_in_str_macros)) and
          (GetParConf(pro_const. num_rss, num_par_cfg_in_str_macros, num_t) <> '') do inc(num_t);
    if (UpCase(GetParConf(pro_const. num_rss, num_par_cfg_in_str_macros, num_t)) = UpCase(str_par_cfg_in_str_macros)) then
      par_cfg_in_str_macros := true else par_cfg_in_str_macros := false;

  end;

    function f_lang_re (in_lang_re : string) : string;
    var
      num_t_lang : byte;
      str_t : string;

      procedure p_re_string(in_re_string, out_re_string : string);
      var
        str_lang_out, str_out : string;

      begin
        if (bool_read) then // при макросе @read: не обрезаем
           str_out := out_re_string else
           str_out := length_copy(out_re_string, length_read_string);
        if (pos(sim_lang_id + UpCase(in_re_string), UpCase(in_lang_re)) <> 0) then
        begin
          str_t := f_re_string_pos_start(in_lang_re, sim_lang_id + in_re_string);
          str_lang_out := f_re_string_pos_end(in_lang_re, sim_lang_id + in_re_string);
          // Если id макроса удвоен, то макрос не выполняется
          if (str_t[length(str_t)] <> sim_lang_id) and (not par_cfg_in_str_macros(in_re_string, 29)) then
          begin
            if (str_lang_out[1] <> '_') and (str_lang_out[1] <> sim_exec) then
            begin
              // при символе "#" макросы обрабатываются только тогда, когда чему-то равны
              if not (((str_lang_out[1] = sim_view) or par_cfg_in_str_macros(in_re_string, 30)) and (str_out = '')) then
              begin
                if (str_lang_out[1] = sim_view) then
                  in_lang_re := f_re_string_pos(in_lang_re, sim_lang_id + in_re_string + sim_view, str_out) else
                  in_lang_re := f_re_string_pos(in_lang_re, sim_lang_id + in_re_string, str_out);
              end;
            end;
          end else
          begin
            // если задать переменную daseble в конфиге, то макрос тоже будет не выполнен
            if (not par_cfg_in_str_macros(in_re_string, 29)) then
              in_lang_re := str_t + in_re_string + str_lang_out else
              in_lang_re := str_t + sim_lang_id + in_re_string + str_lang_out;
          end;
        end;
      end;

    var
      lang_in, lang_out : Array[1..22] of string[150];
      lang_in_dt, lang_out_dt : Array[1..7] of string[10];

    begin
      lang_in_dt[ 1] := 'hour';   lang_out_dt[ 1] := hour;
      lang_in_dt[ 2] := 'minute'; lang_out_dt[ 2] := minute;
      lang_in_dt[ 3] := 'second'; lang_out_dt[ 3] := second;
      lang_in_dt[ 4] := 'year';   lang_out_dt[ 4] := year;
      lang_in_dt[ 5] := 'month';  lang_out_dt[ 5] := month_const;
      lang_in_dt[ 6] := 'day';    lang_out_dt[ 6] := day;
      lang_in_dt[ 7] := 'week';   lang_out_dt[ 7] := week_const;

      num_t_lang := 1;
      while not (lang_in_dt[num_t_lang] = '') do
      begin
        p_re_string(priority_id + lang_in_dt[num_t_lang], lang_out_dt[num_t_lang]);
        p_re_string(language_id + lang_in_dt[num_t_lang], lang_out_dt[num_t_lang]);
        p_re_string(lang_in_dt[num_t_lang], lang_out_dt[num_t_lang]);
        inc(num_t_lang);
      end;

      lang_in[ 1] := 'logtime';    lang_out[ 1] := date_and_time(2);
      lang_in[ 2] := 'code';       lang_out[ 2] := pro_lang. convert_code;
      lang_in[ 3] := 'news';       lang_out[ 3] := pro_const. str_teg;
      lang_in[ 4] := 'mode_news';  lang_out[ 4] := f_num2str(pro_const. num_re_str);
      lang_in[ 5] := 'version';    lang_out[ 5] := by_Rain;
      lang_in[ 6] := 'q_macros';   lang_out[ 6] := f_num2str(pro_const. q_macros);
      lang_in[ 7] := 'cycle';      lang_out[ 7] := f_num2str(pro_const. num_cycle);
      lang_in[ 8] := 'number';     lang_out[ 8] := f_num2str(pro_const. num_rss);
      lang_in[ 9] := 'file';       lang_out[ 9] := pro_const. file_ex;
      lang_in[10] := 'msg';        lang_out[10] := f_num2str(pro_const. num_msg);
      lang_in[11] := 'cfg';        lang_out[11] := pro_const. put_file_cfg;
      lang_in[12] := 'program';    lang_out[12] := f_file_name_del_ext(f_prog_name);
      lang_in[13] := 'multi';      if (multi) then lang_out[13] := 'TRUE' else lang_out[13] := 'FALSE';
      lang_in[14] := 'home';       lang_out[14] := f_expand('');
      lang_in[15] := 'assembly';   lang_out[15] := assembly;
      lang_in[16] := 'br';         lang_out[16] := f_enter_wr;
      lang_in[17] := 'q_news';     lang_out[17] := f_num2str(q_news);
      lang_in[18] := 'q_item';     lang_out[18] := f_num2str(q_item);
      lang_in[19] := 'writetime';  lang_out[19] := pro_const. writetime;
      lang_in[20] := 'exist';      lang_out[20] := pro_const. put_file_error_exist;
      lang_in[21] := 'path';       lang_out[21] := pro_const. put_file_error_path;
      lang_in[22] := 'pkt';        lang_out[22] := pro_const. put_file_pkt;

      num_t_lang := 1;
      while not (lang_in[num_t_lang] = '') do
      begin
        p_re_string(priority_id + lang_in[num_t_lang], lang_out[num_t_lang]);
        p_re_string(language_id + lang_in[num_t_lang], lang_out[num_t_lang]);
        p_re_string(lang_in[num_t_lang], lang_out[num_t_lang]);
        inc(num_t_lang);
      end;
      // так же работают макросы из config файла
      for num_t_lang := 1 to GetConstCfg do
      begin
        p_re_string(priority_id + const_cfg[num_t_lang], put_cfg_ver_cp_conv(ParConf[pro_const. num_rss][num_t_lang][pro_const. num_tplus], 866, num_t_lang));
        p_re_string(config_id + const_cfg[num_t_lang], put_cfg_ver_cp_conv(ParConf[pro_const. num_rss][num_t_lang][pro_const. num_tplus], 866, num_t_lang));
        p_re_string(const_cfg[num_t_lang], put_cfg_ver_cp_conv(ParConf[pro_const. num_rss][num_t_lang][pro_const. num_tplus], 866, num_t_lang));
      end;
      // результаты макросов-действий
      for num_t_lang := 1 to GetConstCfg do
      begin
        if (bool_const_cfg[num_t_lang]) then str_t := 'TRUE' else str_t := 'FALSE';
        p_re_string(priority_id + const_cfg[num_t_lang] + bool_id, str_t);
        p_re_string(config_id + const_cfg[num_t_lang] + bool_id, str_t);
        p_re_string(const_cfg[num_t_lang] + bool_id, str_t);
      end;
      // так же работают макросы, установленные в config файле
      num_t_lang := 1;
      while not (pro_const. str_set[num_t_lang] = '') do
      begin
        p_re_string(priority_id + pro_const. str_set[num_t_lang], pro_const. str_reset[num_t_lang]);
        p_re_string(set_id + pro_const. str_set[num_t_lang], pro_const. str_reset[num_t_lang]);
        p_re_string(pro_const. str_set[num_t_lang], pro_const. str_reset[num_t_lang]);
        inc(num_t_lang);
      end;
      // работают параметры, переданные в программу
      if not (pos(sim_lang_id + 'PARAMETER' + '#', UpCase(in_lang_re)) = 0) then
      begin
        num_t_lang := f_str2num(in_lang_re[pos(sim_lang_id + 'PARAMETER' + '#', UpCase(in_lang_re)) + length(sim_lang_id + 'PARAMETER' + '#')]);
        p_re_string('PARAMETER' + '#' + f_num2str(num_t_lang), ParamStr(num_t_lang));
      end;
      if not (pro_const. q_macros = 0) then
      begin
        // работают макросы из template files
        num_t_lang := 0;
        while not (pro_const. template_macros_id[num_t_lang] = '') do
        begin
          p_re_string(priority_id + pro_const. template_macros_id[num_t_lang], pro_const. template_macros[num_t_lang]);
          p_re_string(template_id + pro_const. template_macros_id[num_t_lang], pro_const. template_macros[num_t_lang]);
          p_re_string(pro_const. template_macros_id[num_t_lang], pro_const. template_macros[num_t_lang]);
          inc(num_t_lang);
        end;
      end;
      f_lang_re := in_lang_re;
    end;


    function lang_re_set(const in_str_set, in_str_reset : string) : boolean;
    var
      num_set_t : longint;

    begin

      lang_re_set := false;

      // умеем устанавливать кол-во добавляемых messages
      if (UpCase(in_str_set) = 'Q_NEWS') then
      begin
        pro_const. q_news := f_str2num(in_str_reset);
        if (pro_const. q_news > pro_const. q_item) then
           pro_const. q_news := pro_const. q_item;
        if (pro_const. q_news = 0) then
           pro_const. q_news := 1;
        lang_re_set := true;
      end;
      if (UpCase(in_str_set) = 'CYCLE') then
      begin
        pro_const. num_cycle := f_str2num(in_str_reset);
        lang_re_set := true;
      end;
      if (UpCase(in_str_set) = 'NUMBER') then
      begin
        pro_const. num_rss := f_str2num(in_str_reset);
        if (pro_const. num_rss > pro_const. num_rss_end) or
           (pro_const. num_rss = 0) then
           pro_const. num_rss := 1;
        lang_re_set := true;
      end;

      // зарезервированные макросы в качестве переменных конфиг. файла
      if (not lang_re_set) then
      begin
        num_set_t := 1;
        while (const_cfg[num_set_t] <> '') and
              (UpCase(in_str_set) <> UpCase(const_cfg[num_set_t])) do
          inc(num_set_t);
        if (UpCase(in_str_set) = UpCase(const_cfg[num_set_t])) then
        begin
          SetParConf(put_cfg_ver_cp_conv(in_str_reset, 1251, num_set_t), pro_const. num_rss, num_set_t, pro_const. num_tplus);
          lang_re_set := true;
        end;
      end;

      // установленные макросы в процессе работы программы (@read: или @set)
      if (not lang_re_set) then
      begin
        num_set_t := 1;
        while (pro_const. str_set[num_set_t] <> '') and
              (UpCase(in_str_set) <> UpCase(pro_const. str_set[num_set_t])) do
          inc(num_set_t);
        pro_const. str_reset[num_set_t] := in_str_reset;
        pro_const. str_set[num_set_t] := in_str_set;
        lang_re_set := true;
      end;

    end;

    procedure DelayLang(const num_sec_enter : longint; const lang_id, list_id : string; const bool_sec_enter : boolean);
    var
      num_t_sec_enter : longint;
      str_key : string;

    begin
      num_t_sec_enter := 1; str_key := '';
      // инитим спринтер (бегущую строку)
      if (num_sec_enter = 0) and not (bool_sec_enter) then
        init_sprinter;
      repeat
        // выводим символ на экран
        if (num_sec_enter = 0) then
          sprinter;
        delay(60);

        // очищаем буфер
        if keypressed then
          str_key := readkey;

        pro_const. file_ex := 'exit.ok';
        if file_exist(pro_const. file_ex) then
        begin
          LangList(exit_id, 'file', false);
          str_key := #27;
        end;
        pro_const. file_ex := 'next.ok';
        if file_exist(pro_const. file_ex) then
        begin
          LangList(sys_id, 'file', false);
          str_key := #13;
        end;

        if not (str_key = '') then
        begin
          if (str_key = #0) then
          begin
            str_key := readkey;
            if (rf1f12v(str_key[1])) then
              LangList(key_id, 'F' + rf1f12(str_key[1]), false) else
              str_key := #27; // Alt+... = Esc
          end else
            LangList(key_id, str_key, false);

          if ((str_key = #27) or (UpCase(str_key) = 'N')) or
             ((str_key = #13) or (UpCase(str_key) = 'Y') or (str_key = ' ')) then
            bool_exit := true else
          begin
            str_key := '';
            LangList(lang_id, list_id, false);
          end;

        end;

        inc(num_t_sec_enter);
      until ((num_t_sec_enter > num_sec_enter*10) and not (num_sec_enter = 0) or (bool_sec_enter)) or (bool_exit);
      // удаляем спринтер с экрана
      if (num_sec_enter = 0) and not (bool_sec_enter) then
         kill_sprinter;

      if ((str_key = #13) or (UpCase(str_key) = 'Y') or (str_key = ' ')) then
         bool_exit := false;

      if (bool_exit) then
         LangList(exit_id, 'normal', false);
    end;

    function f_lang_wr (line_wr, lang_wr : string) : string;
    var
      num_t : byte;
      str_t : string;


    begin
      str_t := f_in_per_end (line_wr, lang_wr);
      num_t := 2;
      while (not (str_t[num_t] = '')) and
            (not (str_t[num_t] = ' ')) and
            (not (str_t[num_t] = ',')) and

            // (if - end) '!=' and '='
            (not (str_t[num_t] = '=')) and
            (not (str_t[num_t] = '!')) and

            (not (str_t[num_t] = sim_lang_id)) and
            (not (str_t[num_t] = sim_exec)) do
        inc(num_t);
      num_t := outc(num_t);
      f_lang_wr := Copy(str_t, 1, num_t);

    end;


  function ver_lang_teg (const line, teg_ver : string) : boolean;

  begin
    ver_lang_teg := (UpCase(f_sim_del(line, ' ')) = UpCase('[' + teg_ver + ']'));
  end;

  function LangList (const lang_id, list_id : string; const bool_error_exit : boolean) : boolean;

  var
    line, line_read, line_wk : string;
    lang_end : string = 'END';
    lang_arg1, lang_arg2 : longint;
    lang_arg_str : string;
    num_enter : longint;
    exit_code : longint;
    str_lang_in : string;
    bool_ifend : boolean;
    num_ifend : byte;
     // с первой строки читаем ch_lng
    num_str : longint = 0;
    list_ident : string;


    procedure beep (const freq_beep, delay_beep : longint);

    begin
      Sound(freq_beep);
      delay(delay_beep);
      NoSound;
    end;

    procedure color (const text_color, back_color : longint);

    begin
      TextColor(text_color);
      TextBackGround(back_color);
    end;

    function f_lang_re_str (var line : string; const str_pos : string; var lang_arg1, lang_arg2 : longint) : boolean;

    begin
      if (pos(UpCase(str_pos + sim_lang_id), UpCase(line)) <> 0) then
      begin
        lang_arg1 := f_str2num(f_lang_wr(line, str_pos + sim_lang_id));
        lang_arg_str := f_in_per_end(line, str_pos + sim_lang_id);
        if (pos(',', line) <> 0) then
          lang_arg2 := f_str2num(f_lang_wr(lang_arg_str, ',')) else
          lang_arg2 := 0;

        f_lang_re_str := true;
      end else
        f_lang_re_str := false;
    end;

  begin
    LangList := false;

    if not (lang_id = '') and not (list_id = '') then
    begin // при пустом типе или ID не работаем
    list_ident := lang_id + list_id;
    num_enter := read_ch_enter_all(ch_lng);
    repeat
      line := readLn_ch_to_enter(ch_lng, num_str);
      // ищем в PChar тег, переданный в процедуру
    until (num_str > num_enter) or (ver_lang_teg(line, list_ident));

    // показываем первый экран один раз
    if (ver_lang_teg(line, list_ident)) then
    begin // начало тега
      LangList := true;
      while (num_str < num_enter) and (not ver_lang_teg(line, lang_end)) do
      begin  // пока не конец PChar // пока не конец тега
        line := readLn_ch_to_enter(ch_lng, num_str);

      if not ((num_str < num_enter) and (not ver_lang_teg(line, lang_end))) then
        continue;

         // строка без пробелов по краям
        line_wk := f_start_end_del_simvol(line, ' ');

      // основные макросы language
      // если в строке line_wk нет макроса language, то тогда lang_re(line)
      // макрос в language file должен начинаться с собаки
      if (line_wk[1] = sim_lang_id) and not (line_wk = '') and
         // между символами собака и действие что-нибудь должно быть
         not ((line_wk[1] = sim_lang_id) and (line_wk[2] = sim_exec)) then
      begin // и не равен пустой строке
         // сняли макрос (собаку)
        line_wk := f_re_string_pos_end(line_wk, sim_lang_id);
         // все @end пропускаем...
        if (UpCase(line_wk) = UpCase('end')) then continue;

        lang_arg_str := 'if' + sim_exec;
        if CopyStart(line_wk, lang_arg_str) then
        begin
          lang_arg_str := f_lang_wr(line_wk, lang_arg_str); // макрос
          line_read := f_lang_re(f_in_per_end(line_wk, lang_arg_str)); // после
          if (pos('=', line_read) <> 0) then
          begin
            if (pos('!=', line_read) <> 0) then
            begin
              line_read := f_in_per_end(line_read, '!=');
              bool_ifend := not (f_lang_re(lang_arg_str) = line_read);
            end else
            begin
              line_read := f_in_per_end(line_read, '=');
              bool_ifend := (f_lang_re(lang_arg_str) = line_read);
            end;
            if not (bool_ifend) then
            begin
              num_ifend := 1;
              repeat
                line := readLn_ch_to_enter(ch_lng, num_str);
                line_wk := f_start_end_del_simvol(line, ' ');
                line_wk := f_re_string_pos_end(line_wk, sim_lang_id);
                if CopyStart(line_wk, 'if' + sim_exec) then
                  inc(num_ifend);
                if (UpCase(line_wk) = UpCase('end')) then
                  num_ifend := outc(num_ifend);
              until ((UpCase(line_wk) = UpCase('end')) and (num_ifend = 0)) or
                (num_str > num_enter) or ver_lang_teg(line_wk, lang_end);
            end;

            continue;
          end;
        end;
        // группа: макрос + экран
        if (f_lang_re_str(line_wk, 'delay', lang_arg1, lang_arg2)) and
           not (UpCase(list_ident) = UpCase(sys_id + 'delay')) then
        begin
          LangList(sys_id + 'delay', false);
          DelayLang(lang_arg1, list_ident, false);
          continue;
        end;
        if (UpCase(line_wk) = UpCase('exit')) and
           not (UpCase(list_ident) = UpCase(sys_id + 'macros')) then
        begin
          bool_exit := true;
          LangList(exit_id, 'macros', false);
        end;
        if (UpCase(line_wk) = UpCase('key')) and
           not (UpCase(list_ident) = UpCase(sys_id + 'key')) then
        begin
          LangList(sys_id + 'key', false);
          readkey;
          continue;
        end;
        // одиночные мкросы
        if (UpCase(line_wk) = UpCase('clear')) then
        begin ClrScr; continue; end;
        if (UpCase(line_wk) = UpCase('help')) then
        begin p_par('help', false); continue; end;
        if (UpCase(line_wk) = UpCase('info')) then
        begin p_par('info', false); continue; end;
        if (UpCase(line_wk) = UpCase('copyright')) then
        begin p_wr_copyright(false); continue; end;

        // группа макросов с 1-2 числовыми аргументами
        if (f_lang_re_str(line_wk, 'level', lang_arg1, lang_arg2)) or
           (f_lang_re_str(line_wk, 'errorlevel', lang_arg1, lang_arg2)) then
        begin exit_code := lang_arg1; continue; end;
        if (f_lang_re_str(line_wk, 'error', lang_arg1, lang_arg2)) then
        begin halt(lang_arg1); continue; end;
        if (f_lang_re_str(line_wk, 'length', lang_arg1, lang_arg2)) then
        begin length_read_string := lang_arg1; continue; end;
        if (f_lang_re_str(line_wk, 'beep', lang_arg1, lang_arg2)) then
        begin beep(lang_arg1, lang_arg2); continue; end;
        if (f_lang_re_str(line_wk, 'goto', lang_arg1, lang_arg2)) then
        begin gotoXY(lang_arg1, lang_arg2); continue; end;
        if (f_lang_re_str(line_wk, 'color', lang_arg1, lang_arg2)) then
        begin color(lang_arg1, lang_arg2); continue; end;

        // макросы-действия
        if (not (pos(UpCase(sim_exec), UpCase(line_wk)) = 0)) and
           (not bool_error_exit) and (not bool_exit) then
        begin
          str_lang_in := f_re_string_pos_start(line_wk, sim_exec);
          if GetConstCfgVer(str_lang_in) then
          begin
            lang_arg_str := f_in_per_end(line_wk, sim_exec);
            par_cfg_macros(str_lang_in + sim_exec, lang_arg_str);
            continue;
          end;
        end;
        // все макросы-действия, обозначенные через конфиг.
        if (CopyEnd(line_wk, all_id)) and
           (not bool_error_exit) and (not bool_exit) then
        begin
          if GetConstCfgVer(f_re_string_pos_start(line_wk, all_id)) then
          begin
            par_cfg_macros(line_wk, '');
            continue;
          end;
        end;

      end else // если не найдено ни одного language макроса
        WriteLn(f_lang_re(line));
      end;
      if (bool_exit) then halt(exit_code); // exit prog.
    end;
    if (bool_error_exit) then
    begin
      bool_exit := true;
      LangList(exit_id, 'error', false);
    end;
    end;
  end;

  function GetFirstFile (const ft_in : FirstFile) : string;

  var
    SR : SearchRec;
    num_temp : longint;

  begin
    num_temp := 0;
    repeat
      inc(num_temp);
      FindFirst(f_expand('') + '/' + ft_in[num_temp], AnyFile, SR);
      FindClose(SR);
    until (DosError = 0) or (ft_in[num_temp] = '');
    if not (DosError = 0) then
    begin
      WriteLn('Error search ' + ft_in[1] + ' file in the directory');
      delay(600);
      WriteLn;
      halt(11);
    end else
      GetFirstFile := f_expand(Copy(ft_in[num_temp], 1, pos('/', ft_in[num_temp])) + SR.Name);
  end;


  procedure p_io_lang_file(const put_io_lang_file : string);
  var 
    io_lang_file : text; 

  begin
    if not (f_nix_dir(put_io_lang_file)) then
    begin
      Assign(io_lang_file, put_io_lang_file);
      {$I-} reset(io_lang_file); {$I+}
      if (IOResult <> 0) then
      begin
        WriteLn('Error opening language file: ', put_io_lang_file);
        delay(600);
        WriteLn;
        halt(12);
      end;
      close(io_lang_file);
    end;
  end;

  procedure err_cfg (const put_file_cfg : string);
  var
    path_file : string;

    begin
      WriteLn;
      WriteLn('  Invalid path of file configure');
      WriteLn(' -----------------------------------------');

      if (put_file_cfg = '') then
      path_file := '[NONE]' else
      path_file := put_file_cfg;

      WriteLn('  Path: ', path_file);
      WriteLn;
      delay(1200);
      halt(203);
    end;


end.