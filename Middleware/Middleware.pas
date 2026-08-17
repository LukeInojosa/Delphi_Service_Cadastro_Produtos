unit Middleware;

interface uses
  Horse;

type TParseToJson<T> = class
  class procedure Body(Req: THorseRequest;Res: THorseResponse; Next: TNextProc);
end;

implementation

end.
