unit Controller.Notas;

interface

uses
  Controller,
  Model.Notas,
  GBSwagger.Path.Attributes,
  Horse.GBSwagger.Registry,
  Horse.GBSwagger.Controller;

type
  [SwagPath('notas', 'Notas')]
  TControllerNotas = class(THorseGBSwagger)
  public
    [SwagGET('{id}','Consulta Notas')]
    [SwagParamPath('id', 'id da nota sendo buscada', True, False)]
    [SwagParamQuery('tipo_operacao','', False, True)]
    [SwagParamQuery('data_registro')]
    [SwagParamQuery('concluida')]
    [SwagParamQuery('usuario_responsavel','', False, True)]
    [SwagParamQuery('id_almoxarifado','', False, True)]
    [SwagResponse(200,TNotas, True)]
    procedure Get;

    [SwagPost('Cadastra nova Nota')]
    [SwagParamBody('Nota', TNotas)]
    [SwagResponse(201, TNotas, 'Nota criada')]
    procedure Post;

    [SwagPUT('{id}','Altera Nota')]
    [SwagParamPath('id', 'id da nota que se quer alterar', True, True)]
    [SwagParamBody('Nota', TNotas)]
    [SwagResponse(200,TNotas, 'Nota alterada')]
    procedure Put;

    [SwagDELETE('{id}','Deleta Nota')]
    [SwagParamPath('id', 'id da nota a ser deletada', True)]
    [SwagResponse(200,TNotas, 'Nota Deletada')]
    procedure Delete;
  end;

implementation uses
  Service.Notas,
  GBJSON.Helper,
  Horse.Commons,
  System.SysUtils,
  System.Generics.Collections,
  System.JSON, System.Rtti, Utils, Service.Usuario, Service.Estoque,
  Service.Almoxarifado;
var
  FServiceNotas: TServiceNotas;
  FServiceUsuario: TServiceUsuario;
  FServiceEstoque: TServiceEstoque;
  FServiceAlmoxarifado: TServiceAlmoxarifado;



{ TControllerNotas }

procedure TControllerNotas.Delete;
var
  id: UInt64;
  Nota: TNotas;
begin
  try
    Nota := TNotas.Create;
    if TryStrToUInt64(FRequest.Params['id'], id) then
      Nota.id := id;

    Nota := FServiceNotas.ConsultaPorId(Nota.id);

    if Nota.concluida then
      raise EConflict.Create('Nao eh possivel deletar nota concluida');

    if Assigned(FServiceNotas.getMovimentacao(Nota.id)) then
      raise EConflict.Create('Nao eh possivel deletar nota com movimentacoes');

    Nota := FServiceNotas.Excluir(Nota);

    FResponse
      .Status(THttpStatus.OK)
      .Send(
        TJSONObject.Create
        .AddPair('data', Nota.ToJSONObject)
      );
  finally

  end;
end;

procedure TControllerNotas.Get;
var
  listNotas: TObjectList<TNotas>;
  jsonArray: TJSONArray;
  Nota : TNotas;
  RecNota: RNotas;
begin
  try
    Nota := TNotas.create();

    if TryStrToUInt64(FRequest.Params['id'], RecNota.id) then
      Nota.id := RecNota.id;

    if TryStrToInt(FRequest.Query['tipo_operacao'], RecNota.tipo_operacao) then
      Nota.tipo_operacao := RecNota.tipo_operacao;

    if TryStrToDateTime(FRequest.Query['data_registro'], RecNota.data_registro) then
      Nota.data_registro := RecNota.data_registro;

    if TryStrToBool(FRequest.Query['concluida'], RecNota.concluida) then
      Nota.concluida := RecNota.concluida;

    if TryStrToUInt64(FRequest.Query['usuario_responsavel'], RecNota.usuario_responsavel) then
      Nota.usuario_responsavel := RecNota.usuario_responsavel;

    if TryStrToUInt64(FRequest.Query['id_almoxarifado'], RecNota.id_almoxarifado) then
      Nota.id_almoxarifado := RecNota.id_almoxarifado;

    listNotas := FServiceNotas.Consulta(Nota);

    // construindo resposta
    jsonArray := TGBJSONDefault.Deserializer<TNotas>
                               .ListToJSONArray(listNotas);
    FResponse
      .Status(THttpStatus.OK)
      .Send(
        TJSONObject.Create
        .AddPair('data', jsonArray)
      );
  finally
    Nota.Free;
  end;
