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
--constants (zitten in de package)
--signals
signal PixelClk: std_logic := '0';--pixelclock signaal vd clocking wizard (ong. 25MHz)
signal address: std_logic_vector(18 downto 0); --adres: 19 bits
signal color: std_logic_vector(2 downto 0);--3bits voor: r g b
signal HCount: integer range 0 to 800;
signal VCount: integer range 0 to 525;
signal VideoActive: boolean;
--components
component VGATiming
    Port(
    --in
    PixelClk    : in std_logic;
    ResetN      : in std_logic; -- active low, synchronous
    --out
    HSync       : out std_logic;
    VSync       : out std_logic;
    VideoActive : out boolean;
    HCount      : out integer range 0 to c_HTotal-1;
    VCount      : out integer range 0 to c_VTotal-1);
end component;

component ClockingWizard
    Port(
    --in
    SysClk100MHz: in std_logic;
    --out
    --Clk100MHz: out std_logic;
    PixelClk: out std_logic);
end component;

component VideoMemory
    Port(
    --port a wordt compleet niet gebruikt
    clka    : in  std_logic;
    wea     : in std_logic_vector(0 downto 0);--write enable a
    addra   : in std_logic_vector(18 downto 0);--adres
    douta   : out std_logic_vector(2 downto 0);--data out
    dina    : in std_logic_vector(2 downto 0);--data in
    --port b
    clkb    : in std_logic;
    web     : in std_logic_vector(0 downto 0);
    addrb   : in std_logic_vector(18 downto 0);
    doutb   : out std_logic_vector(2 downto 0);
    dinb    : in std_logic_vector(2 downto 0));
end component;
begin
--portmaps
    clockmap: ClockingWizard
    Port map( --links component, rechts top design
    --in
    SysClk100MHz => Clk100MHz,
    --out
    --Clk100MHz => , ?? staat op afbeelding
    PixelClk => PixelClk);
        
    verticalTimings: VGATiming
    Port map(
    --in
    PixelClk =>PixelClk,
    ResetN =>ResetN,
    --out
    HSync =>HSync,
    VSync=>VSync,
    VideoActive=>VideoActive,
    HCount =>HCount,
    VCount =>VCount
    );
    
    vidMemory: VideoMemory
    port map (
    clka => '0',
    wea => "0",
    addra => "0000000000000000000",
    dina => "000",
    clkb => PixelClk,--enkel de klok, adres en data output worden gebruikt, voor de rest wordt 0 ingevuld
    web => "0",
    addrb => address,
    doutb => color,
    dinb => "000"
    );
    
--processen
    geheugenadres : process(HCount,VCount)--zoek adres voor geheugen a.d.h.v H/VCount
    begin
        address <= std_logic_vector(to_unsigned(((VCount * 640) +HCount),19));--19 elementen vector, adres = (#aantal lijnen tot nu toe * 640) + aantal pixels van huidige lijn
    end process;
    
    geheugenlezen : process(VideoActive, color)-- bit 2,1,0 = rgb of volgorde andersom?
    begin
        if(VideoActive)--dus zoek rgb waarde voor adres
        then
            if(color(2) = '1')
            then
                Red <= "1111";
            end if;            
            if(color(1) = '1')
            then
                Green <= "1111";
            end if;            
            if(color(0) = '1')
            then
                Blue <= "1111";
            end if;
        else
            --als tussendoortje :)
            Red <= "0000";
            Green <= "0000";
            Blue <= "0000";                
        end if;
    end process;

end RTL;
