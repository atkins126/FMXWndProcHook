{*******************************************************}
{                                                       }
{       ����� Windows�� FMX HOOK���ڹ���               }
{       by: ying32                                      }
{       ��Ȩ���� (C) 2020 ��˾��                        }
{                                                       }
{*******************************************************}

unit FMX.WndProcHook;

{$IFNDEF MSWINDOWS}
  {$MESSAGE ERROR 'ֻ��Ӧ����Windows��'}
{$ENDIF}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  FMX.Types,
  FMX.Forms;

type

  {
    �÷���
      �̳��Դ���

      Ȼ����VCL�����������
      procedure WMMove(var msg: TWMMove); message WM_MOVE;

      procedure TForm23.WMMove(var msg: TWMMove);
      begin
        msg.Result := 1;
        Log.d('�յ��ƶ�����Ϣ');
      end;
  }

  TWndProcForm = class(TForm)
  private
    FWndHandle: HWND;
    FObjectInstance: Pointer;
    FDefWindowProc: Pointer;
  private
    procedure MainWndProc(var Message: TMessage);
    procedure HookWndProc;
    procedure UnHookWndProc;
  protected
    /// <summary>
    ///   WndProc
    /// </summary>
    procedure WndProc(var Message: TMessage); virtual;
  public
    destructor Destroy; override;
    procedure DoShow; override;
  end;

implementation

uses
  FMX.Platform.Win;

{ TWndProcForm }

 

destructor TWndProcForm.Destroy;
begin
  UnHookWndProc;
  inherited;
end;

procedure TWndProcForm.DoShow;
begin
  HookWndProc;
  inherited;
end;

procedure TWndProcForm.HookWndProc;
begin
  // ��HOOK
  if FObjectInstance <> nil then
    Exit;
    
  if FWndHandle = 0  then
    FWndHandle := FmxHandleToHWND(Self.Handle);
    
  if FWndHandle > 0 then
  begin
    if FObjectInstance = nil then
    begin
      FObjectInstance := MakeObjectInstance(MainWndProc);
      if FObjectInstance <> nil then
      begin
        FDefWindowProc := Pointer(GetWindowLong(FWndHandle, GWL_WNDPROC));
        SetWindowLong(FWndHandle, GWL_WNDPROC, IntPtr(FObjectInstance));
      end;
    end;
  end;
end;

procedure TWndProcForm.MainWndProc(var Message: TMessage);
begin
  try
    WndProc(Message);
  except
    Application.HandleException(Self);
  end;
  if Message.Result = 0 then
    Message.Result := CallWindowProc(FDefWindowProc, FWndHandle, Message.Msg, Message.WParam, Message.LParam);
end;

procedure TWndProcForm.UnHookWndProc;
begin
  if FDefWindowProc <> nil then
  begin
    SetWindowLong(FWndHandle, GWL_WNDPROC, IntPtr(FDefWindowProc));
    FDefWindowProc := nil;
  end;
  if FObjectInstance <> nil then
  begin
    FreeObjectInstance(FObjectInstance);
    FObjectInstance := nil;
  end;
end;

 
procedure TWndProcForm.WndProc(var Message: TMessage);
begin
  Dispatch(Message);
end;

end.
