----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:40:11 PM
-- Design Name: 
-- Module Name: IF_ID
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
entity IF_ID is
    port (
        clk       : in std_logic;
        rst       : in std_logic;
        I_instr_in  : in std_logic_vector(15 downto 0);
        O_opcode    : out std_logic_vector(6 downto 0);
        O_ra    :   out std_logic_vector(2 downto 0);
        O_rb    :   out std_logic_vector(2 downto 0);
        O_rc    :   out std_logic_vector(2 downto 0)
    );
end IF_ID;

architecture Behavioral of IF_ID is

begin
    -- Instruction decode process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                O_opcode <= (others => '0');
                O_ra <= (others => '0');
                O_rb <= (others => '0');
                O_rc <= (others => '0');
            else
                -- Latch certain parts of the inputted instruction
                O_opcode <= I_instr_in(15 downto 9);
                O_ra <= I_instr_in(8 downto 6);
                O_rb <= I_instr_in(5 downto 3);
                O_rc <= I_instr_in(2 downto 0);
            end if;
        end if;
    end process;
    
end Behavioral;