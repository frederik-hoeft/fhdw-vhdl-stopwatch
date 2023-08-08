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
    Port ( btn_toggle : in  STD_LOGIC;
           btn_reset : in  STD_LOGIC;
           ctr_clear : out  STD_LOGIC;
           ctr_enable : out  STD_LOGIC);
end stopwatch_controller;

architecture Behavioral of stopwatch_controller is

begin


end Behavioral;

