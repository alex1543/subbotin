
  procedure p_read_cfg(put_file_in_read_cfg : string);

  var
    num_cfg_name_par : word;
    num_const_cfg : byte;
    str_def_cfg : string;
    num_def_cfg : byte;
    str_def_set : string;
    num_set_t : byte;
    str_set_t : string;
    num_const_cfg_plus, num_def_cfg_plus_max : byte;
    num_trlnch : word;
    num_rss_gm, num_base_gm : byte;
    default_cfg : Array[1..25] of string;
    real_byte : longint;


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

  function f_cfg_rss_start (in_rss_line : string) : boolean;

  begin
    f_cfg_rss_start := false;

    if (((UpCase(Copy(in_rss_line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) and (not bool_start_rss)) or
       (UpCase(Copy(in_rss_line, 1, length('[start_rss]'))) = UpCase('[start_rss]'))) then
    begin
    if (first) then // при первом идентификаторе группы default не работает
     begin
       first := false;
       bool_start_rss := true;
     end
     else begin
      // если найдено [start_rss], то группа не может начинаться с Name
       if (UpCase(Copy(in_rss_line, 1, length('[start_rss]'))) = UpCase('[start_rss]')) then
         bool_start_rss := true;

        f_cfg_rss_start := true;
      end;
    end;
  end;

  function f_cfg_rss_end (in_rss_line : string) : boolean;

  begin
    f_cfg_rss_end := false;
    // если найдено Name после [start_rss] или найдено [end_rss],
    // то тогда группа снова может начинаться с Name
    if (UpCase(Copy(in_rss_line, 1, length(const_cfg[1]))) = UpCase(const_cfg[1])) or
       (UpCase(Copy(in_rss_line, 1, length('[end_rss]'))) = UpCase('[end_rss]')) then
    begin
      f_cfg_rss_end := true;
      bool_start_rss := false;
    end;
  end;

  procedure p_cfg_rss_init (in_rss_line : string);

  begin
    first := true;
  end;

  function f_cfg_rss_base (in_rss_line : string) : boolean;

  begin

    if (UpCase(Copy(in_rss_line, 1, length(const_cfg[8]))) = UpCase(const_cfg[8])) then
      f_cfg_rss_base := true else f_cfg_rss_base := false;

  end;

  begin
    num_t := 1;
    while (default_cfg[num_t] <> '') do
    begin
      default_cfg[num_t] := '';
      inc(num_t);
    end;

    p_load_file_ch(ch_cfg, real_byte, put_file_in_read_cfg, sim_comment);
    p_lock_file(put_file_in_read_cfg);
{
    num_trlnch := 1; num_rss_gm := 1; // начиная со второго
    p_cfg_rss_init(line); num_base_gm := 0;
    line := readLn_ch(ch_cfg, real_byte, num_trlnch, num_trlnch +1);
    inc(num_trlnch);
    while (line <> '') do
    begin
      if (f_cfg_rss_start(line)) then
        inc(num_rss_gm);

      if (f_cfg_rss_base(line)) then
        inc(num_base_gm);

      if f_cfg_rss_end(line) then begin end;
      line := readLn_ch(ch_cfg, real_byte, num_trlnch, num_trlnch +1);
      inc(num_trlnch);
    end;
 //   freemem(par_cfg, size_par_cfg);
 //   size_par_cfg := SizeOf(string)*(num_rss_gm + num_base_gm)*20;
 //   getmem(par_cfg, size_par_cfg);
}
writeLn('ok2 ', par_cfg^[1][4][1]); readkey;

    num_trlnch := 1;
    line := readLn_ch(ch_cfg, real_byte, num_trlnch, num_trlnch +1);
    inc(num_trlnch);
    num_cfg_name_par := 1; num_set := 0; p_cfg_rss_init(line);
    while (line <> '') do
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
             (str_def_set[1] = sim_lang_id) then
          begin
            str_set_t := Copy(str_def_set, 2, pos(' ', str_def_set) -2);
            num_set_t := 1;
            while (str_set[num_set_t] <> '') and
                  (UpCase(str_set_t) <> UpCase(str_set[num_set_t])) do
              inc(num_set_t);
            if (UpCase(str_set_t) <> UpCase(str_set[num_set_t])) then
            begin
              inc(num_set);
              str_reset[num_set] := f_in_per_end(str_def_set, sim_lang_id + str_set_t);
              str_set[num_set] := str_set_t;
            end else
            begin
              str_reset[num_set_t] := f_in_per_end(str_def_set, sim_lang_id + str_set_t);
              str_set[num_set_t] := str_set_t;
            end;
          end;
        end;

        num_const_cfg := 1;
        if (f_cfg_rss_start(line)) then
        begin

          if (par_cfg^[num_cfg_name_par][8][1] = '') and
             (par_cfg^[num_cfg_name_par][3][1] = '') then
            // если post_base не задано, то post будет задано из default
            par_cfg^[num_cfg_name_par][3][1] := default_cfg[3];

          num_def_cfg := 1; num_def_cfg_plus_max := 1;
          while (const_cfg[num_def_cfg] <> '') do
          begin
             // Если параметр в группе не задан
            if (par_cfg^[num_cfg_name_par][num_def_cfg][1] = '') and
               (default_cfg[num_def_cfg] <> '') then
              begin
                // если внутренний постер не задан, будет использоваться внешний
                if (UpCase(post_out_base) <> UpCase(const_cfg[num_def_cfg])) then
                  par_cfg^[num_cfg_name_par][num_def_cfg][1] := f_lang_re(default_cfg[num_def_cfg], num_cfg_name_par, 1);
              end;

            // поиск максимального значения для переменных типа "post_"
            num_t2 := 2;
            // если задано параметров для значения в группе больше, чем один
            while (par_cfg^[num_cfg_name_par][num_def_cfg][num_t2] <> '') and
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
                if (par_cfg^[num_cfg_name_par][num_def_cfg][num_t2] = '') and
                   (default_cfg[num_def_cfg] <> '') then
                begin
                  if (UpCase(post_out_base) <> UpCase(const_cfg[num_def_cfg])) then
                    par_cfg^[num_cfg_name_par][num_def_cfg][num_t2] := f_lang_re(default_cfg[num_def_cfg], num_cfg_name_par, 1);
                end;
                // если default не задано, то присваивается последнее значение порядка
                if (par_cfg^[num_cfg_name_par][num_def_cfg][num_t2] = '') and
                   (default_cfg[num_def_cfg] = '') then
                begin
                  num_temp := 1;
                  // нашли последнее заданное значение
                  while (par_cfg^[num_cfg_name_par][num_def_cfg][num_temp] <> '') do
                    inc(num_temp);
                  num_temp := outc(num_temp);

                   // если пследнее значение все-таки есть
                  if (par_cfg^[num_cfg_name_par][num_def_cfg][num_temp] <> '') then
                    par_cfg^[num_cfg_name_par][num_def_cfg][num_t2] := par_cfg^[num_cfg_name_par][num_def_cfg][num_temp];
                end;
                inc(num_t2);
              end;
            end;
            inc(num_def_cfg);
          end;
         // переходим к новой группе
          inc(num_cfg_name_par);
        end;

        if f_cfg_rss_end(line) then begin end;

        while (const_cfg[num_const_cfg] <> '') do
        begin
          if (UpCase(Copy(line, 1, length(const_cfg[num_const_cfg] + ' '))) = UpCase(const_cfg[num_const_cfg] + ' ')) then
          begin
            num_const_cfg_plus := 1;
            while (par_cfg^[num_cfg_name_par][num_const_cfg][num_const_cfg_plus] <> '') do
              inc(num_const_cfg_plus);
            par_cfg^[num_cfg_name_par][num_const_cfg][num_const_cfg_plus] := f_lang_re(f_in_per_end(line, const_cfg[num_const_cfg]), num_cfg_name_par, num_const_cfg_plus);
writeLn(par_cfg^[num_cfg_name_par][num_const_cfg][num_const_cfg_plus], ' -', num_cfg_name_par, '-', num_const_cfg, '-', num_const_cfg_plus);
writeLn('ok1 ', par_cfg^[1][4][1]); readkey;
          end;
          inc(num_const_cfg);
        end;
      line := readLn_ch(ch_cfg, real_byte, num_trlnch, num_trlnch +1);
      inc(num_trlnch);
    end;
    num_rss_end := num_cfg_name_par;
    freemem(ch_cfg, real_byte);

writeLn('ok1 ', par_cfg^[1][4][1]); readkey;
  end;