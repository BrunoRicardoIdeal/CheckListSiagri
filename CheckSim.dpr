program CheckSim;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  uExec in 'uExec.pas';

var
   lEx: TExec;
begin
   lEx := TExec.Create;
   lEx.Sim;

//   keybd_event(VK_RETURN, 0, 0, 0);
//   keybd_event(VK_DOWN, 0, 0, 0);
//   keybd_event(VK_RETURN, 0, 0, 0);
//   keybd_event(VK_RETURN, 0, 0, 0);


//  if lHandle <> 0 then
//    BringWindowToTop(lHandle); // traz para frente
end.