end;

procedure TControllerNotas.Post;
var
  jsonBody: TJSONObject;
  Nota: TNotas;
  RecNota: RNotas;
  Session: TUserSession;
  listUsuario: TObjectList<TUsuario>;
  Usuario: TUsuario;
begin
  Usuario := nil;
  Nota := nil;

  Session := FRequest.Sessions.Session[TUserSession] as TUserSession;
  jsonBody := FRequest.Body<TJSONObject>;
  try
    // pega informacoes do usuario que esta criando a nota
    Usuario := TUsuario.Create;
    Usuario.nome := Session.Nome;
    listUsuario := FServiceUsuario.Consulta(Usuario);

    if listUsuario.Count = 0 then
      raise Exception.Create('nao foi possivel achar o usuario que esta criando a nota');

    Nota := TNotas.Create;
    Nota.tipo_operacao := 1; // supoe que operacao eh de entrada se nao for fornecido tipo de operacao
    Nota.usuario_responsavel := listUsuario[0].id;
    Nota.id_almoxarifado := listUsuario[0].id_almoxarifado;
    Nota.concluida := False;
    Nota.data_registro := Now(); // supoe dia atual se valor nao for passado

    if jsonBody.TryGetValue<String>('observacao', RecNota.observacao) then
      Nota.observacao := RecNota.observacao;

    if jsonBody.TryGetValue<Integer>('tipo_operacao', RecNota.tipo_operacao) then
      Nota.tipo_operacao := RecNota.tipo_operacao;

    // valida tipo de operacao da nota
    if (
      (RecNota.tipo_operacao <> 1) and
      (RecNota.tipo_operacao <> -1)
    )  then
      raise EValidation.Create('O tipo de operacao de notas de movimentacao deve ser (1 ou -1)');

    if jsonBody.TryGetValue<UInt64>('id_almoxarfado', RecNota.id_almoxarifado) then
      Nota.id_almoxarifado := RecNota.id_almoxarifado;

    // almoxarifado deve estar ativo para se criar uma nota
    if not FServiceAlmoxarifado.EstaAtivo(RecNota.id_almoxarifado) then
      raise EConflict.Create('Almoxarifado deve existir e estar ativo para se poder criar nota');

    if jsonBody.TryGetValue<UInt64>('usuario_responsavel', RecNota.usuario_responsavel) then
    begin
      if not Assigned(FServiceUsuario.ConsultaPorId(RecNota.usuario_responsavel)) then
         raise EConflict.Create('Usuario deve existir para se criar uma nota');

      Nota.usuario_responsavel := RecNota.usuario_responsavel;
    end;

    if jsonBody.TryGetValue<TDateTime>('data_registro', RecNota.data_registro) then
      Nota.data_registro := RecNota.data_registro;

    Nota :=  FServiceNotas.Criar(Nota);

    FResponse
      .Status(THTTPStatus.Created)
      .Send<TJSONObject>(
        TJSONObject.Create
        .AddPair('data', Nota.ToJSONObject)
      );
  finally
    Nota.Free;
    Usuario.Free;
  end;
end;

procedure TControllerNotas.Put;
var
  Nota: TNotas;
  RecNota: RNotas;
  jsonBody: TJSONObject;
  listNotas: TObjectList<TNotas>;
  arrJson: TJSONArray;
  NotaASerAtualizada: TNotas;
  listEstoqueResultante : TObjectList<TEstoque>;
  Estoque: TEstoque;
