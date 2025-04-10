----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:34:55 PM
-- Design Name: 
-- Module Name: EX_MEM
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

entity EX_MEM is
    port(
        rst             :   in  std_logic;
        clk             :   in  std_logic;
        I_mem_opr       :   in std_logic;
        I_wb_opr        :   in std_logic;
        I_ra            :   in std_logic_vector(2 downto 0);
        I_ALU_result    :   in std_logic_vector(15 downto 0);
        O_mem_addr      :   out std_logic_vector(15 downto 0);
        O_mem_opr       :   out std_logic;
        O_wb_opr        :   out std_logic;
        O_ra            :   out std_logic_vector(2 downto 0);
        O_mem_data      :   out std_logic_vector(15 downto 0)
    );
end EX_MEM;

architecture Behavioral of EX_MEM is

begin

    process(clk, rst)
    begin
        if rst = '1' then
        -- Set default values
            O_mem_addr <= (others => '0');
            O_mem_opr <= '0';	
            O_wb_opr <= '0';	
            O_ra <= (others => '0');
            O_mem_data <= (others => '0');
        elsif rising_edge(clk) then
            O_mem_opr <= I_mem_opr;
            O_wb_opr <= I_wb_opr;
            O_ra <= I_ra;
            O_mem_data <= I_ALU_result;
        end if;
    end process;

end Behavioral;
