library IEEE;
use IEEE.std_logic_1164.all;
use work.LFSRPackage.all;
use IEEE.numeric_std.all;
--elke klokslag schuiven de waardes op naar rechts (richting LSB)
--'1'ste bit (MSB) krijgt de waarde van de Xor som (default xor(bit6,bit7)), de andere bits krijgen de oude waarde van hun linkerbuur

entity LFSR is
  generic (
    -- the g_Taps array size should match the size of the LFSR
    g_Taps : t_TapsArr := (6 to 7 => true, others => false));
    --default size 7: =0000011, wordt overschreven in generic map
    --g_Taps : t_TapsArr := (14=> true ,17 to 19 => true, others => false));
  port (
    Clk       : in std_logic;
    ResetN    : in std_logic;
    LFSR      : out std_logic_vector(1 to g_Taps'high)); --default 1 to 7 = 7 bits
end LFSR;

architecture RTL of LFSR is
constant lfsrSize: integer:= g_Taps'high;--grootte van de lfsr 7, 16 of 19
constant seed: std_logic_vector(1 to lfsrSize ) := (lfsrSize=>'1',others => '0');
signal XorSum: std_logic_vector(1 to lfsrsize);--default 1 to 7
--signal output: std_logic_vector(1 to lfsrSize ) := (lfsrSize =>'1',others => '0');--seed 0000001 (MSB staat links en is de '1'ste bit)
signal output: std_logic_vector(1 to lfsrSize ) := seed;--seed 0000001 (MSB staat links en is de '1'ste bit)
begin

    startShift:process(clk,ResetN)
    begin
        if ResetN = '1' then--actief laag
            if rising_edge(clk) then 
                output(1)<=XorSum(1);--de hoogste bit krijgt de xor waarde              
                for I in 2 to lfsrSize --voor de 2de bit tot de laatste
                loop
                    output(I) <= output(I-1);--waardes schuiven naar rechts (richting LSB =default bit 7)
                end loop;                                
            end if;
        else --reset = 0 want actief laag
            --output<=std_logic_vector(to_unsigned(1,lfsrSize));--bij reset wordt de output 0000001 (=seed)
            output<=seed;
        end if;
    end process;
        
    GenFeedback: for I in (lfsrSize-1)downto 1 generate --vertrekt op voorlaatste bit (default 6) en bewegen naar links over de taps (laatste/7de bit krijgt al waarde)
        XorSum(lfsrSize)<= output(lfsrSize);--de meeste rechtse bit vd XorSum krijgt waarde van de meest rechtse bit van het lfsr getal (default bit 7)
        GenXOR: if g_Taps(I) = true generate -- alle volgende linkse bits krijgen waarde van xor met rechtse xorsom-buur indien er een tap is        
            XorSum(I)<= output(I) xor XorSum(I+1);--bv 6de bit in g_taps = 1 dus XorSum(6)=output(6) xor XorSum(7)
        end generate GenXOR;
        GenNoXOR: 
        if g_Taps(I) = false generate--geen taps, gewoon waarde doorgeven zonder xor 
            XorSum(I)<= XorSum(I+1);
        end generate GenNoXOR;
    end generate GenFeedback;    
        
    endShift:process(output)
    begin
        LFSR <= output;--output signaal is nodig omdat er geen waarden uit een uitgang gelezen kan worden
    end process;

end RTL;