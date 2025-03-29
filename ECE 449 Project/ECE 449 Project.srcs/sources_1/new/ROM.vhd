----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2025 05:15:21 PM
-- Design Name: 
-- Module Name: ROM - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library xpm;
use xpm.vcomponents.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM is
    port(
        clk    :   in std_logic;
        pc_addr   :   in std_logic_vector(15 downto 0);
        rst    :   in std_logic;
        sleep :   in std_logic;
        injectsbiterra    :   in std_logic;
        injectdbiterra    :   in std_logic;
        instruction_out   :   out std_logic_vector(15 downto 0);
        sbiterra  :   out std_logic;
        dbiterra  :   out std_logic;
        pc_enable : out std_logic
    );
end ROM;

architecture Behavioral of ROM is
    signal rom_addr       : std_logic_vector(7 downto 0);
    signal douta          : std_logic_vector(7 downto 0);
    signal low_byte       : std_logic_vector(7 downto 0) := (others => '0');
    signal high_byte      : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_latched     : std_logic_vector(7 downto 0) := (others => '0');
    signal ena, regcea : std_logic := '1';
    signal stage         : integer range 0 to 4 := 0;
    
begin
    -- xpm_memory_sprom: Single Port ROM
    -- Xilinx Parameterized Macro, Version 2017.4
    xpm_memory_sprom_inst : xpm_memory_sprom
        generic map (
        -- Common module generics
        MEMORY_SIZE => 2048, --positive integer
        MEMORY_PRIMITIVE => "auto", --string; "auto", "distributed", or "block";
        MEMORY_INIT_FILE => "Test_Format_A_16Bit.mem", --string; "none" or "<filename>.mem"
        MEMORY_INIT_PARAM => "", --string;
        USE_MEM_INIT => 1,
        WAKEUP_TIME => "disable_sleep", --string; "disable_sleep" or "use_sleep_pin"
        MESSAGE_CONTROL => 0, --integer; 0,1
        ECC_MODE => "no_ecc", --string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode"
        AUTO_SLEEP_TIME => 0, --Do not Change
        MEMORY_OPTIMIZATION => "true", --string; "true", "false"
        -- Port A module generics
        READ_DATA_WIDTH_A => 8, --positive integer
        ADDR_WIDTH_A => 8, --positive integer
        READ_RESET_VALUE_A => "0", --string
        READ_LATENCY_A => 2 --non-negative integer
        )
        port map (
            -- Common module ports
            sleep => sleep,
            -- Port A module ports
            clka => clk,
            rsta => rst,
            ena => ena,
            regcea => regcea,
            addra => rom_addr,
            injectsbiterra => '0', --do not change
            injectdbiterra => '0', --do not change
            douta => douta,
            sbiterra => open, --do not change
            dbiterra => open --do not change
    );
    -- End of xpm_memory_sprom_inst instance declaration
    
    -- ROM Access Process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                stage <= 0;
                rom_addr <= (others => '0');
                low_byte <= (others => '0');
                high_byte <= (others => '0');
                pc_latched <= (others => '0');
            else
                case stage is
                    when 0 =>
                        -- Stage 0: start fetch from pc_addr (low byte)
                        pc_latched <= pc_addr(7 downto 0);
                        rom_addr <= pc_addr(7 downto 0);
                        stage <= 1;

                    when 1 =>
                        -- Wait for ROM latency
                        stage <= 2;

                    when 2 =>
                        -- Latch low byte, issue high byte read
                        low_byte <= douta;
                        rom_addr <= std_logic_vector(unsigned(pc_latched) + 1);
                        stage <= 3;

                    when 3 =>
                        -- Wait for ROM latency
                        stage <= 4;

                    when 4 =>
                        -- Latch high byte
                        high_byte <= douta;
                        stage <= 0;

                    when others =>
                        stage <= 0;
                end case;
            end if;
        end if;
    end process;
    
    -- Final instruction
    instruction_out <= low_byte & high_byte;
    pc_enable <= '1' when stage = 0 else '0';


end Behavioral;
