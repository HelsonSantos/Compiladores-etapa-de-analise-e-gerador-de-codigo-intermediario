program exemplo;

var
x, y : integer;
z : real;

procedure teste;
var
a : integer;
begin
a := 10;
if a > 5 then
x := a
else
x := 0
end;

begin
x := 1;
y := 2;
z := 3.5;

teste();

while x < y do
begin
x := x + 1
end
end.

