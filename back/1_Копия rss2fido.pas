program RSS2FIDO;

uses crt, dos, utf_dos, rain, skMHL, skmhlsq, skmhljam, skmhlmsg, skCommon;

  Type tpar_cfg = Array[1..255] of Array[1..20] of string;
     ppar_cfg = ^tpar_cfg;
  var par_cfg : ppar_cfg;

  Type tch_rss = Array[0..1] of Char;
     pch_rss = ^tch_rss;
  var ch_rss : pch_rss;

var const_cfg : Array[1..25] of string[20];
    default_cfg : Array[1..25] of string;
    def_base : Array[1..5] of string[10];

var
  put_file_out, put_file_rss : string;
  sw_key : string;
  num_t, num_t2, num_tw, num_temp, end_rss : longint;
  rss_name : string;
  load_tpl : Array[1..50] of string[80];
  load_str : Array[1..300] of string;
  num_str : byte;
  file_tpl : text;
  put_template : string;
  num_re_str : byte;
  mega_num_tpl_fix, mega_num_tpl_in_fix : byte;
  str_start_wr, str_end_wr : string;
  SR : SearchRec;
  str_teg : string;
  file_news, file_out : file Of byte;
  fb : byte;
  temp_num : word;
  rss_start : word;
  tpl_tstr : string;
  by_Rain : string;
  comv_sw : string;
  put_lang : string;
  file_lang : text;
  debage : boolean;
  bool_exit : boolean;
  multi : boolean;
  put_file_cfg : string;
  put_file_error_open : string;
  line : string;
  num_rss, num_rss_end : word;
  put_file_master : string;
  put_file_post : string;
  num_cycle : longint;
  rss_name_id : string;
  back_in_put, back_put_lang : string;
  str_sim_par_cfg : string;
  file_ex : string;
  post_in_base, post_out_base : string;
  num_msg : longint;
  atr_msg, re_atr_msg : Array[1..20] of string[10];
  atr_in_msg : Array[1..20] of longint;
  file_cp_out : string;
  bool_del_out : boolean;
  const_lang_name : Array[1..5] of string;

  lang_in, lang_out : Array[1..50] of string;
  num_t_lang : byte;
  str_lang_in, str_lang_out : string;
  pos_out_lang : byte;
  sim_lang_id : Char;
  sim_comment : Char;

  bool_start_rss : boolean;
  str_set, str_reset : Array[1..255] of string;
  num_set : byte;
  num_end_rss : longint;


  function f_num2str (num_tmp_fns : Longint) : string;
  begin
    str (num_tmp_fns, f_num2str);
  end;
  function f_str2num (str_tmp_fsn : string) : Longint;
  begin
    val (str_tmp_fsn, f_str2num);
  end;
  function outc (in_outc : longint) : longint;
  begin
    outc := in_outc - 1;
  end;

  function file_exist (put_file_exist : string) : boolean;
  var
    SR_file_exit : SearchRec;

  begin
    FindFirst(put_file_exist, AnyFile, SR_file_exit);

    if (DosError <> 0) then
    begin
      FindClose(SR_file_exit);
      file_exist := false; //  не файл, не область
    end
    else
    begin
      FindClose(SR_file_exit);
      FindFirst(put_file_exist + '\*', AnyFile, SR_file_exit);
      if (DosError <> 0) then
      begin
        file_exist := true; // файл
      end
      else
      begin
        file_exist := false; // область
      end;
    end;

  end;


  function file_exist_io (put_file_exist : string) : boolean;
  var
    file_exist_file : text;

  begin

    assign (file_exist_file, put_file_exist);
{$I-}
    reset (file_exist_file);
    close (file_exist_file);
{$I+}
    if IOResult <> 0 then
      file_exist_io := false
                     else
      file_exist_io := true;

  end;

  function f_nol2(string_plus_nol : string) : string;

  begin
    while Length (string_plus_nol) < 2 do
      string_plus_nol := '0' + string_plus_nol;

    f_nol2 := string_plus_nol;
  end;

  Function f_get_time : string;
  var
    hour, min, sec, ssec : Word;

  begin
    GetTime (hour, min, sec, ssec);
    f_get_time := f_nol2(f_num2str(hour)) + ':' + f_nol2(f_num2str(min)) + ':' + f_nol2(f_num2str(sec));

  end;

  Function f_get_date : string;
  var
    Year, M, Day, D: Word;

  begin
    GetDate(Year, M, Day, D);
    f_get_date := f_nol2(f_num2str(Day)) + '-' + f_nol2(f_num2str(M)) + '-' + f_nol2(f_num2str(Year));

  end;


  function f_date_time(num_ind : byte) : string;
