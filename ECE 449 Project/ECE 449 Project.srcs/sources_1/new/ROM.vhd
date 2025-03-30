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
-- Description: Fixed ROM read latency, addressing, and reset handling.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library xpm;
use xpm.vcomponents.all;

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
    signal douta, douta_reg : std_logic_vector(15 downto 0);
    signal low_byte  : std_logic_vector(7 downto 0) := (others => '0');
    signal high_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_latched     : std_logic_vector(7 downto 0) := (others => '0');
    signal ena, regcea    : std_logic := '1';
    signal stage          : integer range 0 to 6 := 0;
    signal reset_done     : std_logic := '0';
    
    
begin
    -- XPM Single Port ROM instance
    xpm_memory_sprom_inst : xpm_memory_sprom
        generic map (
        MEMORY_SIZE => 65536,
        MEMORY_PRIMITIVE => "auto",
        MEMORY_INIT_FILE => "Test_Format_A_16Bit.mem",
        MEMORY_INIT_PARAM => "",
        USE_MEM_INIT => 1,
        WAKEUP_TIME => "disable_sleep",
        MESSAGE_CONTROL => 0,
        ECC_MODE => "no_ecc",
        AUTO_SLEEP_TIME => 0,
        MEMORY_OPTIMIZATION => "true",
        READ_DATA_WIDTH_A => 16,
        ADDR_WIDTH_A => 8,
        READ_RESET_VALUE_A => "0",
        READ_LATENCY_A => 2
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
    
    -- ROM Access Process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reset_done <= '0';
                stage <= 0;
                rom_addr <= (others => '0');
            elsif reset_done = '0' then
                reset_done <= '1';
            else
                case stage is
                    when 0 =>
                        -- Fetch 16-bit instruction from pc_addr
                        rom_addr <= pc_addr;
                        stage <= 1;
                    
                    when 1 =>
                        -- Wait for ROM latency (2 cycles)
                        stage <= 2;
                    
                    when 2 =>
                        -- Latch full instruction
                        instruction_out <= douta;
                        stage <= 0;
                    
                    when others =>
                        stage <= 0;
                end case;
            end if;
        end if;
    end process;
    
    -- PC enable signal
    pc_enable <= '1' when stage = 0 else '0';
    
end Behavioral;