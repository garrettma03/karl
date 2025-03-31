----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Karl Hilario and Garrett Ma
-- 
-- Create Date: 02/24/2025 05:42:28 PM
-- Design Name: 
-- Module Name: ROM
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

Library xpm;
use xpm.vcomponents.all;

entity ROM is
    port(
        clk    : in std_logic;
        pc_addr   : in std_logic_vector(15 downto 0);
        rst    : in std_logic;
        sleep : in std_logic;
        injectsbiterra    : in std_logic;
        injectdbiterra    : in std_logic;
        instruction_out   : out std_logic_vector(15 downto 0);
        sbiterra  : out std_logic;
        dbiterra  : out std_logic;
        pc_enable : out std_logic
    );
end ROM;

architecture Behavioral of ROM is
    signal rom_addr       : std_logic_vector(7 downto 0);
    signal douta          : std_logic_vector(7 downto 0);
    signal low_byte       : std_logic_vector(7 downto 0) := (others => '0');
    signal high_byte      : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_latched     : std_logic_vector(7 downto 0) := (others => '0');
    signal ena, regcea    : std_logic := '1';
    signal stage          : integer range 0 to 5 := 0;
    signal instruction_reg : std_logic_vector(15 downto 0) := (others => '0');

begin
    -- xpm_memory_sprom: Single Port ROM
    -- Xilinx Parameterized Macro, Version 2017.4
    xpm_memory_sprom_inst : xpm_memory_sprom
        generic map (
            MEMORY_SIZE => 2048,
            MEMORY_PRIMITIVE => "auto",
            MEMORY_INIT_FILE => "Test_Format_A_16Bit.mem",
            MEMORY_INIT_PARAM => "",
            USE_MEM_INIT => 1,
            WAKEUP_TIME => "disable_sleep",
            MESSAGE_CONTROL => 0,
            ECC_MODE => "no_ecc",
            AUTO_SLEEP_TIME => 0,
            MEMORY_OPTIMIZATION => "true",
            READ_DATA_WIDTH_A => 8,
            ADDR_WIDTH_A => 8,
            READ_RESET_VALUE_A => "0",
            READ_LATENCY_A => 1
        )
        port map (
            sleep => sleep,
            clka => clk,
            rsta => rst,
            ena => ena,
            regcea => regcea,
            addra => rom_addr,
            injectsbiterra => '0',
            injectdbiterra => '0',
            douta => douta,
            sbiterra => open,
            dbiterra => open
        );
        
        -- End of xpm_memory_sprom_inst instance declaration

    -- ROM Access Process
    process(clk)
    begin
        if rising_edge(clk) then
        -- Set default values
            if rst = '1' then
                stage <= 0;
                rom_addr <= (others => '0');
                low_byte <= (others => '0');
                high_byte <= (others => '0');
                pc_latched <= (others => '0');
                instruction_reg <= (others => '0');
            else
                case stage is
                    when 0 =>
                        -- Start fetch for first byte
                        pc_latched <= pc_addr(7 downto 0);
                        rom_addr <= pc_addr(7 downto 0);
                        stage <= 1;
    
                    when 1 =>
                        -- Latency is set to 1 so we need 1 clock cycle to latch
                        stage <= 2;
                        
                    when 2 =>
                        -- Give extra stage for latching low value
                        low_byte <= douta;
                        rom_addr <= std_logic_vector(unsigned(pc_latched) + 1); -- Increment rom_addr to grab the next half of the instruction
                        stage <= 3;
    
                    when 3 =>
                        -- Latency is set to 1 so we need 1 clock cycle to latch
                        stage <= 4;
                        
                    when 4 =>
                        -- Give extra stage for latching high value
                        high_byte <= douta;
                        stage <= 5;
                        
                    when 5 =>
                        -- Concatenate the high and low bytes
                        instruction_reg <= high_byte & low_byte;
                        stage <= 0;
    
                    when others =>
                        stage <= 0;
                end case;
            end if;
        end if;
    end process;

    -- Output assignments
    instruction_out <= instruction_reg; -- Output the instruction
    pc_enable <= '1' when stage = 0 else '0';
    sbiterra <= '0';
    dbiterra <= '0';

end Behavioral;
