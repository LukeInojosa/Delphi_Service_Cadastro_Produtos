program Project1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.GBSwagger,
  Horse.Jhonson,
  Horse.CORS,
  Horse.BasicAuthentication,
  Router in 'Routes\Router.pas',
  Database.Connection in 'Database\Database.Connection.pas',
  FieldHelper in 'Model\FieldHelper.pas',
  Controller in 'Controller\Controller.pas',
  Enviroment in 'Enviroment.pas',
  Service in 'Service\Service.pas',
  Model.Almoxarifado in 'Model\Model.Almoxarifado.pas',
  Service.Almoxarifado in 'Service\Service.Almoxarifado.pas',
  Database.Query in 'Database\Database.Query.pas',
  Controller.Almoxarifado in 'Controller\Controller.Almoxarifado.pas',
  Middleware.Error in 'Middleware\Middleware.Error.pas',
  Model.Produtos in 'Model\Model.Produtos.pas',
  Service.Produtos in 'Service\Service.Produtos.pas',
  Model in 'Model\Model.pas',
  Controller.Produtos in 'Controller\Controller.Produtos.pas',
  Controller.Usuario in 'Controller\Controller.Usuario.pas',
  Model.Usuario in 'Model\Model.Usuario.pas',
  Service.Usuario in 'Service\Service.Usuario.pas',
  Errors.Api in 'Errors\Errors.Api.pas',
  Utils in 'Utils.pas',
  Model.Notas in 'Model\Model.Notas.pas',
  Helper.TObject in 'Helper.TObject.pas',
  Controller.Notas in 'Controller\Controller.Notas.pas',
  Service.Notas in 'Service\Service.Notas.pas',
  Model.Movimentacao in 'Model\Model.Movimentacao.pas',
  Service.Movimentacao in 'Service\Service.Movimentacao.pas',
  Controller.Movimentacao in 'Controller\Controller.Movimentacao.pas';

var
  App: THorse;
begin
  App := THorse.Create();

  try
    App
      .Use(CORS)
      .Use(Jhonson)
      .Use(HorseSwagger)
      .Use(HorseBasicAuthentication(TControllerUsuario.LogIn));

    App.Use(
    procedure (Req: THorseRequest; Res: THorseResponse;Next: TNextProc)
    begin
      try
        Next();
      except
        on E:Exception do
          GlobalErrorHandler(Req,Res,E);
      end;
    end);

    RegisterRoutes(App);

    App.Listen(Enviroment.Variables.PORT,
    procedure
    begin
      Writeln(Format('Servidor iniciado com sucesso na porta %d', [Enviroment.Variables.PORT]));
    end);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.

