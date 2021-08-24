
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.VGAPackage.all;
--deze entity ontvangt het lfsr getal in d vorm van een  x, y getal (eerste 10, laatste 9 bits)
--vormt deze om in adres en schrijft op dat adres de waarde 100 (rood)


entity WriteVideoMemory is
    port ( Clk          : in std_logic;--25MHz
           ResetN       : in std_logic;--actief laag
           X            : in unsigned (c_NumXBits-1 downto 0);--eerste 10 bits van lfsr
           --X            : in unsigned (9 downto 0);--eerste 10 bits van lfsr
           Y            : in unsigned (c_NumYBits-1 downto 0);--laatste 9 bits van lfsr
           --Y            : in unsigned (8 downto 0);--laatste 9 bits van lfsr
           Addr         : out std_logic_vector(c_VidMemAddrWidth - 1 downto 0);--write address
           WriteData    : out std_logic_vector(2 downto 0);--rgb uit
           ReadData     : in std_logic_vector(2 downto 0);--rgb in = 100 (rood) in opgave 3
           WEn          : out std_logic);--write enable
end WriteVideoMemory;

architecture Behavioral of WriteVideoMemory is
signal location: integer;

begin
schrijfGeheugen: process(Clk,ResetN)
    begin
        if ResetN = '1' then--actief laag dus geen reset
            if rising_edge(Clk) then
                --zoek adres voor geheugen a.d.h.v X,Y bv als coordinaat=(12,200) dan is address=200*640+12
                location<=  to_integer(Y*640+X);
                Addr <= std_logic_vector(to_unsigned(location,19));--19 elementen vector, adres = (Y coordinaat * 640) + X horizontale pixels
                WEn <= '1';
                WriteDatA <= ReadData;
            end if;
        else --reset ingeduwd
            Addr<= std_logic_vector(to_unsigned(0, (c_VidMemAddrWidth )));--00000...00
            WEn <='0';
            WriteDatA <= ReadData;
        end if;
    end process;
end Behavioral;
