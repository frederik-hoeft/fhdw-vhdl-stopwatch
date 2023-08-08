library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stopwatch_controller is
    Port ( clk : in  STD_LOGIC; -- clock
           btn_toggle : in  STD_LOGIC; -- start/stop button for stopwatch, '1'-active
           btn_reset : in  STD_LOGIC; -- reset button for stopwatch, '0'-active
           sys_reset : in  STD_LOGIC; -- '0'-active reset for whole system
           ctr_clear : out  STD_LOGIC; -- '1'-active reset for 16 bit couter
           ctr_enable : out  STD_LOGIC); -- '1'-active enable signal for counter
end stopwatch_controller;

architecture Behavioral of stopwatch_controller is

-- "-" <==> "don't care", "|" <==> "OR"
-- STATE <=> OUTPUT (ctr_enable, ctr_clear), TRANSITION 1 (btn_toggle, btn_reset) => STATE, TRANSITION 2 ...
-- 000: "zero" <=> 00, 0- => 000, 1- => 001
-- 001: "start" <=> 10, 00 => 010, 10|11|01 => 001
-- 010: "running" <=> 10, 0- => 010, 1- => 011
-- 011: "stop" <=> 00, 00 => 100, 10|11|01 => 011
-- 100: "stopped" <=> 00, 00 => 100, 01 => 101, 1- => 001
-- 101: "reset" <=> 01, 00 => 000, 01|11|10 => 101
signal loc_state: std_logic_vector(2 downto 0); -- current state
signal loc_toggle: std_logic; -- local snapshot of btn_toggle
signal loc_reset: std_logic; -- local snapshot of btn_reset

begin
    -- state transition logic
    -- triggered on rising edge of clock
    process (clk)
    begin
        if rising_edge(clk) then
            -- reset state machine if sys_reset is active (low)
            if (sys_reset = '0') then
                loc_state <= "000";
            else
                -- update local snapshots of btn_toggle and btn_reset
                loc_toggle <= btn_toggle;
                loc_reset <= btn_reset;
                -- whatever VHDL version we're using doesn't seem to support VHDL-2008 syntax...
                -- so when-else (basically C# switch expressions) won't work :P
                case loc_state is
                    -- 000: "zero" <=> 00, 0- => 000, 1- => 001
                    when "000" =>
                        if (loc_toggle = '1') then
                            loc_state <= "001";
                        else
                            loc_state <= "000";
                        end if;
                    -- 001: "start" <=> 10, 00 => 010, 10|11|01 => 001
                    when "001" =>
                        if (loc_toggle = '0') and (loc_reset = '0') then
                            loc_state <= "010";
                        else
                            loc_state <= "001";
                        end if;
                    -- 010: "running" <=> 10, 0- => 010, 1- => 011
                    when "010" =>
                        if (loc_toggle = '1') then
                            loc_state <= "011";
                        else
                            loc_state <= "010";
                        end if;
                    -- 011: "stop" <=> 00, 00 => 100, 10|11|01 => 011
                    when "011" =>
                        if (loc_toggle = '0') and (loc_reset = '0') then
                            loc_state <= "100";
                        else
                            loc_state <= "011";
                        end if;
                    -- 100: "stopped" <=> 00, 00 => 100, 01 => 101, 1- => 001
                    when "100" =>
                        if (loc_toggle = '1') then
                            loc_state <= "001";
                        elsif (loc_reset = '1') then
                            loc_state <= "101";
                        else
                            loc_state <= "100";
                        end if;
                    -- 101: "reset" <=> 01, 00 => 000, 01|11|10 => 101
                    when "101" =>
                        if (loc_reset = '0') and (loc_toggle = '0') then
                            loc_state <= "000";
                        else
                            loc_state <= "101";
                        end if;
                    when others =>
                        report "Invalid state" severity failure;
                end case;
            end if;
        end if;
    end process;

    -- output logic
    -- triggered when loc_state changes (I think)
    process (loc_state)
    begin
        if (loc_state = "101") then
            ctr_clear <= '1';
        else
            ctr_clear <= '0';
        end if;
        if (loc_state = "001") or (loc_state = "010") then
            ctr_enable <= '1';
        else 
            ctr_enable <= '0';
        end if;
    end process;
    
end Behavioral;