library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;
use work.VGAPackage.all;
use work.Components.all;
use work.LFSRPackage.all;

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
--lfsr
constant c_Taps : t_TapsArr := (14 => true, 17 to 19 => true, others => false);
signal random: std_logic_vector(1 to 19);
--scherm
signal PixelClk: std_logic := '0';--pixelclock signaal vd clocking wizard (ong. 25MHz)
signal addressB: std_logic_vector(18 downto 0); --adres: 19 bits (waarvan data gelezen en gedisplayt wordt
signal color: std_logic_vector(2 downto 0);--3bits voor: r g b
signal HCount: integer range 0 to 800;
signal VCount: integer range 0 to 525;
signal VideoActive: boolean;
--writeMemory
signal WriteData: std_logic_vector(2 downto 0); --data die in de memory moet worden gestoken
signal ReadData: std_logic_vector(2 downto 0):="100"; -- =rood
--signal X: unsigned (c_NumXBits-1 downto 0);--:=unsigned(random(1 to 10));-- de eerste 10 bits van de lfsr vormden de x coordinaat
signal X: unsigned (9 downto 0);--:=unsigned(random(1 to 10));-- de eerste 10 bits van de lfsr vormden de x coordinaat
signal Y: unsigned (8 downto 0);--:=unsigned(random(1 to 10));-- de eerste 10 bits van de lfsr vormden de x coordinaat

--signal Y: unsigned (1 downto 0);--:=unsigned(random(11 to 9));-- de laatste 9 bits van de lfsr vormden de y coordinaat
signal WriteMemoryEnable: std_logic_vector(0 downto 0);--WEn is om de een of andere reden een std_logic_vecotr(0 downto 0)
signal WriteAddress: std_logic_vector(18 downto 0); --adres: 19 bits

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
    Clk100MHz: out std_logic;
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

component LFSR
    generic (
      -- the g_Taps array size should match the size of the LFSR
      g_Taps : t_TapsArr := (6 to 7 => true, others => false));
      --wordt overgeschreven bij generic map
    port (
      Clk       : in std_logic;
      ResetN    : in std_logic;
      LFSR      : out std_logic_vector(1 to g_Taps'high));
  end component;
  
component WriteVideoMemory is
  port ( Clk          : in std_logic;
         ResetN       : in std_logic;
         X            : in unsigned (c_NumXBits-1 downto 0);
         Y            : in unsigned (c_NumYBits-1 downto 0);
         Addr         : out std_logic_vector(c_VidMemAddrWidth - 1 downto 0);
         WriteData    : out std_logic_vector(2 downto 0);
         ReadData     : in std_logic_vector(2 downto 0);
         WEn          : out std_logic);
end component;
  
begin
X<=unsigned(random(1 to 10));
Y<=unsigned(random(11 to 19));
--port/generic maps
    clockmap: ClockingWizard
    Port map( --links component, rechts top design
    --in
    SysClk100MHz => Clk100MHz,
    --out
    --Clk100MHz => , ?? staat op afbeelding in opgave
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
    --langs de A kant wordt eventueel overschreven
    clka => Clk100MHz,--clk a 
    wea => WriteMemoryEnable,--write  enable a
    addra => writeAddress,-- adres a
    dina => WriteData,--data in a
    
    --langs de B kant wordt alleen gelezen, data in en write enable zijn dus nul
    clkb => PixelClk,--25MHz
    web => "0",
    addrb => addressB,
    doutb => color,
    dinb => "000"
    );
    
    writeMemory: WriteVideoMemory
    port map(
    Clk=>Clk100MHz,--in
    ResetN=>ResetN,--in: actief laag
    X=>X,--in
    Y=>Y,--in
    Addr=>WriteAddress,--out
    WriteData=>WriteData,--out
    ReadData=>ReadData,--in
    WEn=>WriteMemoryEnable(0)--WEn is om de een of andere reden een std_logic_vecotr(0 downto 0)
    );
    
    shiftRegister : LFSR
    generic map (
    g_Taps   => c_Taps
    )
    port map(
    Clk=>Clk100MHz,--100MHz
    ResetN=>ResetN,--actief laag
    LFSR=>random
    );

--processen
    geheugenadres : process(HCount,VCount)--zoek adres voor geheugen a.d.h.v H/VCount
    begin
        addressB <= std_logic_vector(to_unsigned(((VCount * 640) +HCount),19));--19 elementen vector, adres = (#aantal lijnen tot nu toe * 640) + aantal pixels van huidige lijn
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
            --wanneer videoActive=0, geen rgb waarden displayen
            Red <= "0000";
            Green <= "0000";
            Blue <= "0000";                
        end if;
    end process;

end RTL;
