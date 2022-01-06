{$MODE DELPHI}

Program testhttp;

uses
  crt, dos,
  httpsend, classes;

var
  HTTP: THTTPSend;
  l: tstringlist;
  file_out : text;

begin
  HTTP := THTTPSend.Create;
  l := TStringList.create;
  try
    if not HTTP.HTTPMethod('GET', Paramstr(1)) then
      begin
	writeln('ERROR');
        writeln(Http.Resultcode);
      end
    else
      begin
{        writeln(Http.Resultcode, ' ', Http.Resultstring);
        writeln;
readkey;
        writeln(Http.headers.text);
        writeln;
readkey;
}
        l.loadfromstream(Http.Document);

        writeln(l.text);
Assign(file_out, 'D:\hpt\RSS2FIDO\synapse\source\demo\FreePascal\file_out.txt');
rewrite(file_out);
writeLn(file_out, l.text);
close(file_out);

     end;
  finally
    HTTP.Free;
    l.free;
  end;
end.

