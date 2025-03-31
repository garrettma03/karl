----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:36:13 PM
-- Design Name: 
-- Module Name: ALU
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

entity ALU is
    port(
        rst       : in std_logic;
        I_in1       : in std_logic_vector(15 downto 0);
        I_in2       : in std_logic_vector(15 downto 0);
        alu_mode  : in std_logic_vector(6 downto 0);
        z_flag    : out std_logic;
        n_flag    : out std_logic;
        result    : out std_logic_vector(15 downto 0)
    );
end ALU;

architecture Behavioral of ALU is
    
begin

    process(I_in1, I_in2, alu_mode, rst)
    
        -- Variables
        variable a, b   :   signed(15 downto 0);
        variable temp_res   :   signed(15 downto 0);
        variable shift_amount  :   integer;
        variable unsigned_a : unsigned(15 downto 0);
        variable bN_flag, bZ_flag   :   std_logic;
        

    begin
    
    if rst = '1' then
        temp_res := (others => '0');
        bZ_flag := '0';
        bN_flag := '0';
    else
        a := signed(I_in1);
        b := signed(I_in2);
        unsigned_a := unsigned(I_in1);
        temp_res := (others => '0');
        bZ_flag := '0';
        bN_flag := '0';
        
        -- ALU Cases
        case alu_mode is
            when "0000000" => temp_res := resize(a, 16); -- Pass though input 1
            when "0000001" => temp_res := resize((a + b), 16); -- Add input 1 and 2
            when "0000010" => temp_res := resize((a - b), 16); -- Subtract input 1 and 2
            when "0000011" => temp_res := resize(signed(a) * signed(b), 16); -- Multiply input 1 and 2
            when "0000100" => temp_res := resize(not(a and b), 16); -- NAND input 1 and 2
            when "0000101" => -- Shift left input 1 by input 2 (unsigned)
                -- Convert b to an integer for the shift amount
                temp_res := resize(shift_left(a, to_integer(unsigned(b))), 16);
                            
            when "0000110" => -- Shift right input 1 by input 2 (unsigned)
                -- Convert b to an integer for the shift amount
                temp_res := resize(shift_right(a, to_integer(unsigned(b))), 16);
            when "0000111" => temp_res := resize(a, 16);
                          if a = 0 then
                            bZ_flag := '1';
                          else
                            bZ_flag := '0';
                          end if;
                          if a < 0 then
                            bN_flag := '1';
                          else
                            bN_flag := '0';
                          end if;
                      
            
            when "0100000" => temp_res := resize(a, 16); -- Input
            when "0100001" => temp_res := resize(a, 16); -- Output              
                          
            when others => NULL;

        end case;
        
        -- Update flags based on the result for all operations
        if temp_res = 0 then
            bZ_flag := '1';
        else
            bZ_flag := '0';
        end if;
        
        if temp_res < 0 then
            bN_flag := '1';
        else
            bN_flag := '0';
        end if;
    end if;
    
    -- Outputs
    result <= std_logic_vector(temp_res);
    z_flag <= bZ_flag;
    n_flag <= bN_flag;
    
end process;

end Behavioral;