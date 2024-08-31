library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY myxadc is
    PORT (
        clk       : IN  STD_LOGIC;
        reset_l   : IN  STD_LOGIC;
        data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --(15 DOWNTO 0); -- changed to 16  bits
        next_h    : OUT STD_LOGIC;
        vauxn4    : IN  STD_LOGIC;
        vauxp4    : IN  STD_LOGIC;
        vauxn12   : IN  STD_LOGIC;
        vauxp12   : IN  STD_LOGIC --;
       -- channel   : IN  STD_LOGIC_VECTOR (4 DOWNTO 0) -- added to select the channel for sampling
    );
END myxadc;

architecture Behavioral of myxadc is
    COMPONENT xadc_wiz_0
        PORT 
           (
            daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
            den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
            di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
            dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
            do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
            drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
            dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
            reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
            vauxp4          : in  STD_LOGIC;                         -- Auxiliary Channel 4
            vauxn4          : in  STD_LOGIC;
            vauxp12         : in  STD_LOGIC;                         -- Auxiliary Channel 12
            vauxn12         : in  STD_LOGIC;
            busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
            channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
            eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
            eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
            alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
            vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
            vn_in           : in  STD_LOGIC
        );
    END COMPONENT;

    --SIGNAL daddr            : STD_LOGIC_VECTOR(6 DOWNTO 0);
    --SIGNAL den              : STD_LOGIC;
    --SIGNAL di               : STD_LOGIC_VECTOR(15 DOWNTO 0);
    --SIGNAL dwe              : STD_LOGIC;
    SIGNAL do               : STD_LOGIC_VECTOR(15 DOWNTO 0);
    --SIGNAL drdy             : STD_LOGIC;
    SIGNAL eoc_out_den_in   : STD_LOGIC;
    SIGNAL reset_h          : STD_LOGIC;
    SIGNAL enable           : STD_LOGIC;

begin
    -- DADDR_IN is tied to "0010100" (VAUX4) or "0011100" (VAUX12)
    xadc_inst : xadc_wiz_0
        PORT MAP (
            daddr_in    => "0010100",
            den_in      => eoc_out_den_in,
            di_in       => (others => '0'),
            dwe_in      => '0',
            do_out      => do,
            drdy_out    => enable,
            dclk_in     => clk,
            reset_in    => reset_h,
            vp_in       => '0',
            vn_in       => '0',
            vauxp4      => vauxp4,
            vauxn4      => vauxn4,
            vauxp12     => vauxp12,
            vauxn12     => vauxn12,
            channel_out => open,
            eoc_out     => eoc_out_den_in,
            alarm_out   => open,
            eos_out     => open,
            busy_out    => open
        );
    
    -- unnecessary
--   syncprocess:PROCESS(src_clk)
--   BEGIN
--      IF (src_clk = '1' AND src_clk'event) THEN
--         reset_l_temp <= NOT(reset_h) ;
--         reset_l_sync <= reset_l_temp ;
--      END IF;
--   END PROCESS syncprocess ;
        
    reset_h <= NOT reset_l;
    next_h <= enable;
    
    
    
    process(clk)
    begin
        IF rising_edge(clk) THEN
            IF(enable = '1') THEN
                data   <= do(15 DOWNTO 8); --7 DOWNTO 0 is  discarded for now
            END IF;
        END IF;
    end process;

end Behavioral;