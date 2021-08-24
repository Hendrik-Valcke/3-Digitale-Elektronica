
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BresenhamPackage.all;
use work.VGAPackage.all;
--library UNISIM;
--use UNISIM.VComponents.all;

--in het scherm ligt (0,0) linksboven
--in het algoriteme zulle we echter normale coord. gebruiken (0,0) linksonder

--er wordt een finite state machine gebruikt (zie rond p50 cursus ann beniest)
entity Bresenham is
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
end Bresenham;

architecture Behavioral of Bresenham is
--types
type stateType IS (prepState, calcState, plotState);
--signals
signal state, nextState: stateType := prepState;
signal Xa,Xb,Ya,Yb: integer;--startwaarden v algoritme
signal dx :integer;
signal dy :integer;
signal stepX: integer; -- Xn coordinaat = X(n-1)+stepX (als de lijn naar links gaat is stepX =-1)
signal stepY: integer;
signal error:integer; --afwijking t.o.v. correcte lijn
signal Xi:integer;--huidige x,y waarden
signal Yi:integer;
signal errorI:integer;

begin
     
states:process(Clk,ResetN)
    begin
    if ResetN = '0' then --actief laag dus reset
        state<=prepState;
        else if(rising_edge(Clk))then --per klokslag state updaten
                state<=nextState;                
                --states uitvoeren
                case state is
                    when prepState => 
                        
                        if start= '1'then--wordt enkel uitgevoerd wanneer de FSM begint met verse XY0 en XY1 waarden (start = 1)
                            --XYa,XYb definieren
                            Xa<=to_integer(X0);
                            Xb<=to_integer(X1);
                            Ya<=to_integer(Y0);
                            Yb<=to_integer(Y1);
                            --daarvan steps, dx,dy en error bepalen
                            if (X1>X0) then
                                stepX <= 1;
                            else stepX<=-1;
                            end if;
                            if (Y1>Y0) then
                                stepY <= 1;
                            else stepY<=-1;
                            end if;
                            dx<=AbsVal(to_integer(X1)-to_integer(X0));
                            dy<=AbsVal(to_integer(Y1)-to_integer(Y0));
                            error<= dx-dy;
                            Plotting<='1';
                            else Plotting<='0';
                        end if;
                        nextState<=plotState;
                                                
                    when calcState =>
                        Plotting<='1';
                        --error,Xa,Ya updaten
                        --deze methode werkt niet omdat error tussen de ifs zou moeten updaten
--                            if (error*2 > -dy) then
--                                error<=error-dy;
--                                Xa<=Xa+stepX;
--                            end if;
--                            if (error*2 < dx) then
--                                error<=error+dx;
--                                Ya<=Ya+stepY;
--                            end if;
                        --de 2 if statements 'optellen' en de nieuwe en oude x-waarden scheiden:
                        if (errorI*2 >-dy and errorI*2 <dx)then
                            error<=errorI-dy+dx;
                            Xa<=Xi+stepX;
                            Ya<=Yi+stepY;
                        elsif (errorI*2 >-dy and not(errorI*2 <dx))then
                            error<=errorI-dy;
                            Xa<=Xi+stepX;
                            Ya<=Yi;
                        elsif (not(errorI*2 >-dy) and errorI*2 <dx)then
                            error<=errorI+dx;
                            Xa<=Xi;
                            Ya<=Yi+stepY;
                        elsif not(errorI*2 >-dy) and not(errorI*2 <dx)then
                            Xa<=Xi;
                            Ya<=Yi;
                        end if;                        
                        nextstate<=plotState;
                        
                    when plotState=>
                        plotX<=to_unsigned(Xa,Log2Ceil(c_HRes));
                        plotY<=to_unsigned(Ya,Log2Ceil(c_VRes));
                        Xi<=Xa;
                        Yi<=Ya;
                        errori<=error;
                        if not(Xa= Xb and Ya=Yb) then--nog niet aangekomen aan eindcoord
                            nextState<=calcState;--terug naar calcState om volgende stap te calculaten   
                            Plotting<='1';                                                    
                        else--wel aangekomenin eindpunt
                            nextState<=prepState;--terug naar begin om te wachten op instructies
                            Plotting<='0';
                        end if;
                                                
                    --when others=> nextState <= prepState;
                end case;
                
            end if;
    end if;
    end process states;
     
end Behavioral;
