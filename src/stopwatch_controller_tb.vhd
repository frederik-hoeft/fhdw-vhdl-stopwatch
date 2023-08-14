---------------------------------------------------------------
--                          TestBench
---------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE STD.TEXTIO.ALL;
USE ieee.numeric_std.ALL;

ENTITY stopwatch_controller_tbv IS
-- Leere Portliste, Test-Bench hat keine Schnittstellen!
END stopwatch_controller_tbv;

ARCHITECTURE test_bench OF stopwatch_controller_tbv IS
-- Component Declaration for the Unit Under Test (UUT)
COMPONENT stopwatch_controller
PORT(clk,btn_toggle,btn_reset,sys_reset : in std_logic;
    watch_reset : out std_logic;
    watch_running : out std_logic);
END COMPONENT;

--Inputs
SIGNAL clk: std_logic := '0';
SIGNAL btn_toggle: std_logic_vector(0 DOWNTO 0) := "0";
SIGNAL btn_reset : std_logic_vector(0 DOWNTO 0);
SIGNAL sys_reset : std_logic_vector(0 DOWNTO 0);

--Outputs
SIGNAL watch_reset : std_logic_vector(0 downto 0);
SIGNAL watch_running : std_logic_vector(0 downto 0);

--Variablen fuer den Simulationsablauf
SIGNAL DebugVariable : boolean:=true;
--=============================================================
--Functions
FUNCTION char2std_logic (ch: IN CHARACTER) RETURN std_logic IS
BEGIN
    CASE ch IS
        WHEN 'U' | 'u' => RETURN 'U';
        WHEN 'X' | 'x' => RETURN 'X';
        WHEN '0' => RETURN '0';
        WHEN '1' => RETURN '1';
        WHEN 'Z' | 'z' => RETURN 'Z';
        WHEN 'W' | 'w' => RETURN 'W';
        WHEN 'L' | 'l' => RETURN 'L';
        WHEN 'H' | 'h' => RETURN 'H';
        WHEN '-' => RETURN '-';
        WHEN OTHERS =>
    ASSERT FALSE
        REPORT "Illegal Character found" & ch
        SEVERITY ERROR;
    RETURN 'U';
    END CASE;
END;

