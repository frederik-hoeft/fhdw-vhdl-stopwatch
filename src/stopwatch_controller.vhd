----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:29:19 08/08/2023 
-- Design Name: 
-- Module Name:    stopwatch_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
signal _state: std_logic_vector(2 downto 0);

begin

    process (clk)
    begin
        if rising_edge(clk) then

        end if;
    end process;


end Behavioral;

