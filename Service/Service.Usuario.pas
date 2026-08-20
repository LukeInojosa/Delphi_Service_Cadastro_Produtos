unit Service.Usuario;

interface uses
  Model.Usuario,
  Service,
  System.JSON,
  FireDAC.Comp.Client,
  Database.Query,
  GBJSON.Helper,
  System.Generics.Collections,
  System.Rtti;
type
  IService = Service.IService;
  TFDQuery = FireDAC.Comp.Client.TFDQuery;
  TUsuario = Model.Usuario.TUsuario;
  RUsuario = Model.Usuario.RUsuario;

type TServiceUsuario = class(TService)
  private
    Query: TFDQuery;
  public
    constructor Create();
    destructor Destroy(); override;
    function Criar(data: TUsuario): TObjectList<TUsuario>;
    function Consulta(data: TUsuario): TObjectList<TUsuario>;
    function Excluir(data: TUsuario): TObjectList<TUsuario>;
    function Alterar(data: TUsuario): TObjectList<TUsuario>;
    function CheckAutentication(data: TUsuario): Boolean;
    function ConsultaPorId(id: Uint64): TUsuario;
end;

implementation

uses
  System.SysUtils, Errors.Api, Data.DB;

{ TServiceUsuario }

function TServiceUsuario.Alterar(data: TUsuario): TObjectList<TUsuario>;
begin

end;

function TServiceUsuario.CheckAutentication(data: TUsuario): Boolean;
var
  arrJSON: TJSONArray;
  obj: TJSONObject;
begin
  if not (
    Assigned(data) and
    data.isFilled.Items['nome'] and
    data.isFilled.Items['senha']
  ) then
    raise EValidation.Create('Erro De Validacao de Dados');

  Self.Query
    .StartQuery
    .AddToQuery('SELECT * FROM USUARIO')
    .AddToQuery('WHERE NOME = :NOME')
    .AddToQuery('AND SENHA = :SENHA')
    .SetParam('NOME', data.nome)
    .SetParam('SENHA', data.senha)
    .Open;
  Writeln(Self.Query.RecordCount);
  Result := (Self.Query.RecordCount > 0);
end;

function TServiceUsuario.Consulta(data: TUsuario): TObjectList<TUsuario>;
var
  arrJSON: TJSONArray;
  obj: TJSONObject;
begin
  Writeln('- Produto : Realizando Consulta');

  // constroi Query
  Self.Query
    .StartQuery
    .AddToQuery('SELECT ' + data.getAllFields(False,'',['senha']))
    .AddToQuery('FROM USUARIO WHERE 1 = 1');

  if Assigned(data) then
  begin
    if data.isFilled.Items['id'] then
      Self.Query
        .AddToQuery('AND ID = :ID ')
        .SetParam('ID', data.id);
    if data.isFilled.Items['nome'] then
      Self.Query
        .AddToQuery('AND nome = :nome ')
        .SetParam('nome', data.nome);
    if data.isFilled.Items['id_almoxarifado'] then
      Self.Query
        .AddToQuery('AND id_almoxarifado = :id_almoxarifado ')
        .SetParam('id_almoxarifado', data.id_almoxarifado);
  end;

  Self.Query.Open();

  // trata saida da query
  arrJSON := Self.Query.ConvertQueryToJSONArray();

  // constroi array de retorno
  if arrJSON.Count = 0 then
  begin
    Writeln('Nenhum dado foi encontrado');
    Exit(TObjectList<TUsuario>.Create);
  end;

  writeln(arrJSON.ToJSON);
  Result := TGBJSONDefault.Serializer<TUsuario>
                                    .JsonStringToList(arrJSON.ToJSON);
end;

function TServiceUsuario.ConsultaPorId(id: Uint64): TUsuario;
var
  arrJson: TJSONArray;
begin
  Result := TUsuario.Create;

  Self.Query
    .StartQuery
    .AddToQuery('SELECT * FROM USUARIO WHERE ID = :ID')
    .SetParam('ID', id)
    .Open();

  if Self.Query.RecordCount = 0 then
    Exit(nil);

  arrJson := Self.Query.ConvertQueryToJSONArray(True, Result.isFilled.Keys.ToArray);

  Result.FromJSONObject(arrJson.Get(0) as TJSONObject);
end;

constructor TServiceUsuario.Create;
begin
  inherited;
  Self.Query := TFDQuery.Create(nil);
  Self.Query.ConnectToDatabase(
    Self.FConnection
  );
end;

function TServiceUsuario.Criar(data: TUsuario): TObjectList<TUsuario>;
var
  json: TJSONObject;
  arrJson: TJSONArray;
  fieldName: String;
  field: TField;
begin
  if not (
    Assigned(data) and
    data.isFilled.Items['nome'] and
    data.isFilled.Items['senha'] and
    data.isFilled.Items['id_almoxarifado'])
  then
    raise EValidation.Create('Erro De Validacao de Dados');

  data.Show();
  Writeln(data.getAllFields(True));
  Self.Query
    .StartQuery
    .AddToQuery('INSERT INTO USUARIO')
    .AddToQuery('(' + data.getAllFields(True) + ')')
    .AddToQuery('VALUES')
    .AddToQuery('(' + data.getAllFields(True, ':') + ')')
    .AddToQuery('RETURNING ')
    .AddToQuery(data.getAllFields(False,'',['senha']))
    .SetAllParams<TUsuario>(data)
    .Open();

  json := TJSONObject.Create();

  for fieldName in data.isFilled.Keys.ToArray do
  begin
    field := Self.Query.FindField(fieldName);
    if Assigned(field) then
      json.AddPair(fieldName,field.AsString);
  end;

  arrJSON := TJSONArray.Create;
  arrJSON.AddElement(json);

  Result := TGBJSONDefault.Serializer<TUsuario>
                          .JsonStringToList(arrJSON.ToJSON);
end;

destructor TServiceUsuario.Destroy;
begin
  Self.Query.free;
  inherited;
end;

function TServiceUsuario.Excluir(data: TUsuario): TObjectList<TUsuario>;
var
  jsonResult : TJSONArray;
begin
  if not (
    Assigned(data) and
    data.isFilled.Items['nome'] and
    data.isFilled.Items['senha']
  )then
     raise EValidation.Create('Erro De Validacao de Dados');

  Self.Query
    .StartQuery
    .AddToQuery('DELETE FROM USUARIO')
    .AddToQuery('WHERE NOME = :NOME')
    .AddToQuery('AND SENHA = :SENHA')
    .SetParam('NOME', data.nome)
    .SetParam('SENHA', data.senha)
    .AddToQuery('RETURNING NOME, ID_ALMOXARIFADO')
    .Open();

  jsonResult := Self.Query.ConvertQueryToJSONArray(True,['nome','id_almoxarifado']);

  Result := TGBJSONDefault.Serializer<TUsuario>
                          .JsonStringToList(jsonResult.ToJSON);
end;

end.
