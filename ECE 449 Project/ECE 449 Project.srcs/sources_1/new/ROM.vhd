----------------------------------------------------------------------------------
-- Optimized ROM Fix: Ensures Proper Instruction Fetching
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    signal stage          : integer range 0 to 5 := 0; -- Extended to 5 stages
    signal instruction_reg : std_logic_vector(15 downto 0) := (others => '0'); -- Output register
    signal instruction_valid : std_logic := '0'; -- Validity flag

begin
    -- xpm_memory_sprom instantiation remains unchanged
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
                instruction_reg <= (others => '0');
            else
                case stage is
                    when 0 =>
                        -- Start fetch for first byte
                        pc_latched <= pc_addr(7 downto 0);
                        rom_addr <= pc_addr(7 downto 0);
                        stage <= 1;
    
                    when 1 =>
                        -- Wait for ROM latency (cycle 1)
                        stage <= 2;
                        
                    when 2 =>
                        -- Extra cycle to ensure data is stable
                        low_byte <= douta; -- Capture the stable low byte
                        rom_addr <= std_logic_vector(unsigned(pc_latched) + 1);
                        stage <= 3;
    
                    when 3 =>
                        -- Wait for ROM latency (cycle 1 for high byte)
                        stage <= 4;
                        
                    when 4 =>
                        -- Extra cycle to ensure data is stable
                        high_byte <= douta; -- Capture the stable high byte
                        stage <= 5;
                        
                    when 5 =>
                        -- Assemble full instruction with correct byte order
                        instruction_reg <= high_byte & low_byte;
                        stage <= 0;
    
                    when others =>
                        stage <= 0;
                end case;
            end if;
        end if;
    end process;

    -- Output assignments
    instruction_out <= instruction_reg; -- Output the registered value
    pc_enable <= '1' when stage = 0 else '0';
    sbiterra <= '0';
    dbiterra <= '0';

end Behavioral;
