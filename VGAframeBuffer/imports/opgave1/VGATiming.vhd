library IEEE;
use IEEE.std_logic_1164.ALL;
use work.VGAPackage.all;

entity VGATiming is
  port ( PixelClk    : in std_logic;
         ResetN      : in std_logic; -- active low, synchronous
         HSync       : out std_logic;
         VSync       : out std_logic;
         VideoActive : out boolean;
         HCount      : out integer range 0 to c_HTotal-1;
         VCount      : out integer range 0 to c_VTotal-1);
end VGATiming;

architecture RTL of VGATiming is

begin

  -- assuming the following counting scheme (neg polarity):
  -- +     +------------------+     +...
  -- |     |                  |     |
  -- |     |                  |     |
  -- +-----+                  +-----+
  -- |                        |
  -- 0                      Total
  -- |<--->|<-->|<------>|<-->|<--->|...
  --  Sync   BP   Active   FP  Sync

end RTL;