begin
  try
    jsonBody := FRequest.Body<TJSONObject>;

    Nota := TNotas.Create;
    if not System.SysUtils.TryStrToUInt64(FRequest.Params['id'], RecNota.id) then
      raise EValidation.Create('Forneca Param (id) da nota que se quer atualizar');

    Nota.id := RecNota.id;
    NotaASerAtualizada := FServiceNotas.ConsultaPorId(RecNota.id);

    if not Assigned(NotaASerAtualizada) then
      raise EConflict.Create('Nota de movimentacao a ser atualizada nao existe');

    if (
      (NotaASerAtualizada.tipo_operacao <> 1) and
      (NotaASerAtualizada.tipo_operacao <> -1)
    ) then
      raise EConflict.Create('Nota de movimentacao a ser atualizada nao existe');

    if NotaASerAtualizada.concluida then
        raise EConflict.Create('Nao eh possivel atualizar nota que ja foi concluida');

    // ou se altera o status de concluida, ou os outros dados da nota.
    // nao eh possivel atualizar os dois ao mesmo tempo
    if not jsonBody.TryGetValue<Boolean>('concluida', RecNota.concluida) then
    begin
      if jsonBody.TryGetValue<Integer>('tipo_operacao', RecNota.tipo_operacao) then
        Nota.tipo_operacao := RecNota.tipo_operacao;

      if (
        (RecNota.tipo_operacao <> 1) and
        (RecNota.tipo_operacao <> -1)
      )then
        raise EValidation.Create('Nota de transferencia deve ter tipo_operacao igual a 1 ou -1');

      if jsonBody.TryGetValue<TDateTime>('data_registro', RecNota.data_registro) then
        Nota.data_registro := RecNota.data_registro;

      if jsonBody.TryGetValue<UInt64>('id_almoxarifado', RecNota.id_almoxarifado) then
      begin
        // almoxarifado deve estar ativo para se atualizar uma nota
        if not FServiceAlmoxarifado.EstaAtivo(RecNota.id_almoxarifado) then
          raise EConflict.Create('Almoxarifado nao ativo ou inexistente nao pode criar nota');
        Nota.id_almoxarifado := RecNota.id_almoxarifado;
      end;

      if jsonBody.TryGetValue<String>('observacao', RecNota.observacao) then
        Nota.observacao := RecNota.observacao;

      if jsonBody.TryGetValue<UInt64>('usuario_responsavel', RecNota.usuario_responsavel) then
      begin
         if not Assigned(FServiceUsuario.ConsultaPorId(RecNota.usuario_responsavel)) then
            raise EConflict.Create('Usuario nao existe');

         Nota.usuario_responsavel := RecNota.usuario_responsavel;
      end;
    end
    else if (NotaASerAtualizada.concluida <> RecNota.concluida) then
    begin
      Nota.concluida := RecNota.concluida;

      // verifica se almoxarifado esta ativo
      if not FServiceAlmoxarifado.EstaAtivo(NotaASerAtualizada.id_almoxarifado) then
        raise Exception.Create('Almoxarifado deve estar ativo para para a conclusao da nota');

      listEstoqueResultante :=  FServiceEstoque.verificaSaldoEstoqueAposMovimentacao(NotaASerAtualizada.id);

      if (
        (NotaASerAtualizada.tipo_operacao = 1) and
        (NotaASerAtualizada.concluida) and
        (not Nota.concluida)
      ) or  (
        (NotaASerAtualizada.tipo_operacao = -1) and
        (not NotaASerAtualizada.concluida) and
        (Nota.concluida)
      )then
      begin
        for Estoque in listEstoqueResultante do
         begin
            // verifica se quantidade resultante no estoque eh menor que 0
           if Estoque.quantidade < 0 then
              raise EConflict.Create('Estoque resultante nao pode ser negativo');

           if Estoque.ativo = False then
            raise EConflict.Create('Nao eh possivel realizar movimentacao em produto nao ativo');
         end;
      end
      else
      begin
        for Estoque in listEstoqueResultante do
         begin
          // verifica se todos os produtos sendo movimentados estao ativos
           if Estoque.ativo = False then
              raise EConflict.Create('Nao eh possivel realizar movimentacao em produto nao ativo');
         end;
      end;


    end;

    listNotas := FServiceNotas.Alterar(Nota);

    arrJSON := TGBJSONDefault.Deserializer<TNotas>
                             .ListToJSONArray(listNotas);

    FResponse.Status(THttpStatus.Created)
       .Send<TJSONObject>(
          TJSONObject.Create
            .AddPair('data', arrJSON.Items[0])
       );
  finally
    Nota.Free;
  end;
end;

initialization
THorseGBSwaggerRegistry.RegisterPath(TControllerNotas);
FServiceNotas := TServiceNotas.Create();
FServiceUsuario := TServiceUsuario.Create;
FServiceEstoque := TServiceEstoque.Create;
FServiceAlmoxarifado := TServiceAlmoxarifado.Create;
finalization
FServiceNotas.Free;
FServiceUsuario.Free;
FServiceEstoque.Free;
FServiceAlmoxarifado.Free;
end.
