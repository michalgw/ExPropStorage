unit exps_mdoreg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure Register;

implementation

uses
  MDOPropDataProvider;

procedure Register;
begin
  RegisterComponents('ExPropStorage', [TMDOPropDataProvider]);
end;

end.

