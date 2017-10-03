unit ExPropStorage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, DB, DbCtrls;

type

  { TExPropDataProvider }

  TExPropDataProvider = class(TComponent)
  protected
    function DoReadString(const Section, Ident, DefaultValue: string): string; virtual; abstract;
    procedure DoWriteString(const Section, Ident, Value: string); virtual; abstract;
    procedure DoEraseSections(const ARootSection: String); virtual; abstract;
  public
    procedure StorageNeeded(ReadOnly: Boolean); virtual; abstract;
    procedure FreeStorage; virtual; abstract;

    function ReadString(const ASection, AIdent: String; ADefaulValue: String = ''): String;
    function ReadInteger(const ASection, AIdent: String; ADefaulValue: Integer = 0): Integer;
    function ReadBoolean(const ASection, AIdent: String; ADefaulValue: Boolean = False): Boolean;
    procedure WriteString(const ASection, AIdent: String; AValue: String);
    procedure WriteInteger(const ASection, AIdent: String; AValue: Integer);
    procedure WriteBoolean(const ASection, AIdent: String; AValue: Boolean);
  end;

  { TExPropStorage }

  TExPropStorage = class(TFormPropertyStorage)
  private
    FDataProvider: TExPropDataProvider;
    FSectionPrefix: String;
  protected
    procedure DoEraseSections(const ARootSection: String); override;
    function DoReadString(const Section, Ident, DefaultValue: string): string;
      override;
    procedure DoWriteString(const Section, Ident, Value: string); override;
  public
    procedure StorageNeeded(ReadOnly: Boolean); override;
    procedure FreeStorage; override;
  published
    property Active;
    property DataProvider: TExPropDataProvider read FDataProvider write FDataProvider;
    property SectionPrefix: String read FSectionPrefix write FSectionPrefix;
    property StoredValues;
    property OnSavingProperties;
    property OnSaveProperties;
    property OnRestoringProperties;
    property OnRestoreProperties;
  end;

  TDBPropStorageOptions = set of (dsoAutoOpen, dsoAutoClose, dsoUseIdentField);

  { TExPSDataSetProvider }

  TExPSDataSetProvider = class(TExPropDataProvider)
  private
    FAccessCounter: Integer;
    FDataSource: TDataSource;
    FIdentLink: TFieldDataLink;
    FSectionLink: TFieldDataLink;
    FValueLink: TFieldDataLink;
    FOptions: TDBPropStorageOptions;
  private
    function GetIdentField: String;
    function GetSectionField: String;
    function GetValueField: String;
    procedure SetDataSource(AValue: TDataSource);
    procedure SetIdentField(AValue: String);
    procedure SetSectionField(AValue: String);
    procedure SetValueField(AValue: String);
  protected
    function DoReadString(const Section, Ident, DefaultValue: string): string;
       override;
    procedure DoWriteString(const Section, Ident, Value: string); override;
    procedure DoEraseSections(const ARootSection: String); override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure StorageNeeded(ReadOnly: Boolean); override;
    procedure FreeStorage; override;
  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property SectionField: String read GetSectionField write SetSectionField;
    property IdentField: String read GetIdentField write SetIdentField;
    property ValueField: String read GetValueField write SetValueField;
    property Options: TDBPropStorageOptions read FOptions write FOptions;
  end;

implementation

uses
  variants;

{ TExPropDataProvider }

function TExPropDataProvider.ReadString(const ASection, AIdent: String;
  ADefaulValue: String): String;
begin
  Result := DoReadString(ASection, AIdent, ADefaulValue);
end;

function TExPropDataProvider.ReadInteger(const ASection, AIdent: String;
  ADefaulValue: Integer): Integer;
begin
  Result := StrToIntDef(DoReadString(ASection, AIdent, ''), ADefaulValue);
end;

function TExPropDataProvider.ReadBoolean(const ASection, AIdent: String;
  ADefaulValue: Boolean): Boolean;
begin
  Result := StrToBoolDef(DoReadString(ASection, AIdent, ''), ADefaulValue);
end;

procedure TExPropDataProvider.WriteString(const ASection, AIdent: String;
  AValue: String);
begin
  DoWriteString(ASection, AIdent, AValue);
end;

procedure TExPropDataProvider.WriteInteger(const ASection, AIdent: String;
  AValue: Integer);
begin
  DoWriteString(ASection, AIdent, IntToStr(AValue));
end;

procedure TExPropDataProvider.WriteBoolean(const ASection, AIdent: String;
  AValue: Boolean);
begin
  DoWriteString(ASection, AIdent, BoolToStr(AValue));
end;

{ TExPSDataSetProvider }

function TExPSDataSetProvider.GetIdentField: String;
begin
  Result := FIdentLink.FieldName;
end;

function TExPSDataSetProvider.GetSectionField: String;
begin
  Result := FSectionLink.FieldName;
