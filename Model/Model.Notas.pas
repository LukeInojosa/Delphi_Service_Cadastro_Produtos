unit Model.Notas;
interface uses
  Model,
  GBSwagger.Model.Attributes,
  System.SysUtils,
  Database.Query,
  Helper.TObject,
  System.Rtti,
  GBJSON.DateTime.Helper;

type TNotas  = class(TModel)
  private
    FId : uInt64;
    FTipoOperacao : Integer;
    FDataRegistro : TDateTime;
    FObservacao : String;
    FConcluida : Boolean;
    FUsuarioResponsavel : uInt64;
    FIdAlmoxarifado : uInt64;

    procedure SetId(data: uInt64);
    procedure SetTipoOperacao(data: Integer);
    procedure SetDataRegistro(data: TDateTime);
    procedure SetObservacao(data: String);
    procedure SetConcluida(data: Boolean);
    procedure SetUsuarioResponsavel(data: uInt64);
    procedure SetIdAlmoxarifado(data: uInt64);

  public

    [SwagProp('id','',False, True)]
    property id: uInt64 read FId write SetId;

    [SwagProp('tipo_operacao','', False)]
    property tipo_operacao: Integer read FTipoOperacao write SetTipoOperacao;

    [SwagProp('data_registro','',False)]
    property data_registro: TDateTime read FDataRegistro write SetDataRegistro;

    [SwagProp('observacao','',False)]
    property observacao: String read FObservacao write SetObservacao;

    [SwagProp('concluida','',False)]
    property concluida: Boolean read FConcluida write SetConcluida;

    [SwagProp('usuario_responsavel','',False)]
    property usuario_responsavel: uInt64 read FUsuarioResponsavel write SetUsuarioResponsavel;

    [SwagProp('id_almoxarifado','',False)]
    property id_almoxarifado: uInt64 read FIdAlmoxarifado write SetIdAlmoxarifado;

    constructor Create();
    procedure Show();
end;

type RNotas = Record
    id : uInt64;
    tipo_operacao : Integer;
    data_registro : TDateTime;
    observacao : String;
    concluida : Boolean;
    usuario_responsavel : uInt64;
    id_almoxarifado : uInt64;
End;

implementation

uses
  System.Generics.Collections;

{ TNotas }

constructor TNotas.Create;
var
  paramName: String;
begin
  inherited;
  for paramName in Self.getPropNames() do
    isFilled.AddOrSetValue(paramName, False);

  FId := 0;
  FTipoOperacao := 0;
  FDataRegistro := Now ;
  FObservacao := '';
  FConcluida := False;
  FUsuarioResponsavel := 0;
  FIdAlmoxarifado := 0;
end;

procedure TNotas.SetConcluida(data: Boolean);
const
  columnName = 'CONCLUIDA';
begin
  isFilled.Items[columnName.ToLower] := True;
  FConcluida := data;
end;

procedure TNotas.SetDataRegistro(data: TDateTime);
const
  columnName = 'DATA_REGISTRO';
begin
  isFilled.Items[columnName.ToLower] := True;
  FDataRegistro := data;
end;

procedure TNotas.SetId(data: uInt64);
const
  columnName = 'ID';
begin
  isFilled.Items[columnName.ToLower] := True;
  FId := data;
end;

procedure TNotas.SetIdAlmoxarifado(data: uInt64);
const
  columnName = 'ID_ALMOXARIFADO';
begin
  isFilled.Items[columnName.ToLower] := True;
  FIdAlmoxarifado := data;
end;

procedure TNotas.SetObservacao(data: String);
const
  columnName = 'OBSERVACAO';
begin
  isFilled.Items[columnName.ToLower] := True;
  FObservacao := data;
end;

procedure TNotas.SetTipoOperacao(data: Integer);
const
  columnName = 'TIPO_OPERACAO';
begin
  isFilled.Items[columnName.ToLower] := True;
  FTipoOperacao := data;
end;

procedure TNotas.SetUsuarioResponsavel(data: uInt64);
const
  columnName = 'USUARIO_RESPONSAVEL';
begin
  isFilled.Items[columnName.ToLower] := True;
  FUsuarioResponsavel := data;
end;

procedure TNotas.Show;
begin
  Writeln(Format('{ id: %s, tipo_operacao: %s, data_registro, %s, observacao: %s, concluida: %s, usuario_responsavel: %s, id_almoxarifado: %s}',
          [id.ToString,
          tipo_operacao.toString,
          data_registro,
          observacao,
          concluida.ToString,
          usuario_responsavel.toString,
          id_almoxarifado.toString]));
end;

end.
