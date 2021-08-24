--merendeel overgenomen van "schermVerticaal" van project "PongScherm" van 1-Digitale Elektronica 2019-2020
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
--signalen
signal hVideoActive: std_logic;
signal vVideoActive: std_logic;
signal HCounter: integer range 0 to 800;
signal VCounter: integer range 0 to 525;

--de constanten zijn vervangen door die van de VGAPackage
--timings: frame (komt overeen met 1 lijn = 800 ticks aan 25MHz)
--constant vBackPorchTijd: integer := 33; c_VBP
--constant vFrontPorchTijd: integer := 10; c_VFP
--constant vSyncTijd: integer := 2; c_VSync
--constant vVisTijd: integer := 480; c_VRes
--constant vTotaalTijd: integer := 525; c_VTotal

--components
    component VGAHorizontalTiming
    Port(
        --in
        PixelClk : in std_logic;
        --out   
        HSync: out std_logic;
        hVideoActive: out std_logic;
        HCount: out integer range 0 to 800        
        );
    end component;
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
    horizontalTimings: VGAHorizontalTiming
    Port map(            
            --in
            PixelClk => PixelClk,
            --out                 
            hSync => hSync, 
            hVideoActive => hVideoActive,
            HCount=> HCounter          
            );
    
    telKlok: process(PixelClk)
    begin
        if rising_edge(PixelClk) then
            if HCounter =0 then
                if VCounter < c_VTotal-1 then
                    VCounter <= VCounter +1;
                else
                    VCounter <= 0;
                end if;
            end if;
        end if;
    end process;
            
    SchermFrameGenerator: process(VCounter)
    begin
        --standaardwaarden (combinatorisch process)
        vSync <= '1';
        vVideoActive <= '0';
        
        if VCounter <= c_VRes-1 then
            vVideoActive <= '1';
            vSync <= '1';
        elsif VCounter > c_VRes-1 and VCounter <= (c_VRes + c_VFP-1) then
            vVideoActive <= '0';
            vSync <= '1';
        elsif VCounter > (c_VRes + c_VFP-1) and VCounter <=(c_VRes + c_VFP + c_VSync-1) then
            vVideoActive <= '0';
            vSync <= '0';
        elsif VCounter > (c_VRes + c_VFP + c_VSync-1) and VCounter <= (c_VRes + c_VFP + c_VSync + c_VBP-1)then
            vVideoActive <= '0';
            vSync <= '1';
        end if;
    end process;
    
    display: process(hVideoActive,vVideoActive)
    begin
        if hVideoActive ='1' and vVideoActive ='1'   then
            VideoActive <= true;
        else
            VideoActive <= false;
        end if;
    end process;
    
    locaties: process(HCounter, VCounter)
    begin
        HCount<= HCounter;
        VCount <= VCounter;
    end process;
end RTL;
