unit uExec;

interface

uses SysUtils, Windows, Forms, Messages, Clipbrd;

type
   TComando = (TCEnter, TCSetaBaixo, TCSetaDir);
   PDadoProcura = ^TDadoProcura;
   TDadoProcura = record
      Win : THandle;
      YPos: Integer;
   end;

   TExec = class(tObject)
      private
         const
            QT_ITENS = 21;
            JUSTIFICATIVA = 'Nao se aplica';
            PROJECT = 'SiagriProject';
         var
            FHandle: HWnd;
            FOpc: string;
         function  TrazerProjectParaFrente: boolean;
         function  EvnviarProjectParaTras: boolean;         
         procedure ExecutaComando(pCmd: TComando);
         procedure SelecionaNaoSeAplica;
         procedure EscreveJustificativa;
         function  ListaFilhos(Win: THandle; lp: LPARAM): Boolean; stdcall; //internet
      public
         procedure Sim;
         procedure SimNaoSeAplica;
   end;

implementation

{ TExec }

procedure TExec.EscreveJustificativa;
var
   lChar: Char;
   lCodigo: integer;
   lTexto: string;
begin
//   ClipBoard.AsText = JUSTIFICATIVA;
   { Mantém pressionada CTRL }
   keybd_event(VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY or 0, 0);

   { Pressiona V }
   keybd_event(Ord('V'), 0, 0, 0);

   { Libera (solta) CTRL }
   keybd_event(VK_CONTROL, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0)
//   Sleep(100);
//   for lChar in JUSTIFICATIVA do
//   begin
//      lCodigo := Ord(lChar);
//      keybd_event(lCodigo, 0, 0, 0);
//   end;
end;

function TExec.EvnviarProjectParaTras: boolean;
begin
   if FHandle <> 0 then
   begin
      SetWindowPos(FHandle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
   end;
end;

procedure TExec.ExecutaComando(pCmd: TComando);
begin
   case pCmd of
      TCEnter: keybd_event(VK_RETURN, 0, 0, 0);
      TCSetaBaixo: keybd_event(VK_DOWN, 0, 0, 0);
      TCSetaDir: keybd_event(VK_RIGHT, 0, 0, 0);
   end;
   Sleep(100);
end;

procedure TExec.SelecionaNaoSeAplica;
var
   lIndexIn: Integer;
begin
   for lIndexIn := 1 to 3 do
   begin
      ExecutaComando(TCSetaBaixo);
   end;
end;

procedure TExec.Sim;
var
   lIndex: Integer;
begin
   if TrazerProjectParaFrente then
   begin
      ExecutaComando(TCSetaDir);
      ExecutaComando(TCSetaBaixo);
      ExecutaComando(TCEnter);
      for lIndex := 1 to QT_ITENS do
      begin
         ExecutaComando(TCEnter);
         ExecutaComando(TCSetaBaixo);
         ExecutaComando(TCEnter);
      end;
      EvnviarProjectParaTras;
   end;
end;

procedure TExec.SimNaoSeAplica;
var
   lIndex: Integer;
   lIndexIn: Integer;
   Buffer: array[0..80] of char;
   lText: HWND;
begin
   if TrazerProjectParaFrente then
   begin
      ExecutaComando(TCSetaDir);
      SelecionaNaoSeAplica;
      ExecutaComando(TCEnter);
      EscreveJustificativa;
      ExecutaComando(TCEnter);
   end;
end;

function TExec.TrazerProjectParaFrente: boolean;
begin
   FHandle := FindWindow(nil, PROJECT);
   Result := FHandle <> 0;
   if Result then
   begin
      BringWindowToTop(FHandle);
      SetWindowPos(FHandle, Hwnd_TopMost,0, 0, 0, 0, SWP_SHOWWINDOW Or SWP_NOSIZE Or SWP_NOACTIVATE);
      SetForegroundWindow(FHandle);
      ShowWindow(FHandle, SW_SHOWNORMAL);   
   end;
end;

function TExec.ListaFilhos(Win: THandle; lp: LPARAM): Boolean; stdcall;
var
   P: PDadoProcura;
   R: TRect;
   ClassName: array[0..255] of char;
begin
   P:=PDadoProcura(lp);
   GetClassName(Win, ClassName, sizeof(ClassName));
   //Verifica se é um campo estático
   If StrPas(ClassName) = 'Static' then
      begin
         //Verifica se está visível
         If IsWindowVisible(Win) then
            begin
               //Pega a posição e o tamanho da janela
               GetWindowRect(Win, R);
               //Verifica se a coordenada Y é menor
               If R.Top < P^.YPos then
                  begin
                     //&#9556;, assume que é esta
                     P^.YPos := R.Top;
                     P^.Win := Win;
                  end;
            end;
      end;
      //Continua chamando a enumeração
      Result:=True;
end;

end.

