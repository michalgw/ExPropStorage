{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit exps_mdo;

{$warn 5023 off : no warning about unused units}
interface

uses
  MDOPropDataProvider, exps_mdoreg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('exps_mdoreg', @exps_mdoreg.Register);
end;

initialization
  RegisterPackage('exps_mdo', @Register);
end.