Const mec_con_full : Array [1..12] Of String[10] =
('January', 'February', 'March', 'April', 'May', 'June', 
'July', 'August', 'September', 'October', 'November', 'December');


  begin
    if num_ind = 0 then
      f_date_time := f_get_date + ' ' + f_get_time;
    if num_ind = 1 then
      f_date_time := Copy(f_get_date, 1, 2) + ' ' + copy(mec_con_full[f_str2num(Copy(f_get_date, 4, 2))], 1, 3) + ' ' + f_get_time;
    if num_ind = 2 then
      f_date_time := Copy(f_get_date, 1, 2) + '-' + copy(mec_con_full[f_str2num(Copy(f_get_date, 4, 2))], 1, 3) + '-' + Copy(f_get_date, 7, 4) + ' ' + f_get_time;

 //   writeLn(f_date_time);
  end;

  function f_re_sim_sl (re_sim_sl : string) : string;
  var
    re_sim_sl_t : string;

  begin
    re_sim_sl_t := re_sim_sl + '\';
    while (pos('\', re_sim_sl_t) <> 0) do
      re_sim_sl_t := Copy(re_sim_sl_t, 1, pos('\', re_sim_sl_t) -1) + '/' + Copy(re_sim_sl_t, pos('\', re_sim_sl_t) +1, length(re_sim_sl_t) - pos('\', re_sim_sl_t));

    if (re_sim_sl_t[length(re_sim_sl_t)] = '/') then
      re_sim_sl_t := Copy(re_sim_sl_t, 1, length(re_sim_sl_t) -1);
    f_re_sim_sl := re_sim_sl_t;
  end;

  function f_expand(in_put_file_expand : string) : string;
  var
    put_prog_file, put_prog_dir : string;

  begin
    put_prog_file := ParamStr(0);
    num_t := length(put_prog_file);
    while (copy(put_prog_file, num_t, 1) <> '/') and (copy(put_prog_file, num_t, 1) <> '\') do
      num_t := outc(num_t);
    put_prog_dir := Copy(put_prog_file, 1, num_t);

    if (pos('/', in_put_file_expand) = 0) and (pos('\', in_put_file_expand) = 0) then
      in_put_file_expand := put_prog_dir + in_put_file_expand;

    f_expand := f_re_sim_sl(in_put_file_expand);
  end;

  function f_file_ext (path_sp : string) : string;

  begin
    num_t := length(put_file_master);
    while (put_file_master[num_t] <> '.') and
          (put_file_master[num_t] <> '') and
          (num_t > 0) do
      num_t := outc(num_t);

    if (num_t > 0) and (put_file_master[num_t] <> '') and
       (put_file_master[num_t] = '.') then
      f_file_ext := Copy(put_file_master, num_t +1, length(put_file_master) - num_t)
                                      else
      f_file_ext := '';
  end;

    function f_lang_re (in_lang_re : string; in_num_rss : word) : string;

      procedure p_re_string(in_re_string, out_re_string : string);

      begin
        if (pos(sim_lang_id + UpCase(in_re_string), UpCase(in_lang_re)) <> 0) and 
           (in_lang_re[1] <> sim_comment) then
        begin
          str_lang_in := Copy(in_lang_re, 1, pos(UpCase(sim_lang_id + in_re_string), UpCase(in_lang_re)) -1);
          pos_out_lang := pos(UpCase(sim_lang_id + in_re_string), UpCase(in_lang_re)) + length(in_re_string);
          str_lang_out := Copy(in_lang_re, pos_out_lang +1, length(in_lang_re) - pos_out_lang);
          if (str_lang_out[1] <> '_') then
            in_lang_re := str_lang_in + out_re_string + str_lang_out;
        end;
      end;

    begin
      lang_in[1] := 'rss'; lang_out[1] := put_file_rss;
      lang_in[2] := 'logtime'; lang_out[2] := f_date_time(2);
      lang_in[3] := 'code'; lang_out[3] := comv_sw;
      lang_in[4] := 'news'; lang_out[4] := str_teg;
      lang_in[5] := 'mode_news'; lang_out[5] := f_num2str(num_re_str);
      lang_in[6] := 'version'; lang_out[6] := by_Rain;
      lang_in[7] := 'cfg'; lang_out[7] := put_file_cfg;
      lang_in[8] := 'open'; lang_out[8] := put_file_error_open;
      lang_in[9] := 'cycle'; lang_out[9] := f_num2str(num_cycle);
      lang_in[10] := 'number'; lang_out[10] := f_num2str(in_num_rss);
      lang_in[11] := 'file'; lang_out[11] := file_ex;
      lang_in[12] := 'msg'; lang_out[12] := f_num2str(num_msg);
      lang_in[13] := 'kill'; if bool_del_out then lang_out[13] := 'TRUE' else lang_out[13] := 'FALSE';

      num_t_lang := 1;
      while (lang_in[num_t_lang] <> '') do
      begin
        p_re_string(lang_in[num_t_lang], lang_out[num_t_lang]);
        inc(num_t_lang);
      end;
      // так же работают макросы из config файла
      num_t_lang := 1;
      while (const_cfg[num_t_lang] <> '') do
      begin
        p_re_string(const_cfg[num_t_lang], par_cfg^[in_num_rss][num_t_lang]);
        inc(num_t_lang);
      end;
      // так же работают макросы, установленные в config файле
      num_t_lang := 1;
      while (str_set[num_t_lang] <> '') do
      begin
        p_re_string(str_set[num_t_lang], str_reset[num_t_lang]);
        inc(num_t_lang);
      end;

      f_lang_re := in_lang_re;
    end;


  procedure p_lang (str_p_lang : string);
    label g_bool_exit;

  var
    line_lang : string;
    lang_clear : string;
    lang_and : string;
    sim_in, sim_out : Char;
    num_in, num_out : byte;
    put_file_lang_wr : string;
    file_lang_wr : text;
    lang_delay, lang_freq : longint;


    function f_lang_wr (line_lang_wr, lang_wr : string) : string;

    begin
      if (lang_wr <> '') then
      begin
        pos_out_lang := pos(sim_lang_id + UpCase(lang_wr), UpCase(line_lang_wr)) + length(sim_lang_id + lang_wr);
        str_lang_in := Copy(line_lang_wr, pos_out_lang, length(line_lang_wr) - pos_out_lang);
      end else
        str_lang_in := line_lang_wr;

      num_in := 1;
      while Copy(str_lang_in, num_in, 1) = ' ' do
        inc(num_in);
      num_out := num_in +1;
      while (Copy(str_lang_in, num_out, 1) <> ' ') and
            (Copy(str_lang_in, num_out, 1) <> chr($0D)) and
            (Copy(str_lang_in, num_out, 1) <> ',') and
            (Copy(str_lang_in, num_out, 1) <> sim_lang_id) do
        inc(num_out);
      f_lang_wr := Copy(str_lang_in, num_in, num_out - num_in);
    end;


    procedure p_sec_enter(num_sec_enter : longint);
    var
      num_t_sec_enter : longint;

    begin
      while keypressed do
        sw_key := readkey;

      num_t_sec_enter := 1; sw_key := '';
      repeat
        if keypressed then
          sw_key := readkey;

        delay(60);

        file_ex := 'exit.ok';
        if file_exist(file_ex) then
        begin
          p_lang('file');
          sw_key := #27;
        end;
        file_ex := 'next.ok';
        if file_exist(file_ex) then
        begin
          p_lang('file');
          sw_key := #13;
        end;

        inc(num_t_sec_enter);
      until (num_t_sec_enter > num_sec_enter*10) or (sw_key = #13) or (sw_key = #27);
      if (sw_key = #27) then bool_exit := true;
    end;

    procedure beep (freq_beep, delay_beep : longint);

    begin
      Sound(freq_beep);
      delay(delay_beep);
      NoSound;
    end;

  begin
    sim_in := '['; sim_out := ']';
    lang_clear := 'Clear';
    lang_and := 'END';
g_bool_exit:
    close(file_lang);
    reset(file_lang);
    line_lang := '';
    readLn(file_lang, line_lang);
    while (not eof(file_lang)) and (pos(sim_in + UpCase(str_p_lang) + sim_out, UpCase(line_lang)) = 0) do
      readLn(file_lang, line_lang);

    if (pos(sim_in + UpCase(str_p_lang) + sim_out, UpCase(line_lang)) <> 0) and 
       (Copy(line_lang, 1, 1) <> sim_comment) then
    begin
      readLn(file_lang, line_lang);
      while (not eof(file_lang)) and
            (pos(sim_in + UpCase(lang_and) + sim_out, UpCase(line_lang)) = 0) do
      begin
        if (Copy(line_lang, 1, 1) <> sim_comment) then
        begin
        line_lang := line_lang + chr($0D) + chr($0A); // Enter
        if (pos(sim_lang_id + UpCase(lang_clear), UpCase(line_lang)) <> 0) then
        begin
          ClrScr;
          readLn(file_lang, line_lang);
          continue;
        end;
        if (pos(sim_lang_id + UpCase('delay:'), UpCase(line_lang)) <> 0) then
        begin
          lang_delay := f_str2num(f_lang_wr(line_lang, 'delay:'));
          p_sec_enter(lang_delay);
          if bool_exit then
          begin
            str_p_lang := 'exit';
            goto g_bool_exit;
          end;

          readLn(file_lang, line_lang);
          continue;
        end;

        if (pos(sim_lang_id + UpCase('beep:'), UpCase(line_lang)) <> 0) then
        begin
          lang_freq := f_str2num(f_lang_wr(line_lang, 'beep:'));
          lang_delay := f_str2num(f_lang_wr(Copy(line_lang, pos(',', line_lang) +1, length(line_lang) - pos(',', line_lang)), ''));
          beep(lang_freq, lang_delay);
          readLn(file_lang, line_lang);
          continue;
        end;

        if (pos(sim_lang_id + UpCase('file:'), UpCase(line_lang)) <> 0) then
        begin

          put_file_lang_wr := f_lang_wr(line_lang, 'file:');
          line_lang := Copy(str_lang_in, num_out, length(str_lang_in) - num_out);

          line_lang := f_lang_re(line_lang, num_rss);

          if (pos('/', put_file_lang_wr) = 0) and (pos('\', put_file_lang_wr) = 0) then
            put_file_lang_wr := f_expand(put_file_lang_wr);

          Assign(file_lang_wr, put_file_lang_wr);
          if not file_exist(put_file_lang_wr) then
          begin
            rewrite(file_lang_wr);
            if UpCase(Copy(put_file_lang_wr, length(put_file_lang_wr) -3, 4)) = '.LOG' then
              WriteLn(file_lang_wr, ' ' + f_date_time(2) + ' Logfile created ' + by_Rain);
          end
                                              else
          begin

            append(file_lang_wr);
          end;
          WriteLn(file_lang_wr, line_lang);
          close(file_lang_wr);

          readLn(file_lang, line_lang);
          continue;
        end;

        line_lang := f_lang_re(line_lang, num_rss);
        Write(line_lang); // - Enter
        end;
        readLn(file_lang, line_lang);
      end;
      if bool_exit then halt; // exit prog.
    end;
  //  close(file_lang);

  end;

  function f_pos_file_news(str_verif : string; temp_num_dec : integer) : boolean;
  var
    temp_nsvs : word;
    temp_str_verif : string;

  begin
    temp_str_verif := '';
    temp_num := temp_num + temp_num_dec;
    temp_nsvs := temp_num;
    while temp_num < temp_nsvs + length (str_verif) do
    begin
      temp_str_verif := temp_str_verif + ch_rss^[temp_num];
      inc (temp_num);
    end;
    temp_num := temp_nsvs;
    temp_num := temp_num - temp_num_dec;
    if UpCase(temp_str_verif) = UpCase(str_verif) then
      f_pos_file_news := true
    else
      f_pos_file_news := false;
  end;

  procedure p_news_add;
  var
    temp_num_dec_read : byte;

    procedure p_write_add (str_news_begin : string);
    var
      num_tmp_begin : byte;

    begin
      num_tmp_begin := 1;
      while Copy(str_news_begin, num_tmp_begin, 1) <> '' do
      begin
        write (file_out, ord(Copy(str_news_begin, num_tmp_begin, 1)[1]));
        inc (num_tmp_begin);
      end;
    end;


  procedure p_dec_start;

  begin
    p_write_add(str_start_wr);
 
  end;

  procedure p_dec_end (num_pdee : byte);
  var
    num_dec_end : byte;

  begin
    num_dec_end := 1;
    while num_dec_end <= num_pdee do
    begin
      write (file_out, ord(' '));
      inc (num_dec_end);
    end;
    if num_dec_end >= num_pdee then
       p_write_add(str_end_wr);


  end;

  function f_rss_start (start_rss, str_end_rss : string) : boolean;

  begin
    while (f_pos_file_news (start_rss, 0) <> true) and (f_pos_file_news (str_end_rss, 0) <> true) and (temp_num < end_rss) do
    begin
      inc (temp_num);
    end;
    if (f_pos_file_news (str_end_rss, 0) = true) or (temp_num >= end_rss) then
    begin
      temp_num := end_rss;
      f_rss_start := true;
    end else
      f_rss_start := false;

    rss_start := temp_num;
  end;


  function f_pnaddapp2(str_1, str_2 : string) : boolean;

  begin
    temp_num := rss_start;

    while (f_pos_file_news (str_1, 0) <> true) and (f_pos_file_news ('</item>', 0) <> true) and (temp_num < end_rss) do
      inc (temp_num);

    if (f_pos_file_news (str_1, 0) = true) and (temp_num < end_rss) then
    begin
      while (f_pos_file_news (str_2, 0) <> true) and (f_pos_file_news ('</item>', 0) <> true) and (temp_num < end_rss) do
      begin
        inc (temp_num);
      end;
      if (f_pos_file_news (str_2, 0) = true) or (temp_num >= end_rss) then
      begin
        f_pnaddapp2 := true;
        exit;
      end;
      f_pnaddapp2 := false;
    end;
    f_pnaddapp2 := false;
  end;


  procedure p_news_add_append (str_pnaa1, str_pnaa2 : string; num_pnaa1 : byte);
  var
      bool_inc_wrstr : boolean;
      temp_num_dec1 : word;
      num_str_del : byte;

      procedure p_re_sim_in_file_news (in_re_sim_in_file_news, out_re_sim_in_file_news : string);

      begin
        if (f_pos_file_news (in_re_sim_in_file_news, 0)) then
        begin
          load_str[num_str] := load_str[num_str] + out_re_sim_in_file_news;
          bool_inc_wrstr := false;
          temp_num := temp_num + length(in_re_sim_in_file_news);
          temp_num_dec_read := temp_num_dec_read + length(out_re_sim_in_file_news);
        end;
      end;

  begin

    temp_num := rss_start;
    while (not f_pos_file_news (str_pnaa1, 0)) and (temp_num < end_rss) do
      inc (temp_num);
    if (temp_num >= end_rss) then
      exit;
    p_lang('news_add');

    num_str := 0;
    temp_num := temp_num + length (str_pnaa1);
    while (not f_pos_file_news (str_pnaa2, 0)) and
          (not f_pos_file_news (str_pnaa1, 0)) and (temp_num < end_rss) do
    begin
      inc(num_str);
      load_str[num_str] := str_start_wr;
      temp_num_dec_read := 1;
      while (not f_pos_file_news (str_pnaa2, 0)) and
        (not f_pos_file_news (str_pnaa1, 0)) and (temp_num < end_rss) and
        (temp_num_dec_read < mega_num_tpl_fix - mega_num_tpl_in_fix) do
      begin
        bool_inc_wrstr := true;

        if (f_pos_file_news (chr($0A), 0)) or
           ((f_pos_file_news ('&lt;br', 0)) and (not f_pos_file_news ('&lt;br /&gt;' + chr($0A), 0)) and (not f_pos_file_news ('&lt;br /&gt;' + chr($0D), 0))) or
           (f_pos_file_news ('&lt;b&gt;', 0)) then
        begin
          // нашли Enter
          f_string_fix(load_str[num_str], mega_num_tpl_fix - mega_num_tpl_in_fix);
          load_str[num_str] := load_str[num_str] + ' ' + str_end_wr;
          num_str := num_str +1;
          load_str[num_str] := str_start_wr;
          temp_num_dec_read := 1;
          if (f_pos_file_news (chr($0A), 0)) then 
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

      if (f_pos_file_news ('&lt;', 0)) then
      begin
        // не записываем в файл все то, что заключено между '&lt;' и '&gt;'
        temp_num_dec1 := 1;
        while (not f_pos_file_news (str_pnaa2, temp_num_dec1)) and
              (not f_pos_file_news ('&gt;', temp_num_dec1)) and
              (not f_pos_file_news ('&lt;', temp_num_dec1)) do
        begin
          inc(temp_num_dec1);
        end;
        if (f_pos_file_news ('&gt;', temp_num_dec1)) then
        begin
          temp_num := temp_num + temp_num_dec1 + length('&gt;');
          bool_inc_wrstr := false;
        end;
      end;
      if (f_pos_file_news ('&amp;lt;', 0)) then
      begin
        // не записываем в файл все то, что заключено между '&amp;lt;' и '&amp;gt;'
        temp_num_dec1 := 1;
        while (not f_pos_file_news (str_pnaa2, temp_num_dec1)) and
              (not f_pos_file_news ('&amp;gt;', temp_num_dec1)) and
              (not f_pos_file_news ('&lt;', temp_num_dec1)) do
        begin
          inc(temp_num_dec1);
        end;
        if (f_pos_file_news ('&amp;gt;', temp_num_dec1)) then
        begin
          temp_num := temp_num + temp_num_dec1 + length('&amp;gt;');
          bool_inc_wrstr := false;
        end;
      end;

        if bool_inc_wrstr then
        begin
          load_str[num_str] := load_str[num_str] + ch_rss^[temp_num];
          // если в файл что-то не записывалось, 
          // то круг считается не пройденным
          inc(temp_num_dec_read);
          inc(temp_num);
        end;
      end;

      if (f_pos_file_news (str_pnaa2, 0)) then
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
        p_write_add(load_str[num_str]);
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
      p_write_add(load_str[1]);
    end;

  end;


  begin
    if f_rss_start('<item>', '</rss>') = true then
      exit;
    p_write_add(#01 + 'PID: ' + by_Rain);
    num_t2 := 1;
    while load_tpl[num_t2] <> '' do
    begin
      if (pos('@', (load_tpl[num_t2])) <> 0) and
         (pos(',[', (load_tpl[num_t2])) <> 0) and
         (pos(']', (load_tpl[num_t2])) <> 0) and
         (pos(',', (load_tpl[num_t2])) <> 0) then
      begin
        str_teg := Copy(load_tpl[num_t2], pos('@', (load_tpl[num_t2])) +1, length(load_tpl[num_t2]) - (pos('@', (load_tpl[num_t2]))));
        str_teg := Copy(str_teg, 1, pos(',', str_teg) -1);

        mega_num_tpl_in_fix := pos(UpCase('@' + str_teg + ','), UpCase(load_tpl[num_t2])) -1;
        num_re_str := f_str2num(Copy(load_tpl[num_t2], pos(UpCase('@' + str_teg + ','), UpCase(load_tpl[num_t2])) + length('@' + str_teg + ','), 1));
        tpl_tstr := Copy(load_tpl[num_t2], pos(UpCase('@' + str_teg + ','), UpCase(load_tpl[num_t2])) + length('@' + str_teg + ',') + 3, length(load_tpl) - (pos(UpCase('@' + str_teg + ','), UpCase(load_tpl[num_t2])) + length('@' + str_teg + ',') + 3));
        tpl_tstr := Copy(tpl_tstr, 1, pos(']', tpl_tstr) -1);
        mega_num_tpl_fix := f_str2num(tpl_tstr);
        if mega_num_tpl_fix < mega_num_tpl_in_fix then
          mega_num_tpl_fix := mega_num_tpl_in_fix;
        str_start_wr := Copy(load_tpl[num_t2], 1, mega_num_tpl_in_fix);
        str_end_wr := Copy(load_tpl[num_t2], pos(UpCase('@' + str_teg + ','), UpCase(load_tpl[num_t2])) + length('@' + str_teg + ',') + 1 + length(tpl_tstr) + 3, length(load_tpl[num_t2]) - ( pos(UpCase('@' + str_teg + ','), UpCase(load_tpl[num_t2])) + length('@' + str_teg + ',') + length(tpl_tstr) + 3));

        if f_pnaddapp2 ('<' + str_teg + '>', '</' + str_teg + '>') then
          p_news_add_append ('<' + str_teg + '>', '</' + str_teg + '>', num_re_str)
                                                                   else
        begin
          p_write_add(f_string_fix(str_start_wr, mega_num_tpl_in_fix) + str_end_wr);
          p_lang('error_news');
        end;
        inc(num_t2);
        continue;
      end;
      p_write_add(UpCase(load_tpl[num_t2]));
      inc(num_t2);
    end;

    if f_rss_start('</item>', '</rss>') = true then
      exit;

  end;

  procedure p_new_add_in_one_msg(put_file_out : string; num_msg : byte);
  var
    num_msg_t : byte;

  begin
    num_msg_t := 0;
    Assign (file_out, put_file_out);
    rewrite (file_out);
     while (temp_num < end_rss) and (num_msg_t < num_msg) do
    begin
      p_news_add;
      inc(num_msg_t);
    end;
    close(file_out);
  end;

  procedure file_erase(put_file_erase : string);
  var
    file_erase : text;

  begin
    Assign(file_erase, put_file_erase);
    erase(file_erase);
  end;

  procedure p_file_rename (rename_in, rename_out : string);
  var
    file_rename : text;

  begin
    Assign(file_rename, rename_in);
    if file_exist(rename_out) then
      file_erase(rename_out);
    Rename(file_rename, rename_out);

  end;

  function f_file_size(put_file_size : string) : longint;
  var
    file_size : file of byte;

  begin
    Assign(file_size, put_file_size);
    reset(file_size);
    f_file_size := FileSize(file_size);
    close(file_size);

  end;

  function auto_code(ch_auto_code : ch1; end_auto_code : longint) : string;
  var
    num_ac_t : longint;
    num_ac_t_c : longint;
    srt_ac_tc : string;
    bool_code_yes : boolean;

  begin
    num_ac_t := 0; bool_code_yes := false;
    while (num_ac_t + length('encoding=') +1 < end_auto_code) and (bool_code_yes = false) do
    begin
      num_ac_t_c := 1; srt_ac_tc := '';
      while num_ac_t_c <= length('encoding=') +1 do
      begin
        srt_ac_tc := srt_ac_tc + ch_auto_code^[num_ac_t + num_ac_t_c];
        inc(num_ac_t_c);
      end;
      if (UpCase(srt_ac_tc) = UpCase('encoding=' + #39)) or
         (UpCase(srt_ac_tc) = UpCase('encoding=' + #34)) then
      begin
        num_ac_t := num_ac_t + length('encoding=') +1 +1;
        num_ac_t_c := num_ac_t;
        repeat
          inc(num_ac_t_c);
        until (ch_auto_code^[num_ac_t_c] = #39) or (ch_auto_code^[num_ac_t_c] = #34);
        srt_ac_tc := '';
        while num_ac_t <= num_ac_t_c -1 do
        begin
          srt_ac_tc := srt_ac_tc + ch_auto_code^[num_ac_t];
          inc(num_ac_t);
        end;
        auto_code := UpCase(srt_ac_tc);
        bool_code_yes := true;
      end;
      inc(num_ac_t);
    end;

    if bool_code_yes = false then
      auto_code := 'NONE_CODE';

  end;

  procedure p_io_file(put_in_io_file : string);
  var
    in_io_file : text;

  begin
    Assign(in_io_file, put_in_io_file);
{$I-}
    reset(in_io_file);
{$I+}
    if IOResult <> 0 then
    begin
      put_file_error_open := put_in_io_file;
      p_lang('error_open');
      bool_exit := true;
      p_lang('error_exit');
    end;
    close(in_io_file);
  end;

  function f_open_first_file (foff_file, foff_lang_string : string) : string;

  begin

    FindFirst(f_expand('') + '/' + '*.' + foff_file, AnyFile, SR);
    if DosError = 0 then
      f_open_first_file := f_expand(SR.Name)
                    else
    begin
      p_lang(foff_lang_string);
      bool_exit := true;
      p_lang('error_exit');
    end;
    FindClose(SR);
    if (pos('/', f_open_first_file) = 0) and (pos('\', f_open_first_file) = 0) then
      f_open_first_file := f_expand(f_open_first_file);

    p_io_file(f_open_first_file);

  end;

  function f_sim_del(in_sim_del : string; sim_del : Char) : string;
  var
    in_sim_del_t : string;

  begin
    in_sim_del_t := in_sim_del;
    while (pos(sim_del, in_sim_del_t) <> 0) do
      in_sim_del_t := Copy(in_sim_del_t, 1, pos(sim_del, in_sim_del_t) -1) + Copy(in_sim_del_t, pos(sim_del, in_sim_del_t) +1, length(in_sim_del_t) - pos(sim_del, in_sim_del_t));

    f_sim_del := in_sim_del_t;
  end;

  procedure p_read_cfg(put_file_in_read_cfg : string);

  var
    file_in_read_cfg : text;
    sim_comment : Char;
    num_cfg_name_par : word;
    num_const_cfg : byte;
    str_def_cfg : string;
    num_def_cfg : byte;
    str_def_set : string;
    num_set_t : byte;
    str_set_t : string;


    function f_in_per_end(in_per_end, out_per_and : string) : string;

      function f_col_sim_str(col_sim_str : string; col_sim_str_char : char) : byte;
      var
        col_sim, col_sim_t : byte;
        col_sim_str_t : string;

      begin
        col_sim_t := 1; col_sim := 0;
        col_sim_str_t := Copy(col_sim_str, col_sim_t, 1);
        while col_sim_str_t <> '' do
        begin
          if col_sim_str_t = col_sim_str_char then
            inc(col_sim);
          inc(col_sim_t);
          col_sim_str_t := Copy(col_sim_str, col_sim_t, 1);
        end;
        f_col_sim_str := col_sim;
      end;

      function f_sim_in_out_del (sim_in_out_del : string; sim_in_out : Char) : string;
      var
        sim_in_out_del_t : string;
        pos_sim_in_out_del : byte;

      begin
        sim_in_out_del_t := sim_in_out_del;
        pos_sim_in_out_del := pos(sim_in_out, sim_in_out_del_t);
        sim_in_out_del_t := Copy(sim_in_out_del_t, pos_sim_in_out_del +1, length(sim_in_out_del_t) - pos_sim_in_out_del);
        pos_sim_in_out_del := pos(sim_in_out, sim_in_out_del_t);
        sim_in_out_del_t := Copy(sim_in_out_del_t, 1, pos_sim_in_out_del -1);

        f_sim_in_out_del := sim_in_out_del_t;
      end;

      function f_del_in (del_in, del_out : string) : string;

      begin
        f_del_in := Copy(del_in, length(del_out) +1, length(del_in) - length(del_out));
      end;

    begin
      in_per_end := f_del_in(in_per_end, out_per_and);

      num_t := 1;
      while (Copy(in_per_end, num_t, 1) = ' ') do
        inc(num_t);
      in_per_end := copy(in_per_end, num_t, length(in_per_end) - num_t +1);
      num_t := length(in_per_end);
      while (Copy(in_per_end, num_t, 1) = ' ') do
        num_t := outc(num_t);
      in_per_end := copy(in_per_end, 1, num_t);
      if (pos('"', in_per_end) <> 0) then
      begin
        if f_col_sim_str(in_per_end, '"') = 2 then
          in_per_end := f_sim_in_out_del(in_per_end, '"') else
          in_per_end := f_sim_del(in_per_end, '"');
       end;
      f_in_per_end := in_per_end;
    end;


  begin
    num_t := 1;
    while (default_cfg[num_t] <> '') do
    begin
      default_cfg[num_t] := '';
      inc(num_t);
    end;

    sim_comment := ';';
    Assign(file_in_read_cfg, put_file_in_read_cfg);
    reset(file_in_read_cfg);
    readLn(file_in_read_cfg, line);
    num_cfg_name_par := 0; num_set := 0;
    while (not eof(file_in_read_cfg)) do
    begin
      if (Copy(line, 1, 1) <> sim_comment) then
      begin

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
             (str_def_set[1] = '@') then
          begin
            str_set_t := Copy(str_def_set, 2, pos(' ', str_def_set) -2);
            num_set_t := 1;
            while (str_set[num_set_t] <> '') and
                  (UpCase(str_set_t) <> UpCase(str_set[num_set_t])) do
              inc(num_set_t);
            if (UpCase(str_set_t) <> UpCase(str_set[num_set_t])) then
            begin
              inc(num_set);
              str_reset[num_set] := f_in_per_end(str_def_set, '@' + str_set_t);
              str_set[num_set] := str_set_t;
            end else
            begin
              str_reset[num_set_t] := f_in_per_end(str_def_set, '@' + str_set_t);
              str_set[num_set_t] := str_set_t;
            end;
          end;
        end;

        num_const_cfg := 1;
        if ((UpCase(Copy(line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) and (not bool_start_rss)) or
           (UpCase(Copy(line, 1, length('[start_rss]'))) = UpCase('[start_rss]')) then
        begin
          // если найдено [start_rss], то группа не может начинаться с Name
          if (UpCase(Copy(line, 1, length('[start_rss]'))) = UpCase('[start_rss]')) then
            bool_start_rss := true;

          if (num_cfg_name_par > 0) and
             (par_cfg^[num_cfg_name_par][8] = '') and
             (par_cfg^[num_cfg_name_par][3] = '') then
            // если post_base не задано, то post будет задано из default
            par_cfg^[num_cfg_name_par][3] := default_cfg[3];

          inc(num_cfg_name_par);

          num_def_cfg := 1;
          while (const_cfg[num_def_cfg] <> '') do
          begin
             // Если параметр в группе не задан
            if (par_cfg^[num_cfg_name_par][num_def_cfg] = '') and
               (default_cfg[num_def_cfg] <> '') then
              begin
               if (UpCase(post_out_base) <> UpCase(const_cfg[num_def_cfg])) then // если внутренний постер не задан, будет использоваться внешний
                 par_cfg^[num_cfg_name_par][num_def_cfg] := f_lang_re(default_cfg[num_def_cfg], num_cfg_name_par);
              end;
            inc(num_def_cfg);
          end;
        end;
        // если найдено Name после [start_rss] или найдено [end_rss],
        // то тогда группа снова может начинаться с Name
        if (UpCase(Copy(line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) or
           (UpCase(Copy(line, 1, length('[end_rss]'))) = UpCase('[end_rss]')) then
           bool_start_rss := false;

        while (const_cfg[num_const_cfg] <> '') do
        begin
          if (UpCase(Copy(line, 1, length(const_cfg[num_const_cfg] + ' '))) = UpCase(const_cfg[num_const_cfg] + ' ')) then
            par_cfg^[num_cfg_name_par][num_const_cfg] := f_lang_re(f_in_per_end(line, const_cfg[num_const_cfg]), num_cfg_name_par);
          inc(num_const_cfg);
        end;
      end;
      readLn(file_in_read_cfg, line);
    end;
    num_rss_end := num_cfg_name_par;

  end;

  procedure p_io_lang_file(put_io_lang_file : string);

  begin
    Assign(file_lang, put_lang);
    {$I-} reset(file_lang); {$I+}
    if IOResult <> 0 then
    begin
      WriteLn('Error open: ', put_lang);
      halt;
    end;
  end;

  procedure p_load_template;

  begin
    Assign(file_tpl, put_template);
    reset(file_tpl);
    num_t := 1;
    while not eof(file_tpl) do
    begin
      readLn(file_tpl, load_tpl[num_t]);
      load_tpl[num_t] := load_tpl[num_t] + chr($0D) + chr($0A);
      if Copy(load_tpl[num_t], 1, 1) <> ';' then
        inc(num_t);
      load_tpl[num_t] := '';
    end;
 // close(file_tpl);
  end;

  procedure p_rss_verif(put_file_rss : string);

  begin

    if (put_file_rss = '') or (pos('://', put_file_rss) = 0) then
    begin
      p_lang('error_RSS');
      bool_exit := true;
      p_lang('error_exit');
    end;
  end;

  function rss_old : boolean;
  var
    file_rss_dtb : text;
    put_file_rss_dtb : string;
    str_size_old : string;
    num_size_old, num_size_next : longint;
    str_size_name : string;
    bool_rewrite_rss_dtb : boolean;

    procedure p_rss_write_new_dtb(var in_file_rss_dtb : text);

    begin
      WriteLn(in_file_rss_dtb, '[' + const_cfg[1] + ']=' + par_cfg^[num_rss][1]);
      WriteLn(in_file_rss_dtb, '[' + 'size_rss' + ']=' + f_num2str(num_size_next));
      WriteLn(in_file_rss_dtb);

    end;

    procedure p_rewrite_rss_dtb;
    var
      file_rss_dtb_t : text;

    begin

      reset(file_rss_dtb);
      Assign(file_rss_dtb_t, put_file_rss_dtb + '_t');
      rewrite(file_rss_dtb_t);
      readLn(file_rss_dtb, line);
      while (not eof(file_rss_dtb)) do
      begin
        if (UpCase(Copy(line, 1, length('[' + const_cfg[1] + ']='))) = UpCase('[' + const_cfg[1] + ']=')) then
        begin
          str_size_name := Copy(line, length('[' + const_cfg[1] + ']=') +1, length(line) - length('[' + const_cfg[1] + ']='));
          if UpCase(str_size_name) = UpCase(par_cfg^[num_rss][1]) then
          begin
            p_rss_write_new_dtb(file_rss_dtb_t);
            readLn(file_rss_dtb, line);
            readLn(file_rss_dtb, line);
            if (line = '') then
              readLn(file_rss_dtb, line);
          end;
        end;
        WriteLn(file_rss_dtb_t, line);
        readLn(file_rss_dtb, line);
      end;
      close(file_rss_dtb_t);
      close(file_rss_dtb);
      erase(file_rss_dtb);
      rename(file_rss_dtb_t, put_file_rss_dtb);

    end;

  begin
    rss_old := false;

      num_size_next := end_rss;
      put_file_rss_dtb := f_expand('rss2fido.dtb');
      f_expand(put_file_rss_dtb);
      Assign(file_rss_dtb, put_file_rss_dtb);
      if (not file_exist(put_file_rss_dtb)) and
         (num_cycle = 1) then
      begin
        rewrite(file_rss_dtb);
        WriteLn(file_rss_dtb, '; Это динамический файл базы данных программы rss2fido');
        WriteLn(file_rss_dtb);
        p_rss_write_new_dtb(file_rss_dtb);
        close(file_rss_dtb);
      end else
      begin
        bool_rewrite_rss_dtb := false;
        reset(file_rss_dtb);
        readLn(file_rss_dtb, line);
        while (not eof(file_rss_dtb)) and (not rss_old) and
              (not bool_rewrite_rss_dtb) do
        begin
          if (UpCase(Copy(line, 1, length('[' + const_cfg[1] + ']='))) = UpCase('[' + const_cfg[1] + ']=')) then
          begin
            str_size_name := Copy(line, length('[' + const_cfg[1] + ']=') +1, length(line) - length('[' + const_cfg[1] + ']='));
            if UpCase(str_size_name) = UpCase(par_cfg^[num_rss][1]) then
            begin
              readLn(file_rss_dtb, line);
              if (UpCase(Copy(line, 1, length('[' + 'size_rss' + ']='))) = UpCase('[' + 'size_rss' + ']=')) then
              begin
                str_size_old := Copy(line, length('[' + 'size_rss' + ']=') +1, length(line) - length('[' + 'size_rss' + ']='));
                num_size_old := f_str2num(str_size_old);

                if num_size_next = num_size_old then
                  rss_old := true else
                  begin
                    close(file_rss_dtb);
                    p_rewrite_rss_dtb;
                    bool_rewrite_rss_dtb := true;
                    reset(file_rss_dtb);
                  end;
              end;
            end;
          end;

          readLn(file_rss_dtb, line);
        end;
        if eof(file_rss_dtb) and (not rss_old) and
           (not bool_rewrite_rss_dtb) then
        begin
          // новая запись
          close(file_rss_dtb);
          append(file_rss_dtb);
          p_rss_write_new_dtb(file_rss_dtb);
        end;

         close(file_rss_dtb);
      end;

  end;

  function item (item_id : string) : boolean;

  begin
    temp_num := 1;
    while (not f_pos_file_news (item_id, 0)) and
          (temp_num < end_rss - length(item_id)) do
      inc (temp_num);
    if not ((temp_num < end_rss - length(item_id)) and
       (temp_num < end_rss)) then
    begin
      p_lang('error_item');
      item := false;
    end else
      item := true;
  end;

  procedure p_load_const_cfg;

  begin

    getmem(par_cfg,sizeof(string)*255*15);
    num_t := 1;
    while (par_cfg^[num_t][1] <> '') do
    begin
      num_temp := 1;
      while (par_cfg^[num_t][num_temp] <> '') do
        par_cfg^[num_t][num_temp] := '';
    end;

    num_t := 1;
    while (default_cfg[num_t] <> '') do
    begin
      default_cfg[num_t] := '';
      inc(num_t);
    end;

    sim_lang_id := '@';
    sim_comment := ';';

    const_cfg[1] := 'Name';
    const_cfg[2] := 'Adress';
    const_cfg[3] := 'Post';
    const_cfg[4] := 'out';
    const_cfg[5] := 'master';
    const_cfg[6] := 'template';
    const_cfg[7] := 'language';

    const_cfg[8] := 'post_base';
    const_cfg[9] := 'post_format';
    const_cfg[10] := 'post_from';
    const_cfg[11] := 'post_to';
    const_cfg[12] := 'post_fadress';
    const_cfg[13] := 'post_tadress';
    const_cfg[14] := 'post_subj';
    const_cfg[15] := 'post_tearline';
    const_cfg[16] := 'post_origin';
    const_cfg[17] := 'post_flag';
    const_cfg[18] := 'post_exec';
    const_cfg[19] := 'post_create_file';
    const_cfg[20] := '';

    post_out_base := const_cfg[3];
    post_in_base := const_cfg[8];

    def_base[1] := 'squish';
    def_base[2] := 'jam';
    def_base[3] := 'msg';

    atr_msg[1] := 'Private';
    atr_msg[2] := 'Received';
    atr_msg[3] := 'Attach';
    atr_msg[4] := 'Orphan';
    atr_msg[5] := 'Local';
    atr_msg[6] := 'FRq';
    atr_msg[7] := 'RRc';
    atr_msg[8] := 'URq';

    atr_msg[9] := 'Crash';
    atr_msg[10] := 'Sent';
    atr_msg[11] := 'Transit';
    atr_msg[12] := 'Kill';
    atr_msg[13] := 'Hold';
    atr_msg[14] := 'RRq';
    atr_msg[15] := 'ARq';
    atr_msg[16] := 'Scanned';

    atr_in_msg[1] := maPrivate;
    atr_in_msg[2] := maReceived;
    atr_in_msg[3] := maAttach;
    atr_in_msg[4] := maOrphan;
    atr_in_msg[5] := maLocal;
    atr_in_msg[6] := maFRq;
    atr_in_msg[7] := maRRc;
    atr_in_msg[8] := maURq;

    atr_in_msg[9] := maCrash;
    atr_in_msg[10] := maSent;
    atr_in_msg[11] := maTransit;
    atr_in_msg[12] := maKill;
    atr_in_msg[13] := maHold;
    atr_in_msg[14] := maRRq;
    atr_in_msg[15] := maARq;
    atr_in_msg[16] := maScanned;


  end;

  procedure p_parse_str_in_prog;
  var
    num_pr_str : byte;


  begin
    num_t := 1;
    while (ParamStr(num_t) <> '') and
          (UpCase(ParamStr(num_t)) <> str_sim_par_cfg) do
      inc(num_t);

    if (UpCase(ParamStr(num_t)) <> str_sim_par_cfg) then
    begin
      num_t := 1;
      while (ParamStr(num_t) <> '') do
      begin
        num_pr_str := 1;
        while (const_cfg[num_pr_str] <> '') do
        begin
          if (('-' + UpCase(const_cfg[num_pr_str][1]) = UpCase(ParamStr(num_t))) and (pos('_', ParamStr(num_t)) = 0)) or
             ('-' + UpCase(const_cfg[num_pr_str]) = UpCase(ParamStr(num_t))) and
             (ParamStr(num_t +1) <> '') then
          begin
            par_cfg^[1][num_pr_str] := Win2OEM(ParamStr(num_t +1));
            inc(num_t); inc(num_t);
          end;
          inc(num_pr_str);
        end;
        inc(num_t);
      end;
    end;
  end;

  procedure load_pro;

  begin
    writeLn(f_string_fix_left(by_Rain, 75));
  end;

  procedure p_help_par;
  var
    help_par : string;

  begin
    help_par := ParamStr(1);
    if (UpCase(help_par) = '/H') or
       (UpCase(help_par) = '/?') or
       (UpCase(help_par) = '-H') or
       (UpCase(help_par) = '-?') or
       (UpCase(help_par) = '--HELP') or
       (UpCase(help_par) = 'HELP') then
    begin
      WriteLn;
      load_pro;
      WriteLn(' Please, CP866');
      WriteLn;
      WriteLn(' Формат команды: [-команда] [значение]');
      WriteLn(' Доступны следующие команды:');
      WriteLn;
      WriteLn(' -n - название ленты;');
      WriteLn(' -a - адрес RSS;');
      WriteLn(' -p - командный файл для помежения сообщения в почтовую базу;');
      WriteLn(' -o - сообщение из RSS ленты, сформированное программой;');
      WriteLn(' -m - программа для скачивания (по умолчанию wget);');
      WriteLn(' -t - шаблон по которому будет создано сообщение;');
      WriteLn(' -l - language file.');
      WriteLn;
      WriteLn(' Можно использовать любые параметры из config file');
      WriteLn;
      WriteLn(' Стандартные примеры:');
      WriteLn;
      WriteLn(' rss2fido.exe [адрес_ленты]');
      WriteLn(' rss2fido.exe -c [config_file]');
      WriteLn;
      WriteLn(' так же смотрите в _example[XXX].bat');
      WriteLn;

      halt;
    end;
  end;

  procedure p_erase_ext_file(erase_ext_file : string);

  begin
    FindFirst('*' + erase_ext_file, AnyFile, SR);
    while (DosError = 0) do
    begin
      file_erase(f_expand(SR. Name));
      FindNext(SR);
    end;
    FindClose(SR);
  end;


  procedure p_post_in_base (put_file_in_base : string; num_file_in_base : longint);
  var
    Base : PMessageBase;
    adress_in_base, adress_from : TAddress;
    time_in_base : TMessageBaseDateTime;
    file_in_base : text;
    file_post_create_file : text;

    function f_verif_adress(verif_adress : string) : boolean;
    var
      zone, net, node, point : string;
      str_t_adress : string;
      bag_val : integer;

      function f_ver_copy_into(str_into, str_in, str_to, str_new : string) : string;

      begin
        if (pos(str_in, str_into) <> 0) and (pos(str_to, str_into) <> 0) then
          f_ver_copy_into := Copy(str_into, pos(str_in, str_into) +1, pos(str_to, str_into) - (pos(str_in, str_into) +1))
                                        else
          begin
          if (pos(str_in, str_into) <> 0) or (UpCase(str_in) = UpCase('\r')) then
          begin
            if (pos(str_new, str_into) = 0) and (UpCase(str_in) <> UpCase('\r')) then
            f_ver_copy_into := Copy(str_into, pos(str_in, str_into) +1, length(str_into) - (pos(str_in, str_into) +1) +1)
                                            else
            begin
            if (UpCase(str_in) <> UpCase('\r')) then
              f_ver_copy_into := Copy(str_into, pos(str_in, str_into) +1, pos(str_new, str_into) - (pos(str_in, str_into) +1))
                                                else
              f_ver_copy_into := Copy(str_into, pos(str_in, str_into) +1, pos(str_to, str_into) - (pos(str_in, str_into) +1));

            end;
          end
                                          else
            f_ver_copy_into := '';
          end;
      end;

    begin
      if (pos('@', verif_adress) <> 0) then
        str_t_adress := Copy(verif_adress, 1, pos('@', verif_adress) -1)
                                       else
        str_t_adress := verif_adress;

      f_verif_adress := true;
      zone := f_ver_copy_into(str_t_adress, '\r', ':', '');
      val (zone, num_t, bag_val);
      if (bag_val <> 0) then
        f_verif_adress := false;
      net := f_ver_copy_into(str_t_adress, ':', '/', '');
      val (net, num_t, bag_val);
      if (bag_val <> 0) then
        f_verif_adress := false;
      node := f_ver_copy_into(str_t_adress, '/', '.', '@');
      val (node, num_t, bag_val);
      if (bag_val <> 0) then
        f_verif_adress := false;
      point := f_ver_copy_into(str_t_adress, '.', '@', '');
      if (point <> '') then
      begin
        val (point, num_t, bag_val);
        if (bag_val <> 0) then
          f_verif_adress := false;
      end;

      if f_verif_adress then
      begin
        adress_in_base. Zone := f_str2num(zone);
        adress_in_base. Net := f_str2num(net);
        adress_in_base. Node := f_str2num(node);
        adress_in_base. Point := f_str2num(point);

      end;
    end;

    procedure p_re_atr(re_atr : string);
    var
      re_atr_t : string;

      function f_del_sim_re_atr(del_sim_re_atr : string; mode_del_sim : byte) : string;
      var
        del_sim : byte;
      begin
        if (mode_del_sim = 0) then
        begin
          del_sim := 1;
          while (del_sim_re_atr[del_sim] = ' ') do
            inc(del_sim);
          f_del_sim_re_atr := Copy(del_sim_re_atr, del_sim, length(del_sim_re_atr) - del_sim +1);
        end;
        if (mode_del_sim = 1) then
        begin
          del_sim := length(del_sim_re_atr);
          while (del_sim_re_atr[del_sim] = ' ') do
            del_sim := outc(del_sim);
          f_del_sim_re_atr := Copy(del_sim_re_atr, 1, del_sim);
        end;
      end;

    begin
      num_t := 1;
      while (re_atr_msg[num_t] <> '') do
      begin
        re_atr_msg[num_t] := '';
        inc(num_t);
      end;
      re_atr_t := re_atr;
      num_t := 1;
      while (pos(',', re_atr_t) <> 0) do
      begin
        re_atr_msg[num_t] := f_del_sim_re_atr(Copy(re_atr_t, 1, pos(',', re_atr_t) -1), 1);
        re_atr_t := Copy(re_atr_t, pos(',', re_atr_t) +1, length(re_atr_t) - pos(',', re_atr_t));
        re_atr_t := f_del_sim_re_atr(re_atr_t, 0);
        inc(num_t);
      end;
      re_atr_msg[num_t] := re_atr_t;
    end;

  begin
    if (UpCase(par_cfg^[num_file_in_base][9]) <> UpCase(def_base[1])) and
       (UpCase(par_cfg^[num_file_in_base][9]) <> UpCase(def_base[2])) and
       (UpCase(par_cfg^[num_file_in_base][9]) <> UpCase(def_base[3])) then
    begin
      p_lang('error_format');
      bool_exit := true;
      p_lang('error_exit');
    end;
    if (UpCase(par_cfg^[num_file_in_base][9]) = UpCase(def_base[1])) then
      Base := New(PSquishMessageBase, Init);
    if (UpCase(par_cfg^[num_file_in_base][9]) = UpCase(def_base[2])) then
      Base := New(PJamMessageBase, Init);
    if (UpCase(par_cfg^[num_file_in_base][9]) = UpCase(def_base[3])) then
      Base := New(PFidoMessageBase, Init);

    Base^. SetFlag(afEchomail, True);
    par_cfg^[num_file_in_base][8] := f_re_sim_sl(par_cfg^[num_file_in_base][8]);
    if not Base^. Open(par_cfg^[num_file_in_base][8]) then
    begin
      repeat
      p_lang('error_msgbase');
      until Base^. Open(par_cfg^[num_file_in_base][8]);
    end;

    num_msg := Base^. GetCount;

    if not (Base^. CreateNewMessage) then
    begin
      repeat
        p_lang('error_msgbase');
      until (Base^. WriteMessage);
    end else
    begin
      if (f_verif_adress(par_cfg^[num_file_in_base][12])) then
      begin
        Base^. SetFromAddress(adress_in_base, True);
        adress_from := adress_in_base;
      end else
      begin
        p_lang('error_adress');
        bool_exit := true;
        p_lang('error_exit');
      end;
      if (par_cfg^[num_file_in_base][13] <> '') then
      begin
        if (f_verif_adress(par_cfg^[num_file_in_base][13])) then
          Base^. SetToAddress(adress_in_base) else
        begin
          p_lang('error_adress');
          bool_exit := true;
          p_lang('error_exit');
        end;
      end;

      Base^. SetFrom(par_cfg^[num_file_in_base][10]);
      Base^. SetTo(par_cfg^[num_file_in_base][11]);
      Base^. SetSubject(par_cfg^[num_file_in_base][14]);
      GetCurrentMessageBaseDateTime(time_in_base);
      Base^. SetWrittenDateTime(time_in_base);
      Base^. SetArrivedDateTime(time_in_base);

      p_re_atr(par_cfg^[num_file_in_base][17]);
      num_t := 1;
      while (atr_msg[num_t] <> '') do
      begin
        num_temp := 1;
        while (re_atr_msg[num_temp] <> '') do
        begin
          if (UpCase(re_atr_msg[num_temp]) = UpCase(atr_msg[num_t])) then
            Base^. SetAttribute(atr_in_msg[num_t], True);
          inc(num_temp);
        end;
        inc(num_t);
      end;

      Base^. SetKludge(#01 + 'PID', #01 + 'PID: ' + by_Rain);
      Assign(file_in_base, put_file_in_base);
      reset(file_in_base);
      readLn(file_in_base, line);
      while (not eof(file_in_base)) do
      begin
        readLn(file_in_base, line);
        Base^. PutString(line);
      end;
      close(file_in_base);
      Base^. PutString('--- ' + par_cfg^[num_file_in_base][15]);
      Base^. PutOrigin(adress_from, par_cfg^[num_file_in_base][16]);

      if not Base^. WriteMessage then
      begin
        repeat
          p_lang('error_msgbase');
        until (Base^. WriteMessage);
      end;
      Base^. CloseMessage;
    end;
    Dispose(Base, Done);
    p_lang('msgbase');

    if (par_cfg^[num_file_in_base][18] <> '') then
      exec(par_cfg^[num_file_in_base][18], '');

    if (par_cfg^[num_file_in_base][19] <> '') then
    begin
      Assign(file_post_create_file, par_cfg^[num_file_in_base][19]);
      {$I-} rewrite(file_post_create_file); close(file_post_create_file); {$I+}
    end;

  end;

begin
  by_Rain := 'by_Rain 27/09-2006g.';

  if UpCase(ParamStr(2)) = UpCase('debage') then
    debage := true;

  rss_name_id := '_WORK_SAVE';
  if (not debage) then
    p_erase_ext_file(rss_name_id);

  p_help_par;
  p_load_const_cfg;
  str_sim_par_cfg := '-c';
  p_parse_str_in_prog;

  if (par_cfg^[1][7] = '') then
  begin
    const_lang_name[1] := '*.lng';
    const_lang_name[2] := '*.lang';
    const_lang_name[3] := 'language/*.lng';
    const_lang_name[4] := 'language/*.lang';

    num_temp := 0;
    repeat
      inc(num_temp);
      FindFirst(f_expand('') + '/' + const_lang_name[num_temp], AnyFile, SR);
      FindClose(SR);
    until (DosError = 0) or (const_lang_name[num_temp] = '');
    if (DosError = 0) then
      put_lang := f_expand(SR.Name)
                      else
    begin
      WriteLn('Error exist *.lng file');
      exit;
    end;
  end else
    put_lang := par_cfg^[1][7];

  put_lang := f_expand(put_lang);
  p_io_lang_file(put_lang);

  if (UpCase(ParamStr(1)) = UpCase(str_sim_par_cfg)) then
  begin
    put_file_cfg := ParamStr(2);
    if (put_file_cfg = '') then
      put_file_cfg := f_open_first_file ('cfg', 'error_cfg')
    else
      p_io_file(put_file_cfg);

    if file_exist(put_file_cfg) then
    begin
      multi := true;
      p_read_cfg(put_file_cfg);
    end else
    begin
      p_lang('error_cfg');
      bool_exit := true;
      p_lang('error_exit');
    end;
  end else
    multi := false;

  load_pro;

  num_rss := 1;
  num_cycle := 1;
  back_put_lang := '';
  file_cp_out := 'CP866_out.txt';
  bool_del_out := false;
repeat
  if (num_cycle > 1) then
    close(file_tpl);

  if (not multi) then
  begin
    if (par_cfg^[1][2] = '') then
      par_cfg^[1][2] := ParamStr(1);
    if (par_cfg^[1][3] = '') and (par_cfg^[1][8] = '') then
      par_cfg^[1][3] := 'post.bat';
    if (par_cfg^[1][4] = '') then
    begin
      par_cfg^[1][4] := file_cp_out;
      bool_del_out := true;
    end;
    if (par_cfg^[1][5] = '') then
      par_cfg^[1][5] := 'wget.exe';
    if (par_cfg^[1][6] = '') then
    put_template := f_open_first_file ('tpl', 'error_template')
                             else
    put_template := f_expand(par_cfg^[num_rss][6]);
    put_template := f_re_sim_sl(put_template);
  end else
  begin
    put_template := f_expand(par_cfg^[num_rss][6]);
    p_io_file(put_template);

    back_in_put := f_expand(par_cfg^[num_rss][7]);
    if (back_put_lang <> back_in_put) then
    begin
      close(file_lang);
      put_lang := back_in_put;
      p_io_lang_file(put_lang);
      back_put_lang := put_lang;
    end;
  end;

  if (par_cfg^[num_rss][1] = '') then
    par_cfg^[num_rss][1] := 'none_config_file_' + par_cfg^[num_rss][2];

  if not (par_cfg^[num_rss][4] <> '') then
  begin
    par_cfg^[num_rss][4] := file_cp_out;
    bool_del_out := true;
  end;
  num_temp := 2;
  while (num_temp <= 7) do
  begin
    if (par_cfg^[num_rss][num_temp] <> '') then
      par_cfg^[num_rss][num_temp] := f_re_sim_sl(f_expand(par_cfg^[num_rss][num_temp]));
    inc(num_temp);
  end;

  if (par_cfg^[num_rss][2] <> '') then
    put_file_rss := f_expand(par_cfg^[num_rss][2]);
  if (par_cfg^[num_rss][3] <> '') then
    put_file_post := f_expand(par_cfg^[num_rss][3]);
  if (par_cfg^[num_rss][4] <> '') then
    put_file_out := f_expand(par_cfg^[num_rss][4]);
  if (par_cfg^[num_rss][5] <> '') then
    put_file_master := f_expand(par_cfg^[num_rss][5]);

  p_load_template;
  p_rss_verif(put_file_rss);
  rss_name := f_expand('RSS' + rss_name_id);

  if (num_cycle = 1) then
    p_lang('start');

  if not debage then
  begin
    if file_exist(rss_name) then
      file_erase(rss_name);

    if (UpCase(f_file_ext(put_file_master)) = 'EXE') then
      exec(put_file_master, put_file_rss + ' --output-document=' + rss_name)
                                                     else
      exec(put_file_master, put_file_rss + ' ' + rss_name);
  end;

  if not file_exist(rss_name) then
  begin
    p_lang('error_url');
    p_lang('delay');
    continue;
  end;

// load RSS mem
  num_t := 0;
  end_rss := f_file_size(rss_name);
  num_end_rss := end_rss;
  getmem(ch_rss,sizeof(char)*num_end_rss);
  Assign (file_news, rss_name);
  reset(file_news);
  while num_t < end_rss do
  begin
    seek(file_news, num_t);
    read (file_news, fb);
    ch_rss^[num_t] := Chr(fb);
    inc(num_t);
  end;
  close(file_news);
  end_rss := num_t;
  if not debage then
    erase(file_news);
// end load RS mem

  comv_sw := auto_code(ch_rss, end_rss);
  p_lang('code');
  if (comv_sw = 'UTF-8') then
    end_rss := convert_ch_utf2dos(ch_rss, end_rss);
  if (comv_sw = 'WINDOWS-1251') or
     (comv_sw = 'NONE_CODE') then
    end_rss := convert_ch_win2dos(ch_rss, end_rss);

  if item('<item>') then
  begin
    if (not rss_old) then
    begin
      p_lang ('news');
      p_new_add_in_one_msg (put_file_out, 1);
      if (put_file_post <> '') then
        exec (put_file_post, put_file_out) else
        p_post_in_base(put_file_out, num_rss);
      if bool_del_out then
        file_erase(put_file_out);
    end else
      p_lang('size');
  end;
  freemem(ch_rss,sizeof(char)*num_end_rss);

  if not multi then
    p_lang('delay') else
    p_lang('multi');

  if multi then
  begin
    // без конфиг файла RSS не считаем
    if num_rss < num_rss_end then
      inc(num_rss) else
      num_rss := 1;
  end;
  inc(num_cycle);

  until (sw_key = #27);

end.