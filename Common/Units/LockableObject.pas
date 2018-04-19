{*******************************************************}
{                                                       }
{      Copyright(c) 2003-2016 Oamaru Group , Inc.       }
{                                                       }
{   Copyright and license exceptions noted in source    }
{                                                       }
{*******************************************************}
unit LockableObject;

interface

uses
  SysUtils, Classes, SyncObjs;

type
  TLockableObject = class(TInterfacedObject)
    private
      FCriticalSection: TCriticalSection;
    protected
      procedure Lock;
      procedure Unlock;
    public
      constructor Create; virtual;
      destructor Destroy; override;
  end;

implementation

constructor TLockableObject.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TLockableObject.Destroy;
begin
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TLockableObject.Lock;
begin
  FCriticalSection.Acquire;
end;

procedure TLockableObject.Unlock;
begin
  FCriticalSection.Release;
end;

end.
