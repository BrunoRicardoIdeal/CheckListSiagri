program CheckSimNaoSeAplica;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uExec in 'uExec.pas';

var
   lEx: TExec;
begin
   lEx := TExec.Create;
   try
      lEx.SimNaoSeAplica;
      readln;
   finally
      lEx.Free;
   end;
end.

