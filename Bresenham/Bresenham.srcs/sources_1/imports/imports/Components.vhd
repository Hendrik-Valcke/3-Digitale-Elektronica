library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.VGAPackage.all;

package Components is

  component Bresenham is
    port (Clk      : in  std_logic;
          ResetN   : in  std_logic;
          X0       : in  unsigned (Log2Ceil(c_HRes)-1 downto 0);
          Y0       : in  unsigned (Log2Ceil(c_VRes)-1 downto 0);
          X1       : in  unsigned (Log2Ceil(c_HRes)-1 downto 0);
          Y1       : in  unsigned (Log2Ceil(c_VRes)-1 downto 0);
          Start    : in  std_logic;
          PlotX    : out unsigned (Log2Ceil(c_HRes)-1 downto 0);
          PlotY    : out unsigned (Log2Ceil(c_VRes)-1 downto 0);
          Plotting : out std_logic);
  end component;

end Components;

