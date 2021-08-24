library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.Components.all;

entity TB_VGASync is
end TB_VGASync;

architecture Sim of TB_VGASync is

  -- timings to check
  constant c_HFP: time := 0.63555114200596 us;
  constant c_HBP: time := 1.9066534260179 us;
  constant c_HPW: time := 3.8133068520357 us;
  constant c_HTOT: time := 31.777557100298 us;
  constant c_VFP: time := 0.31777557100298 ms;
  constant c_VBP: time := 1.0486593843098 ms;
  constant c_VPW: time := 0.063555114200596 ms;
  constant c_VTOT: time := 16.683217477656 ms;

  -- toegestane afwijking
  constant c_upperMargin: real := 1.01; -- +1%
  constant c_lowerMargin: real := 0.99; -- -1%

  constant c_NumAutoChecks : integer := 8;
  type t_Error is array(1 to c_NumAutoChecks) of boolean;
  signal AutoCheckError : t_Error := (others => false);

  constant c_FirstLeds    : std_logic_vector(15 downto 0) := (15 => '1', others => '0');
  signal Clk      : std_logic := '0';
  signal HSync    : std_logic;
  signal VSync    : std_logic;
  signal Red      : std_logic_vector (3 downto 0);
  signal Green    : std_logic_vector (3 downto 0);
  signal Blue     : std_logic_vector (3 downto 0);
  signal PrevRed  : std_logic_vector (3 downto 0);
  signal PrevGreen: std_logic_vector (3 downto 0);
  signal PrevBlue : std_logic_vector (3 downto 0);
  signal tHighVS  :  time;
  signal tLowVS   : time;
  signal tHighHS  :  time;
  signal tLowHS   : time;
  signal NoVSyncYet: boolean := true;

  signal ResetN   : std_logic;
  signal Dips     : std_logic_vector(15 downto 0);
  
