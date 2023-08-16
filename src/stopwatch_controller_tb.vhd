---------------------------------------------------------------
--                          TestBench
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use STD.TEXTIO.ALL;
use ieee.numeric_std.ALL;

entity stopwatch_controller_tbv is
-- Leere Portliste, Test-Bench hat keine Schnittstellen!
end stopwatch_controller_tbv;

architecture test_bench of stopwatch_controller_tbv is
-- component Declaration for the Unit Under Test (UUT)
component stopwatch_controller
port(clk,btn_toggle,btn_reset,sys_reset : in std_logic;
    watch_reset : OUT std_logic;
    watch_running : OUT std_logic);
end component;

--Inputs
signal clk: std_logic := '0';
signal btn_toggle: std_logic_vector(0 downto 0) := "0";
signal btn_reset : std_logic_vector(0 downto 0);
signal sys_reset : std_logic_vector(0 downto 0);

--Outputs
signal watch_reset : std_logic_vector(0 downto 0);
signal watch_running : std_logic_vector(0 downto 0);

--Variablen fuer den Simulationsablauf
signal DebugVariable : boolean:=true;
--=============================================================
--Functions
function char2std_logic (ch: in character) return std_logic is
begin
    case ch is
        when 'U' | 'u' => return 'U';
        when 'X' | 'x' => return 'X';
        when '0' => return '0';
        when '1' => return '1';
        when 'Z' | 'z' => return 'Z';
        when 'W' | 'w' => return 'W';
        when 'L' | 'l' => return 'L';
        when 'H' | 'h' => return 'H';
        when '-' => return '-';
        when others =>
    assert FALSE
        report "Illegal Character found" & ch
        severity error;
    return 'U';
    end case;
end;

function string2std_logic (s: string) return std_logic_vector is
variable vector: std_logic_vector(s'LEFT - 1 downto 0);
begin
    for i in s'range loop
        vector(i-1) := char2std_logic(s(i));
    end loop;
    return vector;
end;

-- converts std_logic into a character
function std_logic2char(sl: std_logic) return character is
        variable c: character;
        begin
            case sl is
                 when 'U' => c:= 'U';
                 when 'X' => c:= 'X';
                 when '0' => c:= '0';
                 when '1' => c:= '1';
                 when 'Z' => c:= 'Z';
                 when 'W' => c:= 'W';
                 when 'L' => c:= 'L';
                 when 'H' => c:= 'H';
                 when '-' => c:= '-';
            end case;
        return c;
     end std_logic2char;

function std_logic2string(slv: std_logic_vector) return string is
    variable result : string (1 TO slv'LENGTH);
    variable r : integer;
begin
    r := 1;
    for i in slv'range loop
        result(r) := std_logic2char(slv(i));
        r := r + 1;
    end loop;
    return result;
end std_logic2string;

shared variable expected1 : string(1 downto 1);
shared variable expected2 : string(1 downto 1);

-- Testbench
begin
-- Taktgenerator
clk <= not clk after 50 ns;

UUT: stopwatch_controller port map(clk=>clk, btn_toggle=>btn_toggle(0), btn_reset=>btn_reset(0), sys_reset=>sys_reset(0), watch_reset=>watch_reset(0), watch_running=>watch_running(0));

STIMULI: process(clk)
    file testpattern: text OPEN READ_MODE is "stopwatch_controller-inputs.txt";
    variable var_line: line;
    variable whitespace: character;
    variable var1: string(1 downto 1);
    variable var2: string(1 downto 1);
    variable var3: string(1 downto 1);
begin
    assert DebugVariable report "STIMULI" severity note;
    if(clk'event and clk = '1') then
        if(not endfile(testpattern)) then
            readline(testpattern, var_line);
            read(var_line, var1);
            btn_toggle <= string2std_logic(var1);
            -- ueberspringen des Leerzeichens
            read(var_line, whitespace);
            read(var_line, var2);
            btn_reset <= string2std_logic(var2);
            read(var_line, whitespace);
            read(var_line, var3);
            sys_reset <= string2std_logic(var3);
        else
            btn_toggle <= "0";
            btn_reset <= "0";
            sys_reset <= "1";
        end if;
    end if;
end process STIMULI;

RESPONSE: process(clk)
    file comparison_pattern: text OPEN READ_MODE is "stopwatch_controller-outputs.txt";
    variable var_line: line;
    variable whitespace: character;
    variable var1: string(1 downto 1);
    variable var2: string(1 downto 1);
begin
    assert DebugVariable report "EXPECTED" severity note;
    if(clk'event and clk = '1') then
        if(now > 100 ns) then
            if(not endfile(comparison_pattern)) then
                readline(comparison_pattern, var_line);
                read(var_line, var1);
                read(var_line, whitespace);
                read(var_line, var2);
                expected1 := var1;
                assert string2std_logic(var1) = watch_running
                    report "Vergleich fehlerhaft!" & "    Erwartungswert: " & var1 & "    Ergebnis: " & std_logic2string(watch_running)
                    severity warning;
                expected2 := var2;
                assert string2std_logic(var2) = watch_reset
                    report "Vergleich fehlerhaft!" & "    Erwartungswert: " & var2 & "    Ergebnis: " & std_logic2string(watch_reset)
                    severity warning;
            else 
                expected1 := (others => 'X');
                expected2 := (others => 'X');
            end if;
        end if;
    end if;
    --out2 <= StSpKnopf * ReKnopf;
end process RESPONSE;

MONITOR: process(clk)
    file protocol: text OPEN WRITE_MODE is "stopwatch_controller-test.log";
    variable var_line: line;
    variable whitespace: character := ' ';
    variable var1: string(1 downto 1);
    variable var2: string(1 downto 1);
    variable var3: string(1 downto 1);
    variable var4: string(1 downto 1);
    variable var5: string(1 downto 1);
    variable simulation_time: time;
begin
    assert DebugVariable report "MONITOR" severity note;
    if(now > 100 ns) then
        if(clk'event and clk = '1') then
            var1 := std_logic2string(btn_toggle);
            var2 := std_logic2string(btn_reset);
            var3 := std_logic2string(sys_reset);
            var4 := std_logic2string(watch_running); 
            var5 := std_logic2string(watch_reset);
            simulation_time := now;
            write(var_line, "btn_toggle: " & var1);
            write(var_line, whitespace);
            write(var_line, "btn_reset: " & var2);
            write(var_line, whitespace);
            write(var_line, "sys_reset: " & var3);
            write(var_line, whitespace);
            write(var_line, "watch_running: " & var4);
            write(var_line, whitespace);
            write(var_line, "watch_reset: " & var5);
            write(var_line, whitespace);
            write(var_line, "Expected watch_running: " & expected1);
            write(var_line, whitespace);
            write(var_line, "Expected watch_reset: " & expected2);
            write(var_line, whitespace);
            write(var_line, "Time: ");
            write(var_line, simulation_time);
            writeline(protocol, var_line);
        end if;
    end if;     
end process MONITOR;

end test_bench;
