LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY stopwatch_controller IS
    PORT ( clk : IN  std_logic; -- clock
           btn_toggle : IN  std_logic; -- start/stop button fOR stopwatch, '1'-active
           btn_reset : IN  std_logic; -- reset button fOR stopwatch, '0'-active
           sys_reset : IN  std_logic; -- '0'-active reset fOR whole system
           watch_reset : OUT  std_logic; -- '1'-active reset fOR 16 bit couter
           watch_running : OUT  std_logic); -- '1'-active enable signal fOR counter
END stopwatch_controller;

ARCHITECTURE behavioral OF stopwatch_controller IS

TYPE controller_state IS (s_zero, s_start, s_running, s_stop, s_stopped, s_reset);

SIGNAL state: controller_state; -- current state
SIGNAL next_state: controller_state; -- current state

BEGIN

    -- state save loop / reset handling
    refresh_state: PROCESS (clk, sys_reset)
    BEGIN
        IF rising_edge(clk) THEN 
            IF sys_reset = '0' THEN
                state <= s_zero;
            ELSE
                state <= next_state;
            END IF;
        END IF;
    END PROCESS refresh_state;

    -- state transition logic
    transition: PROCESS (state, btn_toggle, btn_reset)
    BEGIN
        -- whatever VHDL version we're using doesn't seem to suppORt VHDL-2008 syntax...
        -- so WHEN-ELSE (basically C# switch expressions) won't wORk :P
        CASE state IS
            -- "zero" <=> 00, 0- => 000, 1- => 001
            WHEN s_zero =>
                IF (btn_toggle = '1') THEN
                    next_state <= s_start;
                ELSE
                    next_state <= s_zero;
                END IF;
            -- "start" <=> 10, 00 => 010, 10|11|01 => 001
            WHEN s_start =>
                IF (btn_toggle = '0') AND (btn_reset = '0') THEN
                    next_state <= s_running;
                ELSE
                    next_state <= s_start;
                END IF;
            -- "running" <=> 10, 0- => 010, 1- => 011
            WHEN s_running =>
                IF (btn_toggle = '1') THEN
                    next_state <= s_stop;
                ELSE
                    next_state <= s_running;
                END IF;
            -- "stop" <=> 00, 00 => 100, 10|11|01 => 011
            WHEN s_stop =>
                IF (btn_toggle = '0') AND (btn_reset = '0') THEN
                    next_state <= s_stopped;
                ELSE
                    next_state <= s_stop;
                END IF;
            -- "stopped" <=> 00, 00 => 100, 01 => 101, 1- => 001
            WHEN s_stopped =>
                IF (btn_toggle = '1') THEN
                    next_state <= s_start;
                ELSIF (btn_reset = '1') THEN
                    next_state <= s_reset;
                ELSE
                    next_state <= s_stopped;
                END IF;
            -- "reset" <=> 01, 00 => 000, 01|11|10 => 101
            WHEN s_reset =>
                IF (btn_reset = '0') AND (btn_toggle = '0') THEN
                    next_state <= s_zero;
                ELSE
                    next_state <= s_reset;
                END IF;
            WHEN OTHERS =>
                REPORT "Invalid state" SEVERITY failure;
        END CASE;
    END PROCESS transition;

    -- output logic
    -- triggered WHEN next_state changes (I think)
    output: PROCESS (state)
    BEGIN
        IF (state = s_reset) THEN
            watch_reset <= '1';
        ELSE
            watch_reset <= '0';
        END IF;
        IF (state = s_start) OR (state = s_running) THEN
            watch_running <= '1';
        ELSE 
            watch_running <= '0';
        END IF;
    END PROCESS output;
    
END behavioral;