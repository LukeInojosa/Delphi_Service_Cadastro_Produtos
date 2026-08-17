unit FieldHelper;

interface

uses
  Data.DB;

type
  TFieldHelper = class helper for TField
  public
    function isDateTime(): Boolean;
    function Time(): Boolean;
    function isNumeric(): Boolean;
    function isString(): Boolean;
    function isDate(): Boolean;
    function isChar(size: integer): Boolean;
  end;

implementation

uses
  System.SysUtils,
  System.Rtti;

{ TFieldHelper }

function TFieldHelper.isChar(size: integer): Boolean;
begin
  //writeln(TRttiEnumerationType.GetName<TFieldType>(Self.DataType));
  Result := ((Self.DataType = ftString)) and ((Self.DataSize) = (size + 1));
end;

function TFieldHelper.isDate(): Boolean;
begin
  Result := ((Self.DataType = ftDate) or (Self.DataType = ftTimeStamp))
end;

function TFieldHelper.isDateTime(): Boolean;
begin
  Result := ((Self.DataType = ftDateTime))
end;

function TFieldHelper.Time(): Boolean;
begin
  Result := ((Self.DataType = ftTime))
end;

function TFieldHelper.isNumeric(): Boolean;
begin
  Result := ((Self.DataType = ftInteger) or (Self.DataType = ftSmallint) or
    (Self.DataType = ftWord) or (Self.DataType = ftFloat) or
    (Self.DataType = ftCurrency) or (Self.DataType = ftBytes) or
    (Self.DataType = ftAutoInc) or (Self.DataType = ftLargeint));
end;

function TFieldHelper.isString(): Boolean;
begin
  Result := ((Self.DataType = ftString))
end;

end.
