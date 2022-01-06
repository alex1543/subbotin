uses WinInet;

type TThreadStatus = (ACTIVE, INACTIVE, SUCCESS);


{------------------------------------------------------------------}
{  Function to get a file from the internet using HTTP          }
{------------------------------------------------------------------}
function GetInetFile(const fileURL, FileName: String): Boolean;
const BufferSize = 1024;
var hSession, hURL: HInternet;
    Buffer: array[1..BufferSize] of Byte;
    BufferLen: DWORD;
    f: File;
    sAppName: string;
    lpFindFileData: TWin32FindData;
begin
  Result:=False;
  sAppName := 'Jans OpenGL Texture loader';
  hSession := InternetOpen(
                 PChar(sAppName),                // agent. (can be "Microsoft Internet Explorer")
                 INTERNET_OPEN_TYPE_PRECONFIG,   // access
                 nil,                            // proxy server
                 nil,                            // defauts
                 0);                             // synchronous

  try
    hURL := InternetOpenURL(
               hSession,          // Handle to current session
               PChar(fileURL),    // URL to read
               nil,               // HTTP headers to send to server
               0,                 // Header length
               0, 0);             // flags   (might want to add some like INTERNET_FLAG_RELOAD with forces a reload from server and not from cache)
    if hURL <> nil then
    begin
      try
        AssignFile(F, FileName);
        Rewrite(F,1);
        repeat
          InternetReadFile(
             hURL,                  // File URL
             @Buffer,               // Buffer that receives data
             SizeOf(Buffer),        // bytes to read
             BufferLen);            // bytes read
          BlockWrite(F, Buffer, BufferLen)
        until BufferLen = 0;
        CloseFile(F);
        if Buffer[1] = $3D then     // basic check to see if its HTML returned
          Result:=FALSE             // if its the start of a tag, then error.
        else
          Result:=True;
      finally
        InternetCloseHandle(hURL)   // close connection to file
      end
    end;
  finally
    InternetCloseHandle(hSession) // close connection to internet
  end
end;


{------------------------------------------------------------------}
{  Download Thread                                                 }
{------------------------------------------------------------------}
function CreateRecID(P : Pointer) : LongInt; stdcall;
begin
  ThreadStatus :=ACTIVE;
  if GetInetFile(FileURL,LocalFileName) = True then
    ThreadStatus :=SUCCESS
  else
  begin
    MessageBox(0, 'Unable to locate file', 'Error', MB_OK or MB_ICONERROR);
    ThreadStatus :=INACTIVE;
  end;
end;


{------------------------------------------------------------------}
{  Creates a thread that downloads a texture from the internet     }
{------------------------------------------------------------------}
procedure GetFileFromInternet(URL, LocalFName : String);
var DownloadThread : THandle;
    ThreadID : DWord;
begin
  ThreadStatus :=ACTIVE;
  FileURL :=URL;
  LocalFileName := LocalFName;
  DownloadThread := CreateThread(nil, 0, @CreateRecID, nil, 0, ThreadID);
  if (DownloadThread = 0) then
    MessageBox(0, 'Unable to create a download thread', 'Error', MB_OK or MB_ICONERROR);
end;

