----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:37:42 PM
-- Design Name: 
-- Module Name: ID_EX
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

entity ID_EX is
    port(
        rst :   in  std_logic;
        clk :   in  std_logic;
        I_alu_mode  :   in  std_logic_vector(6 downto 0);
        I_wb_opr    :   in  std_logic;
        I_mem_opr   :   in  std_logic;
        I_ra    :   in  std_logic_vector(2 downto 0);
        I_rd1   :   in  std_logic_vector(15 downto 0);
        I_rd2   :   in  std_logic_vector(15 downto 0);
        O_op1   :   out std_logic_vector(15 downto 0);
        O_op2   :   out std_logic_vector(15 downto 0);
        O_alu_mode  :   out std_logic_vector(6 downto 0);
        O_wb_opr    :   out std_logic;
        O_mem_opr   :   out std_logic;
        O_ra    :   out std_logic_vector(2 downto 0)
    );
end ID_EX;

architecture Behavioral of ID_EX is

begin

    process(clk, rst)
    begin
        if rst = '1' then
        -- Set default values
            O_op1 <= (others => '0');	
            O_op2 <= (others => '0');	
            O_alu_mode <= (others => '0');	
            O_wb_opr <= '0';
            O_mem_opr <= '0';
            O_ra <= (others => '0');	
        elsif rising_edge(clk) then
            O_op1 <= I_rd1;	
            O_op2 <= I_rd2;	
            O_alu_mode <= I_alu_mode;	
            O_wb_opr <= I_wb_opr;
            O_mem_opr <= I_mem_opr;
            O_ra <= I_ra;
        end if;
    end process;

end architecture;