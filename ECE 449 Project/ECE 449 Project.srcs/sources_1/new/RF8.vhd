----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:38:49 PM
-- Design Name: 
-- Module Name: Register File
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

entity register_file is
    port(
        rst         : in std_logic; 
        clk         : in std_logic;
        rd_index1   : in std_logic_vector(2 downto 0); 
        rd_index2   : in std_logic_vector(2 downto 0); 
        rd_data1    : out std_logic_vector(15 downto 0); 
        rd_data2    : out std_logic_vector(15 downto 0);
        I_ra        : in std_logic_vector(2 downto 0);
        wr_index    : in std_logic_vector(2 downto 0); 
        wr_data     : in std_logic_vector(15 downto 0); 
        wr_enable   : in std_logic;
        I_is_shift  : in std_logic;
        I_is_InOut  : in std_logic
    );
end register_file;

architecture behavioural of register_file is
    type reg_array is array (integer range 0 to 7) of std_logic_vector(15 downto 0);
    -- Internal signals
    signal reg_file : reg_array;
    signal shift_amount : std_logic_vector(3 downto 0);
    signal concatenated : std_logic_vector(5 downto 0);
    
    -- Internal read address signals
    signal rd_addr1 : std_logic_vector(2 downto 0);
    signal data1_from_reg : std_logic_vector(15 downto 0);
    signal data2_from_reg : std_logic_vector(15 downto 0);

    signal ra_internal : std_logic_vector(2 downto 0) := "000";
    signal is_inout_internal : std_logic := '0';

begin
    -- Calculate concatenation and shift amount
    concatenated <= rd_index1 & rd_index2;
    shift_amount <= concatenated(3 downto 0);

    ra_internal <= I_ra;
    is_inout_internal <= I_is_InOut;

    -- Write operation (clocked)
    process(clk, rst)
    begin
        if rising_edge(clk) then
        -- Preloaded values
            if rst = '1' then
                reg_file(0) <= x"0000";
                reg_file(1) <= x"0003";
                reg_file(2) <= x"0005";
                reg_file(3) <= x"0000";
                reg_file(4) <= x"0000";
                reg_file(5) <= x"0000";
                reg_file(6) <= x"0000";
                reg_file(7) <= x"0000";
            elsif wr_enable = '1' then
                case wr_index is
                    when "000" => reg_file(0) <= wr_data;
                    when "001" => reg_file(1) <= wr_data;
                    when "010" => reg_file(2) <= wr_data;
                    when "011" => reg_file(3) <= wr_data;
                    when "100" => reg_file(4) <= wr_data;
                    when "101" => reg_file(5) <= wr_data;
                    when "110" => reg_file(6) <= wr_data;
                    when "111" => reg_file(7) <= wr_data;
                    when others => NULL;
                end case;
            end if;
        end if;
    end process;

    -- Control signal if the opcode is IN/OUT/SHIFT to use ra as rd_data1
    rd_addr1 <= I_ra when (is_inout_internal = '1' or I_is_shift = '1') else rd_index1;

    -- Read operation for data1_from_reg
    data1_from_reg <= 
        reg_file(0) when (rd_addr1 = "000") else
        reg_file(1) when (rd_addr1 = "001") else
        reg_file(2) when (rd_addr1 = "010") else
        reg_file(3) when (rd_addr1 = "011") else
        reg_file(4) when (rd_addr1 = "100") else
        reg_file(5) when (rd_addr1 = "101") else
        reg_file(6) when (rd_addr1 = "110") else 
        reg_file(7);

    -- Read operation for data2_from_reg
    data2_from_reg <= 
        reg_file(0) when (rd_index2 = "000") else
        reg_file(1) when (rd_index2 = "001") else
        reg_file(2) when (rd_index2 = "010") else
        reg_file(3) when (rd_index2 = "011") else
        reg_file(4) when (rd_index2 = "100") else
        reg_file(5) when (rd_index2 = "101") else
        reg_file(6) when (rd_index2 = "110") else 
        reg_file(7);

    -- Final output assignment
    rd_data1 <= data1_from_reg;
    rd_data2 <= (x"000" & shift_amount) when (I_is_shift = '1') else data2_from_reg;

end behavioural;