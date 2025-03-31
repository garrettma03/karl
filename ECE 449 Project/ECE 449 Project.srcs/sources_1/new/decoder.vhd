----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:39:41 PM
-- Design Name: 
-- Module Name: Decoder
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
--use UNISIM.VComponents.all;;

entity decoder is
    port(
        clk :   in std_logic;
        rst :   in std_logic;
        I_op_code :   in std_logic_vector(6 downto 0);
        O_alu_mode  :   out std_logic_vector(6 downto 0);
        O_wb_opr    :   out std_logic;
        O_mem_opr   :   out std_logic;
        O_is_shift  :   out std_logic;
        O_is_InOut  :   out std_logic;
        O_branch_en :   out std_logic
    );
end decoder;

architecture Behavioral of decoder is 
--    type state_type is (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK);
--    signal state, next_state : state_type;

begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Set default values
 --            state <= FETCH;        
            O_alu_mode <= (others => '0');
            O_wb_opr <= '0';
            O_mem_opr <= '0';
            O_is_shift <= '0';
            O_is_InOut <= '0';
            O_branch_en <= '0';
        elsif rising_edge(clk) then
            -- Reset the values to ensure control signals don't stay high
            O_alu_mode <= (others => '0');
            O_wb_opr <= '0';
            O_mem_opr <= '0';
            O_is_shift <= '0';
            O_is_InOut <= '0';
            O_branch_en <= '0';

            case I_op_code is
                -- No Operation
                when "0000000" => O_alu_mode <= "0000000";-- NOP

                -- ALU Operations (Require Writeback)
                when "0000001" => O_alu_mode <= "0000001"; O_wb_opr <= '1'; -- ADD
                when "0000010" => O_alu_mode <= "0000010"; O_wb_opr <= '1'; -- SUB
                when "0000011" => O_alu_mode <= "0000011"; O_wb_opr <= '1'; -- MUL
                when "0000100" => O_alu_mode <= "0000100"; O_wb_opr <= '1'; -- NAND

                -- Shift Operations (Require Writeback)
                when "0000101" => O_alu_mode <= "0000101"; O_wb_opr <= '1'; O_is_shift <= '1'; -- SHL
                when "0000110" => O_alu_mode <= "0000110"; O_wb_opr <= '1'; O_is_shift <= '1'; -- SHR

                -- Test Operation (Affects Flags, No Writeback)
                when "0000111" => O_alu_mode <= "0000111"; -- TEST

                -- I/O Operations
                when "0100000" => O_alu_mode <= "0100000"; O_is_InOut <= '1'; -- OUT
                when "0100001" => O_alu_mode <= "0100001"; O_wb_opr <= '1'; O_is_InOut <= '1'; -- IN

                -- Branch and Control Flow
                when "1000000" => O_alu_mode <= "1000000"; O_branch_en <= '1';  -- BRR
                when "1000001" => O_alu_mode <= "1000001"; O_branch_en <= '1';  -- BRR.N
                when "1000010" => O_alu_mode <= "1000010"; O_branch_en <= '1';  -- BRR.Z
                when "1000011" => O_alu_mode <= "1000011"; O_branch_en <= '1';  -- BR
                when "1000100" => O_alu_mode <= "1000100"; O_branch_en <= '1';  -- BR.N
                when "1000101" => O_alu_mode <= "1000101"; O_branch_en <= '1';  -- BR.Z
                when "1000110" => O_alu_mode <= "1000110"; O_branch_en <= '1';  -- BR.SUB
                when "1000111" => O_alu_mode <= "1000111"; O_branch_en <= '1';  -- RETURN

                -- Memory Operations (Require Read/Write)
                when "0010000" => O_alu_mode <= "0010000"; O_mem_opr <= '1'; O_wb_opr <= '1'; -- LOAD
                when "0010001" => O_alu_mode <= "0010001"; O_mem_opr <= '1'; -- STORE
                when "0010010" => O_alu_mode <= "0010010"; O_wb_opr <= '1'; -- LOADIMM

                -- Stack Operations
                when "1100000" => O_alu_mode <= "1100000"; O_mem_opr <= '1'; -- PUSH
                when "1100001" => O_alu_mode <= "1100001"; O_mem_opr <= '1'; O_wb_opr <= '1'; -- POP
                when "1100010" => O_alu_mode <= "1100010"; O_wb_opr <= '1'; -- LOAD.SP

                -- Data Movement
                when "0010011" => O_alu_mode <= "0010011"; O_wb_opr <= '1'; -- MOV

                -- Special Operations
                when "1100011" => O_alu_mode <= "1100011"; -- RTI

                when others => null; -- No operation
            end case;
        end if;
    end process;
end Behavioral;