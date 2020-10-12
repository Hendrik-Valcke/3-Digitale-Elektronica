library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;
use work.VGAPackage.all;
use work.Components.all;

entity VGAInterface is
  port ( Clk100MHz : in std_logic;
         ResetN    : in std_logic;
         HSync     : out std_logic;
         VSync     : out std_logic;
         Dips      : in  std_logic_vector(15 downto 0);
         Leds      : out std_logic_vector(15 downto 0);
         Red       : out std_logic_vector(3 downto 0);
         Green     : out std_logic_vector(3 downto 0);
         Blue      : out std_logic_vector(3 downto 0));
end VGAInterface;

architecture RTL of VGAInterface is

begin

end RTL;
