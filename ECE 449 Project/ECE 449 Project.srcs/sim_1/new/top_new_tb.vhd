----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/27/2025 02:36:03 PM
-- Design Name: 
-- Module Name: Top Testbench
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

entity cpu_top_tb is
end cpu_top_tb;

architecture Behavioral of cpu_top_tb is

    -- Top component declaration
    component top
        port(
            clk      : in  std_logic;
            in_port  : in  std_logic_vector(15 downto 0);
            out_port : out std_logic_vector(15 downto 0);
            rst_exec : in std_logic;
            rst_load : in std_logic
        );
    end component;


    -- Signals
    signal clk_tb       : std_logic := '0';
    signal rst_exec_tb  : std_logic := '0';
    signal rst_load_tb  : std_logic := '0';
    signal in_port_tb   : std_logic_vector(15 downto 0) := (others => '0');
    signal out_port_tb  : std_logic_vector(15 downto 0);

    -- Clock period (in ns)
    constant clk_period : time := 10 ns;

begin

    -- Top component instantiation
    Top_inst: top port map (
        clk         => clk_tb,
        rst_exec    => rst_exec_tb,
        rst_load    => rst_load_tb,
        in_port     => in_port_tb,
        out_port    => out_port_tb
    );

    -- Clock generator
    clk_process : process
    begin
        -- Generate Clock
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test procedure
    stim_proc: process
    begin
        -- Reset CPU
        wait for 30 ns;
        rst_exec_tb <= '1';
        wait for clk_period;
        -- Start Execution
        rst_exec_tb <= '0';
        wait for 500 ns;

        wait;
    end process;

end Behavioral;
