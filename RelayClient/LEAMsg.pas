unit LEAMsg;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Generics.Collections;

type
  TLeaMsg = class
  protected
    FMsgSrcID: Integer;
    FNormalDateTime: TDateTime;
    FMessage: String;
    procedure Split;
    function GetDateTime: TDateTime;
    procedure SetDateTime(AValue: TDateTime);
    function GetMessage: AnsiString;
  public
    constructor Create(AMsgString: AnsiString); overload;
    constructor Create(ALeaMsg: TLeaMsg = nil); overload;
    property MsgSrcID: Integer read FMsgSrcID write FMsgSrcID;
    property NormalDateTime: TDateTime read FNormalDateTime write FNormalDateTime;
    property LocalDateTime: TDateTime read GetDateTime write SetDateTime;
    property LogMessage: String read FMessage;
    property Msg: AnsiString read GetMessage;
  end;

  TLeaMsgList = class
  protected
    FCollection: TObjectList<TLeaMsg>;
    function GetMessage(AIndex: Integer): TLeaMsg;
    function GetCount: Integer;
  public
    constructor Create(ALeaMsgList: TLeaMsgList = nil);
    destructor Destroy; override;
    procedure LoadFromFile(AFileName: String);
    property Mesages[AIndex: Integer]: TLeaMsg read GetMessage; default;
    property Count: Integer read GetCount;
  end;

implementation

constructor TLeaMsg.Create(AMsgString: AnsiString);
begin
  FMessage := String(AMsgString);
  Split;
end;

constructor TLeaMsg.Create(ALeaMsg: TLeaMsg = nil);
begin
  FMsgSrcID := 0;
  FNormalDateTime := Now;
  FMessage := String.Empty;
  if nil <> ALeaMsg then
  begin
    FMsgSrcID := ALeaMsg.MsgSrcID;
    FNormalDateTime := ALeaMsg.NormalDateTime;
    FMessage := ALeaMsg.LogMessage;
  end;
end;

procedure TLeaMsg.Split;
var
  LSplit: TStringList;
  LComponent: TStringList;
  LTime: Integer;
begin
  LSplit := TStringList.Create;
  try
    LSplit.Delimiter := '|';
    LSplit.StrictDelimiter := TRUE;
    LSplit.DelimitedText := FMessage;
    LComponent := TStringList.Create;
    try
      LComponent.Delimiter := '=';
      LComponent.StrictDelimiter := TRUE;
      LComponent.DelimitedText := LSplit[0];
      FMsgSrcID := StrToInt(LComponent[1]);
      LComponent.DelimitedText := LSplit[4];
      LTime := StrToInt(LComponent[1]);
      FNormalDateTime := UnixToDateTime(LTime);
    finally
      LComponent.Free;
    end;
  finally
    LSplit.Free;
  end;
end;

function TLeaMsg.GetDateTime: TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime(FNormalDateTime);
end;

procedure TLeaMsg.SetDateTime(AValue: TDateTime);
begin
  FNormalDateTime := TTimeZone.Local.ToUniversalTime(AValue);
end;

function TLeaMsg.GetMessage: AnsiString;
var
  LSplit: TStringList;
  LDateTime: String;
begin
  LSplit := TStringList.Create;
  try
    LSplit.Delimiter := '|';
    LSplit.StrictDelimiter := TRUE;
    LSplit.DelimitedText := FMessage;
    LSplit[0] := Format('MsgSrcID=%d', [FMsgSrcID]);
    LSplit[4] := Format('timeval=%d', [DateTimeToUnix(FNormalDateTime)]);
    LDateTime := FormatDateTime('dmmmyyyy hh:nn:ss', TTimeZone.Local.ToLocalTime(FNormalDateTime));
    if Length(LDateTime) < 18 then
      LDateTime := ' ' + LDateTime;
    LSplit[5] := Format('time=%s', [LDateTime]);
    Result := AnsiString(LSplit.DelimitedText);
  finally
    LSplit.Free;
  end;
end;

constructor TLeaMsgList.Create(ALeaMsgList: TLeaMsgList = nil);
var
  i: Integer;
begin
  FCollection := TObjectList<TLeaMsg>.Create(TRUE);
  if nil <> ALeaMsgList then
  begin
    for i := 0 to (ALeaMsgList.Count - 1) do
      FCollection.Add( TLeaMsg.Create(ALeaMsgList[i]) );
  end;
end;

destructor TLeaMsgList.Destroy;
begin
  FCollection.Clear;
  FCollection.Free;
  inherited Destroy;
end;

procedure TLeaMsgList.LoadFromFile(AFileName: String);
var
  LFileLines: TStringList;
  i: Integer;
begin
  FCollection.Clear;
  LFileLines := TStringList.Create;
  try
    LFileLines.LoadFromFile(AFileName);
    for i := 0 to (LFileLines.Count - 1) do
      FCollection.Add(TLeaMsg.Create(AnsiString(LFileLines[i])));
  finally
    LFileLines.Free;
  end;
end;

function TLeaMsgList.GetMessage(AIndex: Integer): TLeaMsg;
begin
  Result := FCollection[AIndex];
end;

function TLeaMsgList.GetCount: Integer;
begin
  Result := FCollection.Count;
end;

end.
