--merendeel overgenomen van "schermHorizontaal" van project "PongScherm" van 1-Digitale Elektronica 2019-2020

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.VGAPackage.all;

entity VGAHorizontalTiming is
    Port (
        --in
        PixelClk: in std_logic;
        --out
        HSync : out std_logic;        
        HCount: out integer range 0 to 800;
        hVideoActive: out std_logic --zelfde naam als in VGATiming voor de gemakkelijkheid
        );
end VGAHorizontalTiming;

architecture Behavioral of VGAHorizontalTiming is
--signalen
signal pixelCounter: integer range 0 to 800;

--constanten (vervangen door die van VGAPackage)
--timings: lijn (komt overeen met 1 tick van de 25MHz klok) 
--constant hBackPorchTijd: integer := 48; c_HBP
--constant hFrontPorchTijd: integer := 16; c_HFP
--constant hSyncTijd: integer := 96; c_HSync
--constant hVisTijd: integer := 640; c_HRes
--constant hTotaalTijd: integer := 800; c_HTotal

begin
    telKlok: process(PixelClk)
    begin
        if rising_edge(PixelClk) then
            if pixelCounter < c_HTotal-1 then
                pixelCounter <= pixelCounter +1;
            else
                pixelCounter <= 0;                
            end if;            
        end if;
    end process;
    
    schermLijnGenerator: process(pixelCounter)
    begin
        --standaardwaarden (regels v combinatorisch process)
        hVideoActive <= '0';
        hSync <= '1';       
        HCount <= pixelCounter;       
        
        if pixelCounter <= c_HRes-1 then
            hVideoActive <= '1';
            hSync <= '1';
        elsif pixelCounter > c_HRes-1 and pixelCounter <= (c_HRes + c_HFP-1) then
            hVideoActive <= '0';
            hSync <= '1';
        elsif pixelCounter >(c_HRes + c_HFP-1) and pixelCounter <= (c_HRes + c_HFP + c_HSync-1) then
            hVideoActive <= '0';
            hSync <= '0';
        elsif pixelCounter >(c_HRes + c_HFP + c_HSync-1) and pixelCounter <= (c_HRes + c_HFP + c_HSync + c_HBP-1) then
            hVideoActive <= '0';
            hSync <= '1';
        end if;
    end process;  
    
end Behavioral;
