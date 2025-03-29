----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2025 15:50:53
-- Design Name: 
-- Module Name: top_test - Behavioral
-- Project Name: 
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top is
    port (
        clk         : in  std_logic;
        rst_exec    : in  std_logic;  
        rst_load    : in  std_logic;  
        in_port     : in  std_logic_vector(15 downto 0);  -- (unused for now)
        out_port    : out std_logic_vector(15 downto 0)   -- (unused for now)
    );
end cpu_top;

architecture Behavioral of cpu_top is

    -- Signals
    signal pc_addr       : std_logic_vector(15 downto 0);
    signal instruction   : std_logic_vector(15 downto 0);
    signal opcode        : std_logic_vector(6 downto 0);
    signal ra, rb, rc    : std_logic_vector(2 downto 0);
    signal pc_enable_sig : std_logic;

begin

    -------------------------------------------------------------------
    -- Program Counter (PC)
    -------------------------------------------------------------------
    PC_inst : entity work.PC
        port map (
            clk         => clk,
            rst_exec    => rst_exec,
            rst_load    => rst_load,
            branch_en   => '0',  -- No branching for Format A
            branch_addr => (others => '0'),
            return_en   => '0',
            return_addr => (others => '0'),
            pc_enable   => pc_enable_sig,
            pc_out      => pc_addr
        );

    -------------------------------------------------------------------
    -- ROM (16-bit instruction via 2-byte reads)
    -------------------------------------------------------------------
    ROM_inst : entity work.ROM
        port map (
            clk             => clk,
            pc_addr         => pc_addr,
            rst             => rst_exec,
            sleep           => '0',
            injectsbiterra  => '0',
            injectdbiterra  => '0',
            instruction_out => instruction,
            pc_enable   => pc_enable_sig,
            sbiterra        => open,
            dbiterra        => open
        );

    -------------------------------------------------------------------
    -- IF/ID Register
    -------------------------------------------------------------------
    IF_ID_inst : entity work.IF_ID
        port map (
            clk        => clk,
            rst        => rst_exec,
            I_instr_in => instruction,
            O_opcode   => opcode,
            O_ra       => ra,
            O_rb       => rb,
            O_rc       => rc
        );

    -- Future connections to decoder, register file, ID/EX, ALU, etc.
    -- For now, this sets up the fetch and decode stage.

    -- Disable output for now
    out_port <= (others => '0');

end Behavioral;

