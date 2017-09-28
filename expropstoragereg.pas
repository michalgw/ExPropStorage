unit expropstoragereg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

uses
  ExPropStorage;

procedure Register;
begin
  RegisterComponents('ExPropStorage', [TExPropStorage, TExPSDataSetProvider]);
end;

end.

