library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stopwatch_controller is
    Port ( clk : in  STD_LOGIC; -- clock
           btn_toggle : in  STD_LOGIC; -- start/stop button for stopwatch, '1'-active
           btn_reset : in  STD_LOGIC; -- reset button for stopwatch, '0'-active
           sys_reset : in  STD_LOGIC; -- '0'-active reset for whole system
           watch_reset : out  STD_LOGIC; -- '1'-active reset for 16 bit couter
           watch_running : out  STD_LOGIC); -- '1'-active enable signal for counter
end stopwatch_controller;

architecture Behavioral of stopwatch_controller is

type controller_state is (s_zero, s_start, s_running, s_stop, s_stopped, s_reset);

signal state: controller_state; -- current state
signal next_state: controller_state; -- current state
signal toggle: std_logic; -- local snapshot of btn_toggle
signal reset: std_logic; -- local snapshot of btn_reset

begin

    -- state save loop / reset handling
    refresh_state: process (clk, sys_reset)
    begin
        if rising_edge(clk) then 
            if sys_reset = '0' then
                state <= s_zero;
            else
                state <= next_state;
            end if;
        end if;
    end process refresh_state;

    -- state transition logic
    transition: process (state, btn_toggle, btn_reset)
    begin
        -- whatever VHDL version we're using doesn't seem to support VHDL-2008 syntax...
        -- so when-else (basically C# switch expressions) won't work :P
        case state is
            -- "zero" <=> 00, 0- => 000, 1- => 001
            when s_zero =>
                if (btn_toggle = '1') then
                    next_state <= s_start;
                else
                    next_state <= s_zero;
                end if;
            -- "start" <=> 10, 00 => 010, 10|11|01 => 001
            when s_start =>
                if (btn_toggle = '0') and (btn_reset = '0') then
                    next_state <= s_running;
                else
                    next_state <= s_start;
                end if;
            -- "running" <=> 10, 0- => 010, 1- => 011
            when s_running =>
                if (btn_toggle = '1') then
                    next_state <= s_stop;
                else
                    next_state <= s_running;
                end if;
            -- "stop" <=> 00, 00 => 100, 10|11|01 => 011
            when s_stop =>
                if (btn_toggle = '0') and (btn_reset = '0') then
                    next_state <= s_stopped;
                else
                    next_state <= s_stop;
                end if;
            -- "stopped" <=> 00, 00 => 100, 01 => 101, 1- => 001
            when s_stopped =>
                if (btn_toggle = '1') then
                    next_state <= s_start;
                elsif (btn_reset = '1') then
                    next_state <= s_reset;
                else
                    next_state <= s_stopped;
                end if;
            -- "reset" <=> 01, 00 => 000, 01|11|10 => 101
            when s_reset =>
                if (btn_reset = '0') and (btn_toggle = '0') then
                    next_state <= s_zero;
                else
                    next_state <= s_reset;
                end if;
            when others =>
                report "Invalid state" severity failure;
        end case;
    end process transition;

    -- output logic
    -- triggered when next_state changes (I think)
    output: process (next_state)
    begin
        if (next_state = s_reset) then
            watch_reset <= '1';
        else
            watch_reset <= '0';
        end if;
        if (next_state = s_start) or (next_state = s_running) then
            watch_running <= '1';
        else 
            watch_running <= '0';
        end if;
    end process output;
    
end Behavioral;