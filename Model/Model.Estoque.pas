unit Model.Estoque;
interface uses
  Model,
  GBSwagger.Model.Attributes,
  System.SysUtils,
  Database.Query,
  System.Generics.Collections,
  Helper.TObject,
  System.Rtti;

type TEstoque = class(TModel)
  private
    FIdProduto : uInt64;
    FIdAlmoxarifado : uInt64;
    FQuantidade : Integer;
    FAtivo: Boolean;

    procedure SetIdProduto(data : uInt64);
    procedure SetIdAlmoxarifado(data : uInt64);
    procedure SetQuantidade(data : Integer);
    procedure SetAtivo(data : Boolean);
  public

    property id_produto: uInt64 read FIdProduto write SetIdProduto;

    property id_almoxarifado: uInt64 read FIdAlmoxarifado write SetIdAlmoxarifado;

    property quantidade: Integer read FQuantidade write SetQuantidade;

    property ativo: Boolean read FAtivo write SetAtivo;

    constructor Create();
    procedure Show();
end;

type REstoque = Record
  id_produto : uInt64;
  id_almoxarifado : uInt64;
  quantidade : Integer;
  ativo: Boolean;
End;

implementation


{ TEstoque }

constructor TEstoque.Create;
var
  paramName: String;
begin
  inherited;
  for paramName in Self.getPropNames() do
    isFilled.AddOrSetValue(paramName, False);

  FIdProduto := 0;
  FIdAlmoxarifado := 0;
  FQuantidade := 0;
  FAtivo := False ;
end;

procedure TEstoque.SetAtivo(data: Boolean);
var
  columnName:String;
begin
  columnName := 'ATIVO';
  isFilled.Items[columnName.ToLower] := True;
  FAtivo := data;
end;

procedure TEstoque.SetIdAlmoxarifado(data: uInt64);
var
  columnName:String;
begin
  columnName := 'ID_ALMOXARIFADO';
  isFilled.Items[columnName.ToLower] := True;
  FIdAlmoxarifado := data;
end;

procedure TEstoque.SetIdProduto(data: uInt64);
var
  columnName:String;
begin
  columnName := 'ID_PRODUTO';
  isFilled.Items[columnName.ToLower] := True;
  FIdProduto := data;
end;

procedure TEstoque.SetQuantidade(data: Integer);
var
  columnName:String;
begin
  columnName := 'QUANTIDADE';
  isFilled.Items[columnName.ToLower] := True;
  FQuantidade := data;
end;

procedure TEstoque.Show;
begin
      Writeln(Format('{id_produto: %s, id_almoxarifado, %s, quantidade: %s, ativo: %s}',
          [id_produto.ToString,
          id_almoxarifado.ToString,
          quantidade.ToString,
          ativo.ToString]))
end;

end.
