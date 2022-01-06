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

unit pro_dtb;

interface

  function rss_old (const ch_old : PChar) : boolean;



implementation

uses
  crt, dos,

  pro_util, pro_string, pro_const, pro_ch;


  function rss_old (const ch_old : PChar) : boolean;
  var
    file_rss_dtb : text;
    put_file_rss_dtb : string;
    str_size_old : string;
    num_size_old, num_size_next : longint;
    str_size_name : string;
    bool_rewrite_rss_dtb : boolean;
    line : string;

    procedure p_rss_write_new_dtb(var in_file_rss_dtb : text);

    begin
      WriteLn(in_file_rss_dtb, '[' + const_cfg[1] + ']=' + par_cfg[num_rss][1][1]);
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
          if UpCase(str_size_name) = UpCase(par_cfg[num_rss][1][1]) then
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

      num_size_next := ch_size(ch_old);
      put_file_rss_dtb := f_expand(put_dtb);
      f_expand(put_file_rss_dtb);
      Assign(file_rss_dtb, put_file_rss_dtb);
      if (not file_exist(put_file_rss_dtb)) then
      begin
        rewrite(file_rss_dtb);
        WriteLn(file_rss_dtb, '; This dynamic file of rss2fido. Please, dont edit this file.');
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
            if UpCase(str_size_name) = UpCase(par_cfg[num_rss][1][1]) then
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



end.