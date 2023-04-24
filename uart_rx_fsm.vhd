-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Veranika Saltanava (xsalta01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX_FSM is
port(
    CLK         : in std_logic;
    RST         : in std_logic;
    DIN 	    : in std_logic;
    CNT_CLKS    : in std_logic_vector(4 downto 0);      -- vector for counting clock signals
    CNT_BIT     : in std_logic_vector(3 downto 0);      -- vector for counting received bits    
    READ_EN : out std_logic;			            -- flag, that we're reading data
    CNT_CLKS_EN : out std_logic;                        -- flag, that we're counting CLK signals
    DOUT_VLD    : out std_logic						    -- valid output
    );
end entity;

-------------------------------------------------
architecture behavioral of UART_RX_FSM is
-- all the states the FSM can take
type STATUS_TYPE is (WAIT_FOR_START, START_BIT, GET_DATA, STOP_BIT, DATA_VALID);
signal status : STATUS_TYPE := WAIT_FOR_START; 
begin

    READ_EN <= '1' when status = GET_DATA else '0';
	DOUT_VLD <= '1' when status = DATA_VALID else '0';
	CNT_CLKS_EN <= '1' when status = START_BIT or status = GET_DATA 
					or status = STOP_BIT else '0';
						
    process (CLK) begin

        if CLK'event AND CLK = '0' then
            if RST = '1' then
                status <= WAIT_FOR_START;
            else	
            
                case status is
                    when WAIT_FOR_START =>
                        if DIN = '0' then
                            status <= START_BIT;
                        end if;
                        
                    when START_BIT =>
                        if CNT_CLKS = "11000" then
                            status <= GET_DATA;
                        end if;
                        
                    when GET_DATA => 
                        if CNT_BIT = "1000" then
                            status <= STOP_BIT;
                        end if;
                        
                    when STOP_BIT =>
                        if CNT_CLKS = "11000" then
                            status <= DATA_VALID;
                        end if;
                        
                    when DATA_VALID =>
                        status <= WAIT_FOR_START;
                    
                    when others => null;
                end case;
            
            end if; -- RST signal
        end if; -- rising edge of CLK	
    end process;
end architecture;