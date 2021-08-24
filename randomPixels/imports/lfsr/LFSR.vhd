library IEEE;
use IEEE.std_logic_1164.all;
use work.LFSRPackage.all;
use IEEE.numeric_std.all;
--0de bit krijgt de waarde van de Xor som, de andere bits krijgen de oude waarde van hun onderbuur

entity LFSR is
  generic (
    -- the g_Taps array size should match the size of the LFSR
    g_Taps : t_TapsArr := (6 to 7 => true, others => false));--default size 7, wordt in TB overschreven
    
  port (
    Clk       : in std_logic;
    ResetN    : in std_logic;
    LFSR      : out std_logic_vector(1 to g_Taps'high));
end LFSR;

architecture RTL of LFSR is
constant lfsrSize: integer:= g_Taps'high;--grootte van de lfsr 7, 16 of 19
signal XorSum: std_logic_vector(0 to lfsrsize-1);--van 0-15 = 1-16
signal output: std_logic_vector(0 to lfsrSize-1 ) := (0 =>'1',others => '0');--seed 1000...00 (MSB staat rechts)
begin

    startShift:process(clk,ResetN)
    begin
        if ResetN = '0' then
            if rising_edge(clk) then 
                output(0)<=XorSum(0);--de 0de bit krijgt de xor waarde              
                for I in 1 to lfsrSize-1 --voor de bit 1 tot de laatste
                loop
                    output(I) <= output(I-1);--waardes schuiven naar rechts (richting MSB)
                end loop;                                
            end if;
        else --reset = 1
            output<=std_logic_vector(to_unsigned(1,lfsrSize));--bij reset wordt de output 000...001
        end if;
    end process;
        
    GenFeedback: for I in (lfsrSize-2)downto 0 generate--van MSB-1 tot 0
        XorSum(lfsrSize-1)<= output(lfsrSize-1);--MSB van XorSum krijgt waarde van de MSB van het lfsr getal
        GenXOR: if g_Taps(I+1) = true generate --er is dus een tap         
            XorSum(I)<= output(I) xor XorSum(I-1);
        end generate GenXOR;
        GenNoXOR: 
        if g_Taps(I+1) = false generate--geen taps gewoon waarde doorgeven
            XorSum(I)<= XorSum(I+1);
        end generate GenNoXOR;
    end generate GenFeedback;    
        
    endShift:process(output)
    begin
        LFSR <= output;
    end process;

end RTL;
