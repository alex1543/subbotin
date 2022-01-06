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

     pro_coder, pro_util, pro_files, pro_dt, pro_string,
     pro_lang, pro_ch, pro_par, pro_dtb, pro_rss, pro_cfg,
     pro_const, pro_wk;


begin
  {$ifdef Win32}
  {$R ico/new.res} // Иконка
  // Выход из программы
  // (по крестику, клавишам, etc)
  SetCtrlHandler;
  // Кодовая стр. отобр. на экране
  set_code_page(866);
  {$endif}

  put_rss_out := f_expand(put_rss_out);

  if f_help(ParamStr(1)) then p_par('help', true);
  if f_info(ParamStr(1)) then p_par('info', true);
  if (f_copyright(ParamStr(1))) then p_wr_copyright(true);

  if (file_exist(f_expand(put_file_lock))) then
  begin
    WriteLn(' ... to view copyright type --copyright');
    WriteLn('     for example: ' + f_prog_name + ' --copyright');
    WriteLn('     just use: --help, --info for more information');
    delay(1200);
  end;
  p_lock (f_expand(put_file_lock));

  SetLength(ParConf, 2);

  init_load_file(lng_sv);
  init_load_file(tpl_sv);

  if (f_config(ParamStr(1))) then
  begin
    put_file_cfg := ParamStr(2);
    if not (put_file_cfg = '') then
       put_file_cfg := f_expand(f_lang_re(put_file_cfg));
    if (put_file_cfg = '') then
       put_file_cfg := GetFirstFile (ft_cfg);
    if not par_cfg_config(put_file_cfg) then
       err_cfg (put_file_cfg);
  end else p_parse_str_in_prog;

repeat

  if (multi) or ((not multi) and (num_cycle = 1)) then
  begin // при конфиге и первый без конфига
    init_bool_const_cfg; // макросы-действия = false
    DeffParConf (pro_const. num_rss); // макросы по умолчанию
    load_file_save(ch_lng, 7, lng_sv); // загружаем в память templates
  end;

  if (not multi) and (num_cycle = 1) then
  begin // первый без конфига
    // если post и post_base не указан, то присваиваем значение post
    if (GetParConf(pro_const. num_rss, 3, 1) = '') and (GetParConf(pro_const. num_rss, 8, 1) = '') then
      SetParConf(sender_deff, pro_const. num_rss, 3, 1);

    if (ParamStr(1) = '') and (GetParConf(pro_const. num_rss, 2, 1) = '') then
      LangList(run_id, 'enter', false) else // при запуске без параметров
      LangList(run_id, 'string', false); // при запуске из командной строки
  end;
  if (multi) and (num_cycle = 1) then // первый с конфигом
    LangList(run_id, 'config', false); // при запуске с конфигом

  // при конфиге и первый без конфига
  if (multi) or ((not multi) and (num_cycle = 1)) then
  // если новое значение равно предыдущему, то PChar не загружаем
    load_file_save(ch_tpl, 6, tpl_sv); // загружаем в память languages
  // запускаем начальный макрос
  LangList(sys_id, 'start', false);
  // без конфига потом будет работать
  // только начальный макрос
  until (pro_const. num_rss > pro_const. num_rss_end);
  // бесконечный цикл, выход через pro_lang
end.