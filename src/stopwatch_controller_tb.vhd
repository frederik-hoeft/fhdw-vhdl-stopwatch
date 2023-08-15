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
-- Component Declaration FOR the Unit Under Test (UUT)
COMPONENT stopwatch_controller
PORT(clk,btn_toggle,btn_reset,sys_reset : IN std_logic;
    watch_reset : OUT std_logic;
    watch_running : OUT std_logic);
END COMPONENT;

--Inputs
SIGNAL clk: std_logic := '0';
SIGNAL btn_toggle: std_logic_vector(0 DOWNTO 0) := "0";
SIGNAL btn_reset : std_logic_vector(0 DOWNTO 0);
SIGNAL sys_reset : std_logic_vector(0 DOWNTO 0);

--Outputs
SIGNAL watch_reset : std_logic_vector(0 DOWNTO 0);
SIGNAL watch_running : std_logic_vector(0 DOWNTO 0);

--Variablen fuer den Simulationsablauf
SIGNAL DebugVariable : boolean:=true;
--=============================================================
--Functions
FUNCTION char2std_logic (ch: IN character) RETURN std_logic IS
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
        SEVERITY error;
    RETURN 'U';
    END CASE;
END;

FUNCTION string2std_logic (s: string) RETURN std_logic_vector IS
VARIABLE vector: std_logic_vector(s'LEFT - 1 DOWNTO 0);
BEGIN
    FOR i IN s'RANGE LOOP
        vector(i-1) := char2std_logic(s(i));
    END LOOP;
    RETURN vector;
END;

-- converts std_logic into a character
FUNCTION std_logic2char(sl: std_logic) RETURN character IS
        VARIABLE c: character;
        BEGIN
            CASE sl IS
                 WHEN 'U' => c:= 'U';
                 WHEN 'X' => c:= 'X';
                 WHEN '0' => c:= '0';
                 WHEN '1' => c:= '1';
                 WHEN 'Z' => c:= 'Z';
                 WHEN 'W' => c:= 'W';
                 WHEN 'L' => c:= 'L';
                 WHEN 'H' => c:= 'H';
                 WHEN '-' => c:= '-';
            END CASE;
        RETURN c;
     END std_logic2char;

FUNCTION std_logic2string(slv: std_logic_vector) RETURN string IS
    VARIABLE result : string (1 TO slv'LENGTH);
    VARIABLE r : integer;
BEGIN
    r := 1;
    FOR i IN slv'RANGE LOOP
        result(r) := std_logic2char(slv(i));
        r := r + 1;
    END LOOP;
    RETURN result;
END std_logic2string;

SHARED VARIABLE expected1 : string(1 DOWNTO 1);
SHARED VARIABLE expected2 : string(1 DOWNTO 1);

-- Testbench
BEGIN
-- Taktgenerator
clk <= NOT clk AFTER 50 ns;

UUT: stopwatch_controller PORT MAP(clk=>clk, btn_toggle=>btn_toggle(0), btn_reset=>btn_reset(0), sys_reset=>sys_reset(0), watch_reset=>watch_reset(0), watch_running=>watch_running(0));

STIMULI: PROCESS(clk)
    FILE testpattern: text OPEN READ_MODE IS "stopwatch_controller-inputs.txt";
    VARIABLE var_line: line;
    VARIABLE whitespace: character;
    VARIABLE var1: string(1 DOWNTO 1);
    VARIABLE var2: string(1 DOWNTO 1);
    VARIABLE var3: string(1 DOWNTO 1);
BEGIN
    ASSERT DebugVariable REPORT "STIMULI" SEVERITY note;
    IF(clk'EVENT AND clk = '1') THEN
        IF(NOT endfile(testpattern)) THEN
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
        ELSE
            btn_toggle <= "0";
            btn_reset <= "0";
            sys_reset <= "1";
        END IF;
    END IF;
END PROCESS STIMULI;

RESPONSE: PROCESS(clk)
    FILE comparison_pattern: text OPEN READ_MODE IS "stopwatch_controller-outputs.txt";
    VARIABLE var_line: line;
    VARIABLE whitespace: character;
    VARIABLE var1: string(1 DOWNTO 1);
    VARIABLE var2: string(1 DOWNTO 1);
BEGIN
    ASSERT DebugVariable REPORT "EXPECTED" SEVERITY note;
    IF(clk'EVENT AND clk = '1') THEN
        IF(now > 100 ns) THEN
            IF(NOT endfile(comparison_pattern)) THEN
                readline(comparison_pattern, var_line);
                read(var_line, var1);
                read(var_line, whitespace);
                read(var_line, var2);
                expected1 := var1;
                ASSERT string2std_logic(var1) = watch_running
                    REPORT "Vergleich fehlerhaft!" & "    Erwartungswert: " & var1 & "    Ergebnis: " & std_logic2string(watch_running)
                    SEVERITY warning;
                expected2 := var2;
                ASSERT string2std_logic(var2) = watch_reset
                    REPORT "Vergleich fehlerhaft!" & "    Erwartungswert: " & var2 & "    Ergebnis: " & std_logic2string(watch_reset)
                    SEVERITY warning;
            ELSE 
                expected1 := (others => 'X');
                expected2 := (others => 'X');
            END IF;
        END IF;
    END IF;
    --out2 <= StSpKnopf * ReKnopf;
END PROCESS RESPONSE;

MONITOR: PROCESS(clk)
    FILE protocol: text OPEN WRITE_MODE IS "stopwatch_controller-test.log";
    VARIABLE var_line: line;
    VARIABLE whitespace: character := ' ';
    VARIABLE var1: string(1 DOWNTO 1);
    VARIABLE var2: string(1 DOWNTO 1);
    VARIABLE var3: string(1 DOWNTO 1);
    VARIABLE var4: string(1 DOWNTO 1);
    VARIABLE var5: string(1 DOWNTO 1);
    VARIABLE simulation_time: time;
BEGIN
    ASSERT DebugVariable REPORT "MONITOR" SEVERITY note;
    IF(now > 100 ns) THEN
        IF(clk'EVENT AND clk = '1') THEN
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
        END IF;
    END IF;     
END PROCESS MONITOR;

END test_bench;