FUNCTION string2std_logic (s: STRING) RETURN std_logic_vector IS
VARIABLE vector: std_logic_vector(s'LEFT - 1 DOWNTO 0);
BEGIN
    FOR i IN s'RANGE LOOP
        vector(i-1) := char2std_logic(s(i));
    END LOOP;
    RETURN vector;
END;

-- converts std_logic into a character
FUNCTION std_logic2char(sl: std_logic) return character is
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

FUNCTION std_logic2string(slv: std_logic_vector) return string is
    variable result : string (1 to slv'length);
    variable r : integer;
begin
    r := 1;
    for i in slv'range loop
        result(r) := std_logic2char(slv(i));
        r := r + 1;
    end loop;
    return result;
end std_logic2string;

shared variable expected1 : STRING(1 DOWNTO 1);
shared variable expected2 : STRING(1 DOWNTO 1);

-- Testbench
BEGIN
-- Taktgenerator
clk <= NOT clk AFTER 50 ns;

UUT: stopwatch_controller PORT MAP(clk=>clk, btn_toggle=>btn_toggle(0), btn_reset=>btn_reset(0), sys_reset=>sys_reset(0), watch_reset=>watch_reset(0), watch_running=>watch_running(0));

STIMULI: PROCESS(clk)
    FILE testpattern: TEXT OPEN READ_MODE IS "stopwatch_controller-inputs.txt";
    VARIABLE zeile: LINE;
    VARIABLE leerzeichen: CHARACTER;
    VARIABLE var1: STRING(1 DOWNTO 1);
    VARIABLE var2: STRING(1 DOWNTO 1);
    VARIABLE var3: STRING(1 DOWNTO 1);
BEGIN
    ASSERT DebugVariable REPORT "STIMULI" SEVERITY NOTE;
    IF(clk'EVENT AND clk = '1') THEN
        IF(NOT endfile(testpattern)) THEN
            readline(testpattern, zeile);
            read(zeile, var1);
            btn_toggle <= string2std_logic(var1);
            -- ueberspringen des Leerzeichens
            read(zeile, leerzeichen);
            read(zeile, var2);
            btn_reset <= string2std_logic(var2);
            read(zeile, leerzeichen);
            read(zeile, var3);
            sys_reset <= string2std_logic(var3);
        ELSE
            btn_toggle <= "0";
            btn_reset <= "0";
            sys_reset <= "1";
        END IF;
    END IF;
END PROCESS STIMULI;

RESPONSE: PROCESS(clk)
    FILE vergleichspattern: TEXT OPEN READ_MODE IS "stopwatch_controller-outputs.txt";
    VARIABLE zeile: LINE;
    VARIABLE leerzeichen: CHARACTER;
    VARIABLE var1: STRING(1 DOWNTO 1);
    VARIABLE var2: STRING(1 DOWNTO 1);
BEGIN
    ASSERT DebugVariable REPORT "EXPECTED" SEVERITY NOTE;
    IF(clk'EVENT AND clk = '1') THEN
        IF(NOW > 100 ns) THEN
            IF(NOT endfile(vergleichspattern)) THEN
                readline(vergleichspattern, zeile);
                read(zeile, var1);
                read(zeile, leerzeichen);
                read(zeile, var2);
                expected1 := var1;
                ASSERT string2std_logic(var1) = watch_running
                    REPORT "Vergleich fehlerhaft!" & "    Erwartungswert: " & var1 & "    Ergebnis: " & std_logic2string(watch_running)
                    SEVERITY WARNING;
                expected2 := var2;
                ASSERT string2std_logic(var2) = watch_reset
                    REPORT "Vergleich fehlerhaft!" & "    Erwartungswert: " & var2 & "    Ergebnis: " & std_logic2string(watch_reset)
                    SEVERITY WARNING;
            ELSE 
                expected1 := (others => 'X');
                expected2 := (others => 'X');
            END IF;
        END IF;
    END IF;
    --out2 <= StSpKnopf * ReKnopf;
END PROCESS RESPONSE;

MONITOR: PROCESS(clk)
    FILE protokoll: TEXT OPEN WRITE_MODE IS "stopwatch_controller-test.log";
    VARIABLE zeile: LINE;
    VARIABLE leerzeichen: CHARACTER := ' ';
    VARIABLE var1: STRING(1 DOWNTO 1);
    VARIABLE var2: STRING(1 DOWNTO 1);
    VARIABLE var3: STRING(1 DOWNTO 1);
    VARIABLE var4: STRING(1 DOWNTO 1);
    VARIABLE var5: STRING(1 DOWNTO 1);
    VARIABLE simulationszeit: TIME;
BEGIN
    ASSERT DebugVariable REPORT "MONITOR" SEVERITY NOTE;
    IF(NOW > 100 ns) THEN
        IF(clk'EVENT AND clk = '1') THEN
            var1 := std_logic2string(btn_toggle);
            var2 := std_logic2string(btn_reset);
            var3 := std_logic2string(sys_reset);
            var4 := std_logic2string(watch_running);
            var5 := std_logic2string(watch_reset);
            simulationszeit := NOW;
            write(zeile, "btn_toggle: " & var1);
            write(zeile, leerzeichen);
            write(zeile, "btn_reset: " & var2);
            write(zeile, leerzeichen);
            write(zeile, "sys_reset: " & var3);
            write(zeile, leerzeichen);
            write(zeile, "watch_running: " & var4);
            write(zeile, leerzeichen);
            write(zeile, "watch_reset: " & var5);
            write(zeile, leerzeichen);
            write(zeile, "Expected watch_running: " & expected1);
            write(zeile, leerzeichen);
            write(zeile, "Expected watch_reset: " & expected2);
            write(zeile, leerzeichen);
            write(zeile, "Time: ");
            write(zeile, simulationszeit);
            writeline(protokoll, zeile);
        END IF;
    END IF;     
END PROCESS MONITOR;

END test_bench;
