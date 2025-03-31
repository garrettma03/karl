----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:33:47 PM
-- Design Name: 
-- Module Name: MEM_WB
-- Project Name: CPU Project
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM_WB is
    port(
        rst :   in  std_logic;
        clk :   in  std_logic;
        I_wb_opr   :   in std_logic;
        O_wb_opr   :   out std_logic
    );
end MEM_WB;

architecture Behavioral of MEM_WB is

begin

    process (clk, rst)
    begin
        if rst = '1' then
        -- Set default value
            O_wb_opr <= '0';
        elsif rising_edge(clk) then
            O_wb_opr <= I_wb_opr;
        end if;

    end process;

end Behavioral;