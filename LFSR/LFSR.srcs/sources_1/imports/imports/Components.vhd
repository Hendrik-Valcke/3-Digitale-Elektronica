library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.LFSRPackage.all;

package Components is

  component LFSR
    generic (
      -- the g_Taps array size should match the size of the LFSR
      g_Taps : t_TapsArr := (6 to 7 => true, others => false));
    port (
      Clk       : in std_logic;
      ResetN    : in std_logic;
      LFSR      : out std_logic_vector(1 to g_Taps'high));
  end component;

end Components;

