unit Errors.Api;

interface uses
  System.SysUtils,
  Horse.Commons;

type EHelperAPI = class helper for Exception
  function Status: Integer;
end;

type EValidation = class(Exception)
  function Status: Integer;
end;

type ENotFound = class(Exception)
  function Status: Integer;
end;


implementation
{ EValidation }

function EValidation.Status: Integer;
begin
  Result := THttpStatus.BadRequest.ToInteger;
end;

{ EHelperAPI }

function EHelperAPI.Status: Integer;
begin
  Result :=  0;
end;

{ ENotFound }

function ENotFound.Status: Integer;
begin
  Result := THttpStatus.NotFound.ToInteger;
end;

end.
