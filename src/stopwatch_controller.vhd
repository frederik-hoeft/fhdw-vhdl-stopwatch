library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stopwatch_controller is
    port ( clk : in  std_logic; -- clock
           btn_toggle : in  std_logic; -- start/stop button fOR stopwatch, '1'-active
           btn_reset : in  std_logic; -- reset button fOR stopwatch, '0'-active
           sys_reset : in  std_logic; -- '0'-active reset fOR whole system
           watch_reset : out  std_logic; -- '1'-active reset fOR 16 bit couter
           watch_running : out  std_logic); -- '1'-active enable signal fOR counter
end stopwatch_controller;

architecture behavioral OF stopwatch_controller is

type controller_state is (s_zero, s_start, s_running, s_stop, s_stopped, s_reset);

signal state: controller_state; -- current state
signal next_state: controller_state; -- current state
signal sys_reset_sff1: std_logic;
signal sys_reset_sff2: std_logic;
signal btn_reset_sff1: std_logic;
signal btn_reset_sff2: std_logic;
signal btn_toggle_sff1: std_logic;
signal btn_toggle_sff2: std_logic;

begin

    -- refresh synchronization flip flops
    refresh_sffs: process (clk)
    begin
        if rising_edge(clk) then
            sys_reset_sff2 <= sys_reset_sff1;
            sys_reset_sff1 <= sys_reset;
            btn_reset_sff2 <= btn_reset_sff1;
            btn_reset_sff1 <= btn_reset;
            btn_toggle_sff2 <= btn_toggle_sff1;
            btn_toggle_sff1 <= btn_toggle;
        end if;
    end process refresh_sffs;

    -- state save loop / reset handling
    refresh_state: process (clk, sys_reset_sff2)
    begin
        if rising_edge(clk) then 
            if sys_reset_sff2 = '0' then
                state <= s_zero;
            else
                state <= next_state;
            end if;
        end if;
    end process refresh_state;

    -- state transition logic
    transition: process (state, btn_toggle_sff2, btn_reset_sff2)
    begin
        -- whatever VHDL version we're using doesn't seem to suppORt VHDL-2008 syntax...
        -- so when-else (basically C# switch expressions) won't wORk :P
        case state is
            -- "zero" <=> 00, 0- => 000, 1- => 001
            when s_zero =>
                if (btn_toggle_sff2 = '1') then
                    next_state <= s_start;
                else
                    next_state <= s_zero;
                end if;
            -- "start" <=> 10, 00 => 010, 10|11|01 => 001
            when s_start =>
                if (btn_toggle_sff2 = '0') and (btn_reset_sff2 = '0') then
                    next_state <= s_running;
                else
                    next_state <= s_start;
                end if;
            -- "running" <=> 10, 0- => 010, 1- => 011
            when s_running =>
                if (btn_toggle_sff2 = '1') then
                    next_state <= s_stop;
                else
                    next_state <= s_running;
                end if;
            -- "stop" <=> 00, 00 => 100, 10|11|01 => 011
            when s_stop =>
                if (btn_toggle_sff2 = '0') and (btn_reset_sff2 = '0') then
                    next_state <= s_stopped;
                else
                    next_state <= s_stop;
                end if;
            -- "stopped" <=> 00, 00 => 100, 01 => 101, 1- => 001
            when s_stopped =>
                if (btn_toggle_sff2 = '1') then
                    next_state <= s_start;
                elsif (btn_reset_sff2 = '1') then
                    next_state <= s_reset;
                else
                    next_state <= s_stopped;
                end if;
            -- "reset" <=> 01, 00 => 000, 01|11|10 => 101
            when s_reset =>
                if (btn_reset_sff2 = '0') and (btn_toggle_sff2 = '0') then
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
    output: process (state)
    begin
        if (state = s_reset) then
            watch_reset <= '1';
        else
            watch_reset <= '0';
        end if;
        if (state = s_start) or (state = s_running) then
            watch_running <= '1';
        else 
            watch_running <= '0';
        end if;
    end process output;
    
end behavioral;