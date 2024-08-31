-- using LTC2640ITS8-LZ12
-- system clock is 48 MHZ
-- we don't need a receiver, just a transmitter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI is
    PORT (
        clk     : IN STD_LOGIC ;
        reset_l : IN STD_LOGIC ;
        sclk    : OUT STD_LOGIC;
        mosi    : OUT STD_LOGIC;
        ---miso : IN STD_LOGIC;
        cs_l    : OUT STD_LOGIC;
        d       : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        a       : IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;
        ce      : IN STD_LOGIC ;
        oe      : IN STD_LOGIC ;
        we      : IN STD_LOGIC
        ) ;
end SPI;

architecture Behavioral of SPI is
    signal tx_counter  : UNSIGNED(12 DOWNTO 0)         := (others => '0');
    signal tx_busy     : STD_LOGIC                     := '0';
    signal tx_data_sav : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others => '0');
    signal tx_start    : STD_LOGIC                     := '0';
begin
    -- Transmit start and data loading    
    d <= "0000000000000000000000000000000" & tx_busy when (a = "00" and oe = '1' and ce = '1') else (others => 'Z');
    tx_start <= '1' when (a = "01" and ce = '1' and we = '1') else '0';
    --tx_data_sav <= d(23 downto 0);

    -- SPI Transmitter
    trans_counter: PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset_l = '0' THEN
                tx_counter <= (others => '0');
                tx_busy    <= '0';
                mosi       <= '0';
                sclk       <= '0';
                cs_l       <= '1';
                tx_data_sav <= (others => '0');
            
            ELSIF tx_busy = '0' THEN
                sclk       <= '0';
                --cs_l       <= '1';
                IF tx_start = '1' THEN
                    tx_busy    <= '1';
                    tx_counter <= (others => '0');
                    cs_l       <= '0';  -- Assert chip select
                    tx_data_sav <= d(23 DOWNTO 0);
                END IF;

            ElSIF tx_counter >= 110 THEN
                cs_l       <= '1';  -- Deassert chip select
                tx_counter <= (others => '0');
                tx_busy    <= '0';
                
            ELSE
                tx_counter <= tx_counter + 1;
                
                IF tx_counter < 96 THEN
                    IF tx_counter(1 downto 0) = "00" THEN  -- SCLK low
                        sclk <= '0';
                    ELSIF tx_counter(1 downto 0) = "10" THEN  -- SCLK high
                        sclk <= '1';
                    END IF;
                ELSE
                    sclk <= '0';
                END IF;
                
                -- Shift out MOSI data with setup and hold time
                IF tx_counter(1 downto 0) = "01" THEN  -- MOSI data setup
                    CASE tx_counter(6 downto 2) IS
                        WHEN "00000" => mosi <= tx_data_sav(23);  -- Bit 23 C <- MSB
                        WHEN "00001" => mosi <= tx_data_sav(22);  -- Bit 22 C
                        WHEN "00010" => mosi <= tx_data_sav(21);  -- Bit 21 C
                        WHEN "00011" => mosi <= tx_data_sav(20);  -- Bit 20 C
                        WHEN "00100" => mosi <= tx_data_sav(19);  -- Bit 19 X
                        WHEN "00101" => mosi <= tx_data_sav(18);  -- Bit 18 X
                        WHEN "00110" => mosi <= tx_data_sav(17);  -- Bit 17 X
                        WHEN "00111" => mosi <= tx_data_sav(16);  -- Bit 16 X
                        WHEN "01000" => mosi <= tx_data_sav(15);  -- Bit 15 D11
                        WHEN "01001" => mosi <= tx_data_sav(14);  -- Bit 14 D10
                        WHEN "01010" => mosi <= tx_data_sav(13);  -- Bit 13 D9
                        WHEN "01011" => mosi <= tx_data_sav(12);  -- Bit 12 D8
                        WHEN "01100" => mosi <= tx_data_sav(11);  -- Bit 11 D7
                        WHEN "01101" => mosi <= tx_data_sav(10);  -- Bit 10 D6
                        WHEN "01110" => mosi <= tx_data_sav(9);   -- Bit 9  D5
                        WHEN "01111" => mosi <= tx_data_sav(8);   -- Bit 8  D4
                        WHEN "10000" => mosi <= tx_data_sav(7);   -- Bit 7  D3
                        WHEN "10001" => mosi <= tx_data_sav(6);   -- Bit 6  D2
                        WHEN "10010" => mosi <= tx_data_sav(5);   -- Bit 5  D1
                        WHEN "10011" => mosi <= tx_data_sav(4);   -- Bit 4  D0
                        WHEN "10100" => mosi <= tx_data_sav(3);   -- Bit 3  X
                        WHEN "10101" => mosi <= tx_data_sav(2);   -- Bit 2  X
                        WHEN "10110" => mosi <= tx_data_sav(1);   -- Bit 1  X
                        WHEN "10111" => mosi <= tx_data_sav(0);   -- Bit 0  X <- LSB
                        WHEN OTHERS => NULL; -- do nothing
                    END CASE;
                END IF;
                            
            END IF;
        END IF;
    END PROCESS;
    
    
end Behavioral;


