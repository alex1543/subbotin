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


program rss2fido;

uses crt, dos,

     pro_coder, pro_util, pro_files, pro_time, pro_string,
     pro_lang, pro_ch, pro_par, pro_dtb, pro_rss, pro_cfg,
     pro_const, pro_post, pro_master, pro_pkt,

     Sockets;

  {$I variable.inc}


begin

  p_lock;
  p_erase_ext_file(rss_name_id);
  p_help_par;

  num_tplusr := 1; num_t := 1;
  pro_const. num_rss := 1;
  pro_const. num_tplus := 1;
  post_out_base := const_cfg[3];
  post_in_base := const_cfg[8];
{
  setLength(par_cfg, 5);
  setLength(par_cfg[1], 20);
  setLength(par_cfg[1][1], 5);
  setLength(par_cfg[1][2], 5);
  setLength(par_cfg[2], 20);
  setLength(par_cfg[2][1], 5);
  setLength(par_cfg[2][2], 5);

par_cfg[1][1][1] := 'bla-bla';
writeLn(par_cfg[1][1][1], ' okt1');
}

  p_parse_str_in_prog;

  put_lang := par_cfg[1][7][1];
  if (put_lang = '') then
    put_lang := put_first_lang_file;

  put_lang := f_expand(put_lang);
  p_io_lang_file(file_lang, put_lang);

  if (UpCase(ParamStr(1)) = UpCase(str_sim_par_cfg)) then
  begin
    pro_const. put_file_cfg := ParamStr(2);
    if (pro_const. put_file_cfg <> '') then
      pro_const. put_file_cfg := f_expand(pro_const. put_file_cfg);
    if (pro_const. put_file_cfg = '') then
      pro_const. put_file_cfg := f_open_first_file ('cfg', 'error_cfg')
    else
      p_io_file(pro_const. put_file_cfg);
    if file_exist(pro_const. put_file_cfg) then
    begin
      multi := true;
      p_read_cfg(pro_const. put_file_cfg);
    end else
    begin
      p_lang('error_cfg');
      pro_const. bool_exit := true;
      p_lang('error_exit');
    end;
  end else
    multi := false;

  pro_const. num_rss := 1;
  pro_const. num_cycle := 1;
  back_put_lang := '';

  num_t := 1;
  while (pro_const. bool_del_out[num_t]) do
  begin
    pro_const. bool_del_out[num_t] := false;
    inc(num_t);
  end;
