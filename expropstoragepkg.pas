{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit expropstoragepkg;

{$warn 5023 off : no warning about unused units}
interface

uses
  ExPropStorage, expropstoragereg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('expropstoragereg', @expropstoragereg.Register);
end;

initialization
  RegisterPackage('expropstoragepkg', @Register);
end.
