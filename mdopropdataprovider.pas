unit MDOPropDataProvider;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  ExPropStorage, MDODatabase, MDOSQL;

type

  { TMDOPropDataProvider }

  TMDOPropDataProvider = class(TExPropDataProvider)
  private
    FDatabase: TMDODataBase;
    FTransaction: TMDOTransaction;
    FTableName: String;
    FSectionField: String;
    FIdentField: String;
    FValueField: String;
  protected
    procedure DoEraseSections(const ARootSection: String); override;
    function DoReadString(const Section, Ident, DefaultValue: string): string;
      override;
    procedure DoWriteString(const Section, Ident, Value: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure StorageNeeded(ReadOnly: Boolean); override;
    procedure FreeStorage; override;
  published
    property Database: TMDODataBase read FDatabase write FDatabase;
    property Transaction: TMDOTransaction read FTransaction write FTransaction;
    property TableName: String read FTableName write FTableName;
    property SectionField: String read FSectionField write FSectionField;
    property IdentField: String read FIdentField write FIdentField;
    property ValueField: String read FValueField write FValueField;
  end;

implementation

{ TMDOPropDataProvider }

procedure TMDOPropDataProvider.DoEraseSections(const ARootSection: String);
const
  DEL_SQL = 'delete from %s where %s = :VSECTION';
var
  FQ: TMDOSQL;
begin
  if not Assigned(FDatabase) then
    Exit;
  FQ := TMDOSQL.Create(nil);
  FQ.Database := FDatabase;
  if Assigned(FTransaction) then
    FQ.Transaction := FTransaction
  else
    FQ.Transaction := FDatabase.DefaultTransaction;
  FQ.SQL.Text := Format(DEL_SQL, [FTableName, FSectionField]);
  FQ.ParamByName('VSECTION').AsString := ARootSection + '%';
  if not FQ.Transaction.Active then
    FQ.Transaction.StartTransaction;
  FQ.ExecQuery;
  FQ.Transaction.Commit;
  FQ.Free;
end;

function TMDOPropDataProvider.DoReadString(const Section, Ident,
  DefaultValue: string): string;
const
  SEL_SQL = 'select %s from %s where %s = :VSECTION and %s = :VIDENT';
var
  FQ: TMDOSQL;
begin
  if not Assigned(FDatabase) then
    Exit;
  FQ := TMDOSQL.Create(nil);
  FQ.Database := FDatabase;
  if Assigned(FTransaction) then
    FQ.Transaction := FTransaction
  else
    FQ.Transaction := FDatabase.DefaultTransaction;
  FQ.SQL.Text := Format(SEL_SQL, [FValueField, FTableName, FSectionField, FIdentField]);
  FQ.ParamByName('VSECTION').AsString := Section;
  FQ.ParamByName('VIDENT').AsString := Ident;
  if not FQ.Transaction.Active then
    FQ.Transaction.StartTransaction;
  FQ.ExecQuery;
  if FQ.RecordCount > 0 then
    Result := FQ.FieldByName(FValueField).AsString
  else
    Result := DefaultValue;
  FQ.Transaction.Commit;
  FQ.Free;
end;

procedure TMDOPropDataProvider.DoWriteString(const Section, Ident, Value: string
  );
const
  SEL_SQL = 'select count(*) from %s where %s = :VSECTION and %s = :VIDENT';
  UPD_SQL = 'update %s set %s = :VVALUE where %s = :VSECTION and %s = :VIDENT';
  INS_SQL = 'insert into %s (%s, %s, %s) values (:VSECTION, :VIDENT, :VVALUE)';
var
  FQ: TMDOSQL;
begin
  if not Assigned(FDatabase) then
    Exit;
  FQ := TMDOSQL.Create(nil);
  FQ.Database := FDatabase;
  if Assigned(FTransaction) then
    FQ.Transaction := FTransaction
  else
    FQ.Transaction := FDatabase.DefaultTransaction;
  FQ.SQL.Text := Format(SEL_SQL, [FTableName, FSectionField, FIdentField]);
  FQ.ParamByName('VSECTION').AsString := Section;
  FQ.ParamByName('VIDENT').AsString := Ident;
  if not FQ.Transaction.Active then
    FQ.Transaction.StartTransaction;
  FQ.ExecQuery;
  if (FQ.RecordCount > 0) and (FQ.Fields[0].AsInteger > 0) then
  begin
    FQ.Close;
    FQ.SQL.Text := Format(UPD_SQL, [FTableName, FValueField, FSectionField, FIdentField]);
  end
  else
  begin
    FQ.Close;
    FQ.SQL.Text := Format(INS_SQL, [FTableName, FSectionField, FIdentField, FValueField]);
  end;
  FQ.ParamByName('VVALUE').AsString := Value;
  FQ.ParamByName('VSECTION').AsString := Section;
  FQ.ParamByName('VIDENT').AsString := Ident;
  FQ.ExecQuery;
  FQ.Transaction.Commit;
  FQ.Free;
end;

constructor TMDOPropDataProvider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TMDOPropDataProvider.Destroy;
begin
  inherited Destroy;
end;

procedure TMDOPropDataProvider.StorageNeeded(ReadOnly: Boolean);
begin

end;

procedure TMDOPropDataProvider.FreeStorage;
begin

end;

end.
