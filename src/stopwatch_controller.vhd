library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stopwatch_controller is
    Port ( clk : in  STD_LOGIC; -- clock
           btn_toggle : in  STD_LOGIC; -- start/stop button for stopwatch, '1'-active
           btn_reset : in  STD_LOGIC; -- reset button for stopwatch, '0'-active
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
signal _ctr_enable: std_logic; -- stable ctr_enable output
signal _ctr_clear: std_logic; -- stable ctr_clear output

begin
    process (clk)
    begin
        if rising_edge(clk) then
            _toggle <= btn_toggle;
            _reset <= btn_reset;
            _ctr_clear <= '0';
            case _state is
                -- 000: "zero" <=> 00, 0- => 000, 1- => 001
                when "000" =>
                    if (_toggle = '1') then
                        _state <= "001";
                    else
                        _state <= "000";
                    end if;
                    _ctr_enable <= '0';
                -- 001: "start" <=> 10, 00 => 010, 10|11|01 => 001
                when "001" =>
                    if (_toggle = '0') and (_reset = '0') then
                        _state <= "010";
                    else
                        _state <= "001";
                    end if;
                    _ctr_enable <= '1';
                -- 010: "running" <=> 10, 0- => 010, 1- => 011
                when "010" =>
                    if (_toggle = '1') then
                        _state <= "011";
                    else
                        _state <= "010";
                    end if;
                    _ctr_enable <= '1';
                -- 011: "stop" <=> 00, 00 => 100, 10|11|01 => 011
                when "011" =>
                    if (_toggle = '0') and (_reset = '0') then
                        _state <= "100";
                    else
                        _state <= "011";
                    end if;
                    _ctr_enable <= '0';
                -- 100: "stopped" <=> 00, 00 => 100, 01 => 101, 1- => 001
                when "100" =>
                    if (_toggle = '1') then
                        _state <= "001";
                    elsif (_reset = '1') then
                        _state <= "101";
                    else
                        _state <= "100";
                    end if;
                    _ctr_enable <= '0';
                -- 101: "reset" <=> 01, 00 => 000, 01|11|10 => 101
                when "101" =>
                    if (_reset = '0') and (_toggle = '0') then
                        _state <= "000";
                    else
                        _state <= "101";
                    end if;
                    _ctr_enable <= '0';
                    _ctr_clear <= '1';
            end case;
        end if;
    end process;
    ctr_clear <= _ctr_clear;
    ctr_enable <= _ctr_enable;
end Behavioral;