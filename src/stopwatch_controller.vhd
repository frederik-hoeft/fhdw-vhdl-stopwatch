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
signal _state: std_logic_vector(2 downto 0); -- current state
signal _toggle: std_logic; -- local snapshot of btn_toggle
signal _reset: std_logic; -- local snapshot of btn_reset

begin
    -- state transition logic
    -- triggered on rising edge of clock
    process (clk)
    begin
        if rising_edge(clk) then
            -- reset state machine if sys_reset is active (low)
            if (sys_reset = '0') then
                _state <= "000";
                return;
            end if;
            -- update local snapshots of btn_toggle and btn_reset
            _toggle <= btn_toggle;
            _reset <= btn_reset;
            -- state transition logic, basically a C#-style switch-case on _state
            -- with switch expressions for next state
            case _state is
                -- 000: "zero", 0- => 000, 1- => 001
                when "000" => _state <= 
                    "001" when (_toggle = '1') else 
                    "000";
                -- 001: "start", 00 => 010, 10|11|01 => 001
                when "001" => _state <= 
                    "010" when (_toggle = '0') and (_reset = '0') else 
                    "001";
                -- 010: "running", 0- => 010, 1- => 011
                when "010" => _state <= 
                    "011" when (_toggle = '1') else 
                    "010";
                -- 011: "stop", 00 => 100, 10|11|01 => 011
                when "011" => _state <= 
                    "100" when (_toggle = '0') and (_reset = '0') else 
                    "011";
                -- 100: "stopped", 00 => 100, 01 => 101, 1- => 001
                when "100" => _state <= 
                    "001" when (_toggle = '1') else 
                    "101" when (_reset = '1') else 
                    "100";
                -- 101: "reset", 00 => 000, 01|11|10 => 101
                when "101" => _state <= 
                    "000" when (_reset = '0') and (_toggle = '0') else 
                    "101";
                when others =>
                    report "Invalid state" severity failure;
            end case;
        end if;
    end process;

    -- output logic
    -- triggered when _state changes (I think)
    process (_state)
    begin
        ctr_clear <= (_state = "101");
        ctr_enable <= (_state = "001") or (_state = "010");
    end process;
    
end Behavioral;