begin
  
  Clk <= not Clk after 5 ns;
  ResetN <= '0', '1' after 100 ns;
  
  TopLevel: VGAInterface port map (
    Clk100MHz   => Clk,
    ResetN      => ResetN,
    HSync       => Hsync,
    VSync       => Vsync,
    Dips        => Dips,
    Leds        => open,
    Red         => Red,
    Green       => Green,
    Blue        => Blue);

  p_Timeout: process
  begin
    wait for 40 ms;
    assert false report "AUTOCHECK: simulation timeout! Je hebt nog geen twee volledige beeldschermen opgebouwd na 40 ms. Dit klopt niet." severity failure;
  end process p_Timeout;
  
  p_TestVSync: process
    variable tDiffLow : time;
    variable tDiffPeriod : time;
  begin
    assert false report "INFO: Starting automated testbench: all error types will only be reported once!"
                 severity NOTE;
    assert false report "AUTOCHECKLIST" &
                        "<br>1: Heeft je HSync puls de juiste breedte?" &
                        "<br>2: Heeft HSync de juiste periode?" &
                        "<br>3: Heeft je VSync puls de juiste breedte?" &
                        "<br>4: Heeft VSync de juiste periode?" &
                        "<br>5: Wordt de HSync front porch gerespecteerd?" &
                        "<br>6: Wordt de HSync back porch gerespecteerd?" &
                        "<br>7: Wordt de VSync front porch gerespecteerd?" &
                        "<br>8: Wordt de VSync back porch gerespecteerd?" severity NOTE;
    wait until ResetN'event and ResetN = '1';
    -- ignore the first VSync pulse, as it might differ in length
    if VSync /= '0' then
      wait until VSync'event and VSync = '0';
    end if;
    NoVSyncYet  <= false;
    wait until VSync'event and VSync = '1';
    tHighVS     <= now;
    wait until VSync'event and VSync = '0';
    tLowVS      <= now;
    wait until VSync'event and VSync = '1';
    tDiffLow    := now - tLowVS;
    tDiffPeriod := now - tHighVS;
    if tDiffLow > c_VPW*c_upperMargin or tDiffLow < c_VPW*c_lowerMargin then
      assert AutoCheckError(3) report "AUTOCHECK 3: NOK: VSync puls breedte=" & time'image(tDiffLow) &
        " en wijkt dus meer dan 1% af van de vereiste " & time'image(c_VPW) severity NOTE;
      AutoCheckError(3)  <= true;
    end if;
    if tDiffPeriod > c_VTOT*c_upperMargin or tDiffPeriod < c_VTOT*c_lowerMargin then
      assert AutoCheckError(4) report "AUTOCHECK 4: NOK: VSync periode=" & time'image(tDiffPeriod) &
        " en wijkt dus meer dan 1% af van de vereiste " & time'image(c_VTOT) severity NOTE;
      AutoCheckError(4)  <= true;
    end if;
    AutoChecksLoop: for I in 1 to c_NumAutoChecks loop
      assert AutoCheckError(I) report "AUTOCHECK " & integer'image(I) & ": OK" severity NOTE;
    end loop AutoChecksLoop;
    assert false report "Automated simulation complete!" severity failure;
    wait;
  end process p_TestVSync;
  
  p_TestHSync: process
    variable tDiff : time;
  begin
    wait until ResetN'event and ResetN = '1';
    -- ignore the first HSync pulse, as it might differ in length
    wait until HSync'event and HSync = '0';
    wait until HSync'event and HSync = '1';
    tHighHS     <= now;
    wait until HSync'event and HSync = '0';
    HSyncLoop: loop
      tLowHS    <= now;
      wait until HSync'event and HSync = '1';
      tHighHS   <= now;
      tDiff     := now - tLowHS;
      if tDiff > c_HPW*c_upperMargin or tDiff < c_HPW*c_lowerMargin then
        assert AutoCheckError(1) report "AUTOCHECK 1: NOK: HSync puls breedte=" & time'image(tDiff) &
          " en wijkt dus meer dan 1% af van de vereiste " & time'image(c_HPW) severity NOTE;
        AutoCheckError(1)  <= true;
      end if;
      wait until HSync'event and HSync = '0';
      tDiff     := now - tLowHS;
      if tDiff > c_HTOT*c_upperMargin or tDiff < c_HTOT*c_lowerMargin then
        assert AutoCheckError(2) report "AUTOCHECK 2: NOK: HSync periode=" & time'image(tDiff) &
          " en wijkt dus meer dan 1% af van de vereiste " & time'image(c_HTOT) severity NOTE;
        AutoCheckError(2)  <= true;
      end if;
    end loop HSyncLoop;
  end process p_TestHSync;

  p_TestRGB: process(Red, Green, Blue)
    variable tDiffHS : time;
    variable tDiffVS : time;
  begin
    if now > 0 ns then 
      if Red /= "0000" or Blue /= "0000" or Green /= "0000" then
        tDiffHS := now - tHighHS;
        tDiffVS := now - tHighVS;
        if tDiffHS < c_HBP*c_lowerMargin and tDiffHS > 0 ns then
          assert AutoCheckError(6) report "AUTOCHECK 6: NOK: HSync back porch werd niet gerespecteerd." &
            "<br>RGB was niet nul " & time'image(tDiffHS) & " na de HSync puls en wijkt dus meer dan 1% af van de vereiste " &
            time'image(c_HBP) severity NOTE;
          AutoCheckError(6)  <= true;
        end if;
        if tDiffHS > (c_HTOT-c_HPW-c_HFP)*c_upperMargin then
          assert AutoCheckError(5) report "AUTOCHECK 5: NOK: HSync front porch werd niet gerespecteerd." &
            "<br>RGB was niet nul " & time'image(tDiffHS) & " na de HSync puls en wijkt dus meer dan 1% af van de vereiste " &
            time'image(c_HTOT-c_HPW-c_HFP) severity NOTE;
          AutoCheckError(5)  <= true;
        end if;
        if not NoVSyncYet then
          if tDiffVS < c_VBP*c_lowerMargin and tDiffVS > 0 ns then
            assert AutoCheckError(8) report "AUTOCHECK 8: NOK: VSync back porch werd niet gerespecteerd." &
              "<br>RGB was niet nul " & time'image(tDiffVS) & " na de VSync puls en wijkt dus meer dan 1% af van de vereiste " &
              time'image(c_VBP) severity NOTE;
            AutoCheckError(8)  <= true;
          end if;
          if tDiffVS > (c_VTOT-c_VPW-c_VFP)*c_upperMargin then
            assert AutoCheckError(7) report "AUTOCHECK 7: NOK: VSync front porch werd niet gerespecteerd." &
              "<br>RGB was niet nul " & time'image(tDiffVS) & " na de VSync puls en wijkt dus meer dan 1% af van de vereiste " &
              time'image(c_VTOT-c_VPW-c_VFP) severity NOTE;
            AutoCheckError(7)  <= true;
          end if;
        end if;
      end if;
    end if;
  end process p_TestRGB;
    
end Sim;