repeat
  if (not multi) then
  begin
    if (ParamStr(1) = '') and (par_cfg[1][2][1] = '') then
    begin
      ClrScr;
      GotoXY (1, 3);
      WriteLn('  ┌───────── ─── ── ─  ─   ─     ─');
      WriteLn('  │ RSS adress: ');
      WriteLn('  └───────────────── ──── ─── ──  ─   ─    ─     ─');
      GotoXY (17, 4);
      ReadLn(par_cfg[1][2][1]);
      ClrScr;
      GotoXY (1, 3);
    end;

    if (par_cfg[1][2][1] = '') then
      par_cfg[1][2][1] := ParamStr(1);
    if (par_cfg[1][3][1] = '') and (par_cfg[1][8][1] = '') then
      par_cfg[1][3][1] := 'post.bat';
    if (par_cfg[1][6][1] = '') then
    par_cfg[1][6][1] := f_open_first_file ('tpl', 'error_template')
                             else
    par_cfg[1][6][1] := f_expand(par_cfg[pro_const. num_rss][6][1]);
    par_cfg[1][6][1] := f_re_sim_sl(par_cfg[1][6][1]);
  end else
  begin
    par_cfg[pro_const. num_rss][6][1] := f_expand(par_cfg[pro_const. num_rss][6][1]);
    p_io_file(par_cfg[pro_const. num_rss][6][1]);

    back_in_put := f_expand(par_cfg[pro_const. num_rss][7][1]);
    if (back_put_lang <> back_in_put) then
    begin
      close(file_lang);
      put_lang := back_in_put;
      p_io_lang_file(file_lang, put_lang);
      back_put_lang := put_lang;
    end;
  end;

  if (par_cfg[pro_const. num_rss][1][1] = '') then
    par_cfg[pro_const. num_rss][1][1] := rss_none_name + par_cfg[pro_const. num_rss][2][1];

  if not (par_cfg[pro_const. num_rss][4][1] <> '') then
  begin
    par_cfg[pro_const. num_rss][4][1] := file_cp_out;
    pro_const. bool_del_out[pro_const. num_rss] := true;
  end;
  num_temp := 2;
  while (num_temp <= 7) do
  begin
    if (par_cfg[pro_const. num_rss][num_temp][1] <> '') then
      par_cfg[pro_const. num_rss][num_temp][1] := f_re_sim_sl(f_expand(par_cfg[pro_const. num_rss][num_temp][1]));
    inc(num_temp);
  end;

  if (par_cfg[pro_const. num_rss][2][1] <> '') then
    pro_const. put_file_rss := f_expand(par_cfg[pro_const. num_rss][2][1]);
  if (par_cfg[pro_const. num_rss][3][1] <> '') then
    par_cfg[pro_const. num_rss][3][1] := f_expand(par_cfg[pro_const. num_rss][3][1]);
  if (par_cfg[pro_const. num_rss][4][1] <> '') then
    par_cfg[pro_const. num_rss][4][1] := f_expand(par_cfg[pro_const. num_rss][4][1]);

  p_load_file_ch_all(ch_tpl, par_cfg[pro_const. num_rss][6][1]);
  p_rss_verif;
  rss_name := f_expand(rss_name_id);

  if (pro_const. num_cycle = 1) then
    p_lang('start');

  if file_exist(rss_name) then
    file_erase(rss_name);

  if (par_cfg[pro_const. num_rss][5][1] <> '') and
     (UpCase(f_file_ext(f_expand(par_cfg[pro_const. num_rss][5][1]))) <> 'LOG') then
  begin
    par_cfg[pro_const. num_rss][5][1] := f_expand(par_cfg[pro_const. num_rss][5][1]);
    if (UpCase(f_file_ext(par_cfg[pro_const. num_rss][5][1])) = 'EXE') then
      exec(par_cfg[pro_const. num_rss][5][1], pro_const. put_file_rss + ' --output-document=' + rss_name)
                                                     else
      exec(par_cfg[pro_const. num_rss][5][1], pro_const. put_file_rss + ' ' + rss_name);
  end else
  begin
    p_lang('master');
    p_get_inet_file(put_file_rss, rss_name, par_cfg[pro_const. num_rss][5][1]);
  end;

  if (not file_exist(rss_name)) or
     (f_file_size(rss_name) = 0) then
    p_lang('error_url') else
  begin
  p_load_file_ch_all(ch_rss, rss_name);
  file_erase(rss_name);

  pro_const. comv_sw := auto_code(ch_rss);
  p_lang('code');
  if (pro_const. comv_sw = 'UTF-8') then
    convert_ch_utf2dos(ch_rss);
  if (pro_const. comv_sw = 'WINDOWS-1251') or
     (pro_const. comv_sw = 'NONE_CODE') then
    convert_ch_win2dos(ch_rss);

  if item(ch_rss, '<item>') then
  begin
    if (not rss_old(ch_rss)) then
    begin
      p_lang ('news');
      getmem(ch_out,sizeof(char)*ch_size(ch_rss));  // end_ch_rss -- а сколько?
      p_new_add_in_one_msg (ch_rss, ch_tpl, ch_out, 1);

      num_tplusr := 1;
      while (par_cfg[pro_const. num_rss][4][num_tplusr] <> '') and
            (not pro_const. bool_del_out[pro_const. num_rss]) do
      begin
        // создаем out файлы, заданные переменной "out"
        file_create(ch_out, par_cfg[pro_const. num_rss][4][num_tplusr]);
        inc(num_tplusr);
      end;
      num_tplusr := 1;
      while (par_cfg[pro_const. num_rss][18][num_tplusr] <> '') do
      begin
        // запускаем приложения, определённые макросом "exec"
        exec(par_cfg[pro_const. num_rss][18][num_tplusr], '');
        inc(num_tplusr);
      end;

      pro_const. num_tplus := 1;
      // если post задан
      if (par_cfg[pro_const. num_rss][3][1] <> '') then
      begin
        // если задано несколько параметров post
        while (par_cfg[pro_const. num_rss][3][pro_const. num_tplus] <> '') and
              // и если задано значение out
              (par_cfg[pro_const. num_rss][4][pro_const. num_tplus] <> '') do
        begin
          file_create(ch_out, par_cfg[pro_const. num_rss][4][pro_const. num_tplus]);
          exec (par_cfg[pro_const. num_rss][3][pro_const. num_tplus], par_cfg[pro_const. num_rss][4][pro_const. num_tplus]);
          if (pro_const. bool_del_out[pro_const. num_rss]) then
            file_erase(par_cfg[pro_const. num_rss][4][pro_const. num_tplus]);
          inc(pro_const. num_tplus);
        end;
      end else
      begin
        // если post не задан, то добавляем message
        while (par_cfg[pro_const. num_rss][8][pro_const. num_tplus] <> '') do
        begin
          if (Upcase(par_cfg[pro_const. num_rss][9][pro_const. num_tplus]) = UpCase(pkt_id)) then
            p_pkt_create(ch_out) else p_post_in_base(ch_out);
          inc(pro_const. num_tplus);
        end;
      end;

      // Создаем флаги и записываем туда имена почтовых баз
      pro_const. num_tplus := 1;
      while (par_cfg[pro_const. num_rss][19][pro_const. num_tplus] <> '') do
      begin
        Assign(file_post_create_file, par_cfg[pro_const. num_rss][19][pro_const. num_tplus]);
        {$I-} rewrite(file_post_create_file); {$I+}
        num_tplusr2 := 1;
        base_name := f_base_name(par_cfg[pro_const. num_rss][8][num_tplusr2]);
        while (base_name <> '') do
        begin {$I-}
          writeLn(file_post_create_file, base_name);
          inc(num_tplusr2);
          base_name := f_base_name(par_cfg[pro_const. num_rss][8][num_tplusr2]);
        end; {$I+}
        {$I-} close(file_post_create_file); {$I+}
        inc(pro_const. num_tplus);
      end;
      pro_const. num_tplus := 1;

      freemem(ch_out,sizeof(char)*ch_size(ch_rss));
    end else
      p_lang('size');
  end;
    ch_rss := nil;
  end;

  if (multi) then
  begin
    // без конфиг файла RSS не считаем
    if pro_const. num_rss < num_rss_end then
      inc(pro_const. num_rss) else
      pro_const. num_rss := 1;

    p_lang('multi');
  end else
    p_lang('delay');

  inc(pro_const. num_cycle);

  until (sw_key = #27);

end.