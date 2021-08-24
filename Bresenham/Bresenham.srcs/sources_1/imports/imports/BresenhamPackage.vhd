library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package BresenhamPackage is
  -- definieer hier de functie AbsVal om de absolute waarde te
  -- berekenen van een integer
  function AbsVal(a: integer) return integer;
  --function Log2Ceil(a: integer) return integer;
end BresenhamPackage;

package body BresenhamPackage is
function AbsVal(a: integer) return integer is
begin
    if a >= 0 then
        return a;
    else
        return -a;
    end if;
end AbsVal;

--function Log2Ceil(a: integer) return integer is
--    variable Power : integer := 0;
--    variable PowerOf2 : integer := 1;
--  begin
--    PowerLoop: while PowerOf2 < a loop
--      Power     := Power + 1;
--      PowerOf2  := PowerOf2 * 2;
--    end loop PowerLoop;
--    return Power;
--  end Log2Ceil;
end BresenhamPackage;
