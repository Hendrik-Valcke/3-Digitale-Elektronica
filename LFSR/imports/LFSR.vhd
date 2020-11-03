library IEEE;
use IEEE.std_logic_1164.all;
use work.LFSRPackage.all;

entity LFSR is
  generic (
    -- the g_Taps array size should match the size of the LFSR
    g_Taps : t_TapsArr := (6 to 7 => true, others => false));
  port (
    Clk       : in std_logic;
    ResetN    : in std_logic;
    LFSR      : out std_logic_vector(1 to g_Taps'high));
end LFSR;

architecture RTL of LFSR is

begin

end RTL;