end;

function TExPSDataSetProvider.GetValueField: String;
begin
  Result := FValueLink.FieldName;
end;

procedure TExPSDataSetProvider.SetDataSource(AValue: TDataSource);
begin
  if FDataSource = AValue then Exit;
  FDataSource := AValue;
  FIdentLink.DataSource := AValue;
  FSectionLink.DataSource := AValue;
  FValueLink.DataSource := AValue;
end;

procedure TExPSDataSetProvider.SetIdentField(AValue: String);
begin
  FIdentLink.FieldName := AValue;
end;

procedure TExPSDataSetProvider.SetSectionField(AValue: String);
begin
  FSectionLink.FieldName := AValue;
end;

procedure TExPSDataSetProvider.SetValueField(AValue: String);
begin
  FValueLink.FieldName := AValue;
end;

function TExPSDataSetProvider.DoReadString(const Section, Ident,
  DefaultValue: string): string;
var
  Found: Boolean;
begin
  if dsoUseIdentField in Options then
    Found := FDataSource.DataSet.Locate(FSectionLink.FieldName+';'+FIdentLink.FieldName, VarArrayOf([Section, Ident]), [loCaseInsensitive])
  else
    Found := FDataSource.DataSet.Locate(FSectionLink.FieldName, Section + '\' + Ident, [loCaseInsensitive]);
  if Found and (not FValueLink.Field.IsNull) then
    Result := FValueLink.Field.AsString
  else
    Result := DefaultValue;
end;

procedure TExPSDataSetProvider.DoWriteString(const Section, Ident, Value: string
  );
var
  Found: Boolean;
begin
  if dsoUseIdentField in Options then
    Found := FDataSource.DataSet.Locate(FSectionLink.FieldName+';'+FIdentLink.FieldName, VarArrayOf([Section, Ident]), [loCaseInsensitive])
  else
    Found := FDataSource.DataSet.Locate(FSectionLink.FieldName, Section + '\' + Ident, [loCaseInsensitive]);
  if Found then
    FDataSource.DataSet.Edit
  else
  begin
    FDataSource.DataSet.Append;
    FSectionLink.Field.AsString:=Section;
    FIdentLink.Field.AsString:=Ident;
  end;
  FValueLink.Field.AsString:=Value;
  FDataSource.DataSet.Post;
end;

procedure TExPSDataSetProvider.DoEraseSections(const ARootSection: String);
begin
  while FDataSource.DataSet.Locate(FSectionLink.FieldName, ARootSection, [loCaseInsensitive, loPartialKey]) do
    FDataSource.DataSet.Delete;
end;

constructor TExPSDataSetProvider.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FIdentLink := TFieldDataLink.Create;
  FSectionLink := TFieldDataLink.Create;
  FValueLink := TFieldDataLink.Create;
  FOptions := [dsoUseIdentField];
end;

destructor TExPSDataSetProvider.Destroy;
begin
  FIdentLink.Free;
  FSectionLink.Free;
  FValueLink.Free;
  inherited Destroy;
end;

procedure TExPSDataSetProvider.StorageNeeded(ReadOnly: Boolean);
begin
  if (dsoAutoOpen in FOptions) and not FDataSource.DataSet.Active then
  begin
    FDataSource.DataSet.Active := True;
    FAccessCounter := 0;
  end;
  Inc(FAccessCounter);
end;

procedure TExPSDataSetProvider.FreeStorage;
begin
  Dec(FAccessCounter);
  if (dsoAutoClose in FOptions) and (FAccessCounter <= 0) and (not (csDestroying in ComponentState)) then
    FDataSource.DataSet.Active := False;
end;

{ TExPropStorage }

procedure TExPropStorage.DoEraseSections(const ARootSection: String);
begin
  if Assigned(FDataProvider) then
    FDataProvider.DoEraseSections(FSectionPrefix + ARootSection);
end;

function TExPropStorage.DoReadString(const Section, Ident, DefaultValue: string
  ): string;
begin
  if Assigned(FDataProvider) then
    Result := FDataProvider.DoReadString(FSectionPrefix + Section, Ident, DefaultValue)
  else
    Result := DefaultValue;
end;

procedure TExPropStorage.DoWriteString(const Section, Ident, Value: string);
begin
  if Assigned(FDataProvider) then
    FDataProvider.DoWriteString(FSectionPrefix + Section, Ident, Value);
end;

procedure TExPropStorage.StorageNeeded(ReadOnly: Boolean);
begin
  if Assigned(FDataProvider) then
    FDataProvider.StorageNeeded(ReadOnly);
end;

procedure TExPropStorage.FreeStorage;
begin
  if not (csDestroying in ComponentState) and  Assigned(FDataProvider) then
    FDataProvider.FreeStorage;
end;

end.
