{*******************************************************}
{                                                       }
{      Copyright(c) 2003-2016 Oamaru Group , Inc.       }
{                                                       }
{   Copyright and license exceptions noted in source    }
{                                                       }
{*******************************************************}
unit CustomThread;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows, WinApi.Messages, System.SyncObjs;

type
  TCustomThread = class
    private
      FCriticalSection: TCriticalSection;
      function ThreadProc: Boolean;
      //class function CustomThreadProc(const AThread: TCustomThread): Integer;
    protected
      FThreadHandle: THandle;
      FThreadId: TThreadID;
      FFinishedEvent: THandle;
      FShouldFinishEvent: THandle;
      FStartedEvent: THandle;
  		FTerminated: Boolean;
      FStarted: Boolean;
      FException: Exception;
      procedure Lock;
      procedure Unlock;
      function GetTerminated: Boolean;
      procedure SetTerminated(AValue: Boolean);
      function GetStarted: Boolean;
      function OnThreadExecute: Boolean; virtual;
      function OnBeforeThreadBegin(AWaitTillStarted: Boolean = FALSE): Boolean; virtual;
      function OnAfterThreadBegin: Boolean; virtual;
      function OnBeforeThreadEnd(AWaitTillFinished: Boolean = FALSE): Boolean; virtual;
      function OnAfterThreadEnd: Boolean; virtual;
      procedure HandleException;
      procedure DoHandleException; virtual;
    public
      constructor Create; virtual;
      destructor Destroy; override;
      function ThreadStart(AWaitTillStarted: Boolean = FALSE; AMilliseconds:DWORD = INFINITE): Boolean;
      function ThreadStop(AWaitTillFinished: Boolean = FALSE; AMilliseconds:DWORD = INFINITE): Boolean;
      property Terminated: Boolean read GetTerminated write SetTerminated;
      property Started: Boolean read GetStarted;
  end;

implementation

function CustomThreadProc(const AThread: TCustomThread): Integer;
begin
  AThread.ThreadProc;
  EndThread( 0 );
	Result := 0;
end;

constructor TCustomThread.Create;
begin
  FCriticalSection := TCriticalSection.Create;
  FThreadHandle := 0;
  FThreadId := 0;
  FFinishedEvent := 0;
  FShouldFinishEvent := 0;
  FStartedEvent := 0;
  FTerminated := FALSE;
  FStarted := FALSE;
end;

destructor TCustomThread.Destroy;
begin
  ThreadStop;
  FCriticalSection.Free;
  inherited Destroy;
end;

function TCustomThread.ThreadProc: Boolean;
begin
  Self.OnThreadExecute();

  // now that we are done, set our event to notify the
  // creating class that we are done.
  if 0 <> FFinishedEvent then
  begin
    SetEvent(FFinishedEvent);
  end;
  Result := TRUE;
end;

procedure TCustomThread.Lock;
begin
  FCriticalSection.Acquire;
end;

procedure TCustomThread.Unlock;
begin
  FCriticalSection.Release;
end;

function TCustomThread.GetTerminated: Boolean;
begin
  Lock;
  try
    Result := FTerminated;
  finally
    Unlock;
  end;
end;

procedure TCustomThread.SetTerminated(AValue: Boolean);
begin
  Lock;
  try
    FTerminated := AValue;
  finally
    Unlock;
  end;
end;

function TCustomThread.GetStarted: Boolean;
begin
  Lock;
  try
    Result := FStarted;
  finally
    Unlock;
  end;
end;

function TCustomThread.OnThreadExecute: Boolean;
begin
  Result := TRUE;
end;

function TCustomThread.OnBeforeThreadBegin(AWaitTillStarted: Boolean = FALSE): Boolean;
begin
  Result := TRUE;
end;

function TCustomThread.OnAfterThreadBegin: Boolean;
begin
  Result := TRUE;
end;

function TCustomThread.OnBeforeThreadEnd(AWaitTillFinished: Boolean = FALSE): Boolean;
begin
  Result := TRUE;
end;

function TCustomThread.OnAfterThreadEnd: Boolean;
begin
  Result := TRUE;
end;

procedure TCustomThread.HandleException;
begin
  // This function is virtual so you can override it
  // and add your own functionality.
  FException := Exception(ExceptObject);
  try
    // Don't show EAbort messages
    if not (FException is EAbort) then
      DoHandleException;
  finally
    FException := nil;
  end;
end;

procedure TCustomThread.DoHandleException;
begin
  EXIT;
end;

function TCustomThread.ThreadStart(AWaitTillStarted: Boolean = False; AMilliseconds:DWORD  = INFINITE): Boolean;
begin
  // first make sure we are not already running
  if FStarted then
  begin
    Result := FALSE;
    EXIT;
  end;

  //Create my Events
  FFinishedEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FShouldFinishEvent := CreateEvent(nil, TRUE, FALSE, nil);

  if (0 = FFinishedEvent) then
  begin
    Result := FALSE;
    EXIT;
  end;

	// Set Started event
	FStartedEvent := CreateEvent(nil, TRUE, FALSE, nil );

	OnBeforeThreadBegin();

  FTerminated := False;
  FThreadHandle := BeginThread(nil, 0, @CustomThreadProc, Pointer(Self), NORMAL_PRIORITY_CLASS, FThreadID);
  if 0 <> FThreadHandle then
  begin
    FStarted := TRUE;
		if(AWaitTillStarted) then
			WaitForSingleObject(FStartedEvent, AMilliseconds);
    OnAfterThreadBegin;
    Result := TRUE;
    EXIT;
  end else
  begin
    FThreadId := 0;
    FThreadHandle := 0;
    if (0 <> FFinishedEvent) then
      CloseHandle(FFinishedEvent);
		if (0 <> FStartedEvent) then
			CloseHandle(FStartedEvent);
    FTerminated := TRUE;
    Result := FALSE;
  end;
end;

function TCustomThread.ThreadStop(AWaitTillFinished: Boolean = FALSE; AMilliseconds: DWORD = INFINITE): Boolean;
var
  LWaitResult: DWORD;
begin
  Result := OnBeforeThreadEnd();
  if (0 <> FFinishedEvent) and (0 <> FThreadId) then
  begin
    // signal anyone waiting or looping that this thread should exit
    FTerminated := true;
    SetEvent(FShouldFinishEvent);

    // make sure that the thread is processing messages to get the termination flag.
    PostThreadMessage(FThreadId, WM_QUIT, 0, 0 );
    if AWaitTillFinished then
    begin
      LWaitResult := WaitForSingleObject(FFinishedEvent, AMilliseconds );
      if (WAIT_OBJECT_0 = LWaitResult) then
      begin
        Result := TRUE;
      end else
      begin
        Result := FALSE;
      end;
      CloseHandle(FFinishedEvent);
      CloseHandle(FShouldFinishEvent);
      CloseHandle(FStartedEvent);
      FFinishedEvent := 0;
      FThreadHandle := 0;
      OnAfterThreadEnd();
    end;
  end;
end;

end.
