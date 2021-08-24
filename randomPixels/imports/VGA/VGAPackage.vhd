library IEEE;
use IEEE.std_logic_1164.all;

package VGAPackage is
  function Log2Ceil(a: integer) return integer;

  -- vga constants for 640x480@60Hz
  -- horizontal (number of PixelClk periods)
  constant c_HTotal     : integer := 800;
  constant c_HRes       : integer := 640;
  constant c_HFP        : integer := 16;
  constant c_HSync      : integer := 96;
  constant c_HBP        : integer := 48;
  constant c_HPol       : std_logic := '0';
  -- vertical (number of horizontal lines)
  constant c_VTotal     : integer := 525;
  constant c_VRes       : integer := 480;
  constant c_VFP        : integer := 10;
  constant c_VSync      : integer := 2;
  constant c_VBP        : integer := 33;
  constant c_VPol       : std_logic := '0';

  constant c_NumXBits   : integer := Log2Ceil(c_HRes);
  constant c_NumYBits   : integer := Log2Ceil(c_VRes);
  constant c_VidMemAddrWidth : integer := Log2Ceil(c_HRes*c_VRes);

end VGAPackage;

package body VGAPackage is
  function Log2Ceil(a: integer) return integer is
    variable Power : integer := 0;
    variable PowerOf2 : integer := 1;
  begin
    PowerLoop: while PowerOf2 < a loop
      Power     := Power + 1;
      PowerOf2  := PowerOf2 * 2;
    end loop PowerLoop;
    return Power;
  end Log2Ceil;
end VGAPackage;
