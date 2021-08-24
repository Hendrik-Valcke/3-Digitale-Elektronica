library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use work.LFSRPackage.all;
use work.Components.all;
use work.BresenhamPackage.all;
use work.VGAPackage.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity TB_bresenham is
end TB_bresenham;

architecture Behavioral of TB_bresenham is

  --constant c_Size : integer := 16;
  --constant c_Taps : t_TapsArr(1 to c_Size) := (4 => true, 13 => true, 15 to 16 => true, others => false);
  --constant c_Size : integer := 19;
  --constant c_Taps : t_TapsArr(1 to c_Size) := (14 => true, 17 to 19 => true, others => false);
  --constant c_Size : integer := 7;
  --constant c_Taps : t_TapsArr(1 to c_Size) := (6 to 7 => true, others => false);

  signal Clk      : std_logic := '0';
  signal ResetN   : std_logic := '1';
  signal X0       : unsigned (Log2Ceil(c_HRes)-1 downto 0):=to_unsigned(0,Log2Ceil(c_HRes));--deze waarden invullen
  signal X1       : unsigned (Log2Ceil(c_HRes)-1 downto 0):=to_unsigned(5,Log2Ceil(c_HRes));
  signal Y0       : unsigned (Log2Ceil(c_VRes)-1 downto 0):=to_unsigned(0,Log2Ceil(c_VRes));
  signal Y1       : unsigned (Log2Ceil(c_VRes)-1 downto 0):=to_unsigned(5,Log2Ceil(c_VRes));
  signal PlotX       : unsigned (Log2Ceil(c_HRes)-1 downto 0);
  signal Ploty       : unsigned (Log2Ceil(c_VRes)-1 downto 0);
  signal Start    : std_logic:='1';
  signal Plotting      : std_logic;
  --signal LFSRReg  : std_logic_vector(1 to c_Size);
  
   component Bresenham
        Port (
          Clk : in STD_LOGIC;
          X0       : in  unsigned (Log2Ceil(c_HRes)-1 downto 0);
          Y0       : in  unsigned (Log2Ceil(c_VRes)-1 downto 0);
          X1       : in  unsigned (Log2Ceil(c_HRes)-1 downto 0);
          Y1       : in  unsigned (Log2Ceil(c_VRes)-1 downto 0);
          --Xout       : out  unsigned (Log2Ceil(c_HRes)-1 downto 0);
          --Yout       : out  unsigned (Log2Ceil(c_VRes)-1 downto 0);
          Start    : in  std_logic;
          ResetN    : in  std_logic;
          PlotX    : out unsigned (Log2Ceil(c_HRes)-1 downto 0);
          PlotY    : out unsigned (Log2Ceil(c_VRes)-1 downto 0);
          Plotting : out STD_LOGIC);
    end component;
    

begin

  Clk    <= not Clk after 5 ns;          -- 100 MHz => 10 ns period
  --ResetN <= '0', '1' after 30 ns;
  Start<= '0' after 20 ns;
  --Start<='0' after 20 ns;
  bresenh:Bresenham
      port map (
      --links comp, rechts topmodule
       Clk      => Clk,
       ResetN   => ResetN,
       X0=>X0,
       X1=>X1,
       Y0=>Y0,
       Y1=>Y1,
       Start=> Start,
       PlotX => PlotX,
       Ploty => Ploty,
       Plotting => Plotting);
 --      LFSR     => LFSRReg
 --      );


--  p_Main: process(Clk)
--    file TestVector : text open read_mode is "LFSRVectorSize7.txt";
--    --file TestVector : text open read_mode is "LFSRVectorSize19.txt";
--    --file TestVector : text open read_mode is "LFSRVectorSize16.txt";
--    variable Row    : line;
--    variable Val    : std_logic_vector(1 to c_Size);
--    -- These string variables are needed because the assert statement cannot
--    -- "print" std_logic_vectors, so we convert them to strings first.
--    variable LFSRString : string(1 to c_Size);
--    variable ValString : string(1 to c_Size);
--  begin
--    if rising_edge(Clk) then
--      if ResetN = '1' then
--        if(not endfile(TestVector)) then
--          readline(TestVector,Row);
--          read(Row,Val);
--          -- conversion to strings
--          BuildLFSRString: for A in 1 to c_Size loop
--            if LFSRReg(A) = '0' then
--              LFSRString(A) := '0';
--            else
--              LFSRString(A) := '1';
--            end if;
--          end loop BuildLFSRString;
--          BuildValString: for A in 1 to c_Size loop
--            if Val(A) = '0' then
--              ValString(A) := '0';
--            else
--              ValString(A) := '1';
--            end if;
--          end loop BuildValString;
--          assert Val = LFSRReg report "Error: value " & LFSRString & " does not match expected value " & ValString severity warning;
--        else
--          assert false report "End of simulation. Not an error." severity failure;
--        end if;
--      end if;
--    end if;
--  end process p_Main;
  
--  LFSR0: LFSR
--    generic map (
--      g_Taps   => c_Taps
--      )
--    port map (
--      Clk      => Clk,
--      ResetN   => ResetN,
--      LFSR     => LFSRReg
--      );

end Behavioral;
