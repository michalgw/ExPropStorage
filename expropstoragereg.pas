unit expropstoragereg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

uses
  ExPropStorage;

{$R expropstoragepkg.res}

procedure Register;
begin
  RegisterComponents('ExPropStorage', [TExPropStorage, TExPSDataSetProvider]);
end;

end.

