unit Router;
interface uses
    Horse;

procedure RegisterRoutes(var App: THorse);

implementation uses
  Controller.Almoxarifado,
  Controller.Produtos,
  Controller.Usuario,
  Controller.Notas,
  Controller.Movimentacao,
  Controller.Estoque;

procedure RegisterRoutes(var App: THorse);
begin
  APP.Group
    .Prefix('/almoxarifado')
    .Put('/:id', TControllerAlmoxarifado.Put)
    .Get('/:id', TControllerAlmoxarifado.Get)
    .Get('/', TControllerAlmoxarifado.Get)
    .Post('/', TControllerAlmoxarifado.Post)
    .Delete('/:id', TControllerAlmoxarifado.Delete);

  APP.Group
    .Prefix('/produtos')
    .Post('/', TControllerProdutos.Post)
    .Get('/:id', TControllerProdutos.Get)
    .Get('/', TControllerProdutos.Get)
    .Delete('/:id', TControllerProdutos.Delete)
    .Put('/:id', TControllerProdutos.Put);

  APP.Group
    .Prefix('/usuario')
    .Get('/:id', TcontrollerUsuario.Get)
    .Get('/', TcontrollerUsuario.Get)
    .Post('/', TControllerUsuario.Cadastro)
    .Delete('/', TControllerUsuario.Delete);

  APP.Group
    .Prefix('/notas')
    .Post('/', TControllerNotas.Post)
    .Get('/:id', TControllerNotas.Get)
    .Get('/', TControllerNotas.Get)
    .Delete('/:id', TControllerNotas.Delete)
    .Put('/:id', TControllerNotas.Put);

  APP.Group
    .Prefix('/mov')
    .Post('/', TControllerMovimentacao.Post)
    .Get('/', TControllerMovimentacao.Get)
    .Get('/:id', TControllerMovimentacao.Get)
    .Get('/:num_pagina/:qtd_por_pagina', TControllerMovimentacao.Get)
    .Delete('/:id', TControllerMovimentacao.Delete)
    .Put('/:id', TControllerMovimentacao.Put);

  APP.Group
    .Prefix('/estoque')
    .Get('/', TControllerEstoque.Get);

end;

end.
