-- dmaengine.vhd
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY dmaengine is
    PORT (
        clk     : IN    STD_LOGIC ;
        reset_l : IN    STD_LOGIC ;
        d       : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)  ;
        address : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)  ;
      --read    : INOUT STD_LOGIC ;
        write   : INOUT STD_LOGIC ;
        request : OUT   STD_LOGIC ;
        grant   : IN    STD_LOGIC ;
        done    : INOUT STD_LOGIC ;
        vauxn4  : IN    STD_LOGIC ;
        vauxp4  : IN    STD_LOGIC ;
        vauxn12 : IN    STD_LOGIC ; -- Not used in single-channel mode
        vauxp12 : IN    STD_LOGIC   -- Not used in single-channel mode
    );    
END dmaengine;

ARCHITECTURE behavioral OF dmaengine IS
 -- MAKE AN INSTANCE OF myxadc 
 
   COMPONENT myxadc
    Port (
        clk     : IN  STD_LOGIC;
        reset_l : IN  STD_LOGIC;
        data    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        next_h  : OUT STD_LOGIC;
        vauxn4  : IN  STD_LOGIC;
        vauxp4  : IN  STD_LOGIC;
        vauxn12 : IN  STD_LOGIC;
        vauxp12 : IN  STD_LOGIC
    );
   END COMPONENT ;

   SIGNAL data                : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
   SIGNAL next_h              : STD_LOGIC ;

   SIGNAL start_address       : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL internal_address    : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL length              : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL word_count          : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL go                  : STD_LOGIC ;
   SIGNAL end_l               : STD_LOGIC ;
   SIGNAL oe                  : STD_LOGIC ;
   SIGNAL inc                 : STD_LOGIC ;
   SIGNAL dec                 : STD_LOGIC ;
   SIGNAL write_en            : STD_LOGIC ;
   SIGNAL ld                  : STD_LOGIC ;

   TYPE states IS (s0, s1, s2, s3);
   SIGNAL state: states := s0;
   SIGNAL nxt_state : states := s0;
    
BEGIN

   myxadc_inst : myxadc
   PORT MAP (
       clk     => clk,
       reset_l => reset_l,
       data    => data,
       next_h  => next_h,
       vauxn4  => vauxn4,
       vauxp4  => vauxp4,
       vauxn12 => vauxn12,
       vauxp12 => vauxp12
   );
   
   end_l <= '0' WHEN word_count = "00000000000000000000000000000000" ELSE '1' ;
   write <= '1' WHEN write_en = '1' ELSE 'Z' ;
   
   address <= internal_address WHEN oe = '1' ELSE (OTHERS => 'Z') ;
   d       <= ("000000000000000000000000" & data) WHEN oe = '1' ELSE (OTHERS => 'Z') ;


    --- statment to define the output values
   request  <= '1' WHEN (state = s1) OR (state = s2) ELSE '0' ;
   write_en <= '1' WHEN (state = s2) ELSE '0' ;
   oe       <= '1' WHEN (state = s2) ELSE '0' ;
   inc      <= '1' WHEN (state = s2) AND done = '1' ELSE '0' ;
   dec      <= '1' WHEN (state = s2) AND done = '1' ELSE '0' ;
   ld       <= '1' WHEN (state = s3) AND end_l = '0' ELSE '0' ;

    
    -- DMA Engine Go Bit Register: FFFF FFB0H
    -- DMA Engine Length Register: FFFF FFB8H
    -- DMA Engine Starting Address Register: FFFF FFBCH

   done <= '1' WHEN (address(31 DOWNTO 2) = "111111111111111111111111101100" AND write = '1') OR -- FFFF FFB0H
                    (address(31 DOWNTO 2) = "111111111111111111111111101110" AND write = '1') OR -- FFFF FFB8H
                    (address(31 DOWNTO 2) = "111111111111111111111111101111" AND write = '1')    -- FFFF FFBCH
               ELSE 'Z' ;  
                  
   ------------******** CHANGED TO NEW ADDRESSES ********------------
    
    ------------ Starting address is mapped to FFFF FFBCH ------------
    startprocess:PROCESS(clk)
    begin
       IF (clk = '1' AND clk'EVENT) THEN
          IF (reset_l = '0') THEN
             start_address <= (OTHERS => '0') ;
          ELSIF (address(31 DOWNTO 2) = "111111111111111111111111101111" AND write = '1') THEN
             start_address <= d(31 DOWNTO 0) ;
          END IF;
       END IF;
    END PROCESS startprocess ;
    
    ------------ Length is mapped to address FFFF FFB8H ------------
    lengthprocess:PROCESS(clk)
    begin
       IF (clk = '1' AND clk'EVENT) THEN
          IF (reset_l = '0') THEN
             length <= (OTHERS => '0') ;
          ELSIF (address(31 DOWNTO 2) = "111111111111111111111111101110" AND write = '1') THEN
             length <= d(31 DOWNTO 0) ;
          END IF;
       END IF;
    END PROCESS lengthprocess ;
    
    ------------ Go is mapped to address FFFF FFB0H ------------
    goprocess:PROCESS(clk)
    begin
       IF (clk = '1' AND clk'EVENT) THEN
          IF (reset_l = '0') THEN
             go <= '0' ;
          ELSIF (address(31 DOWNTO 2) = "111111111111111111111111101100" AND write = '1') THEN
             go <= d(0) ;
          END IF;
       END IF;
    END PROCESS goprocess ;
    
   ------------*******************************************------------

   addresscounter:PROCESS(clk)
   begin
      IF (clk = '1' AND clk'EVENT) THEN
         IF (go = '0' OR ld = '1') THEN
            internal_address <= start_address ;
         ELSIF (inc = '1') THEN
            internal_address <= internal_address + 4 ;
         END IF;
      END IF;
   END PROCESS addresscounter ;


   xfercounter:PROCESS(clk)
   begin
      IF (clk = '1' AND clk'EVENT) THEN
         IF (go = '0' OR ld = '1') THEN
            word_count <= length ;
         ELSIF (dec = '1') THEN
            word_count <= word_count - 1 ;
         END IF;
      END IF;
   END PROCESS xfercounter ;


-- process to implement the state register

   clkd: PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk='1') THEN
         IF (reset_l = '0') THEN
            state <= s0;
         ELSE
            state <= nxt_state;
         END IF;
      END IF;
    END PROCESS clkd;

-- process to determine next state

   state_trans: PROCESS (go, grant, done, end_l, next_h, state) --- end_l is listed but not used
   BEGIN
      nxt_state <= state ; 
      CASE state IS
         WHEN s0 => IF (go = '1' AND next_h = '1') THEN
                       nxt_state <= s1;
                    END IF ; 
         WHEN s1 => IF (grant = '1') THEN
                       nxt_state <= s2;
                    END IF ;
         WHEN s2 => IF (done = '1') THEN
                       nxt_state <= s3;
                    END IF ; 
         WHEN s3 => nxt_state <= s0;
         END CASE;
   END PROCESS state_trans;



END behavioral ;

