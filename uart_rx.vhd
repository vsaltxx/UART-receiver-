-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Veranika Saltanava (xsalta01)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is

signal cnt_clks     : std_logic_vector(4 downto 0) := "00000";
signal cnt_bit      : std_logic_vector(3 downto 0) := "0000";
signal cnt_clks_en  : std_logic;
signal read_en      : std_logic; -- receive enable
signal do_vld       : std_logic;

begin

	FSM: entity work.UART_RX_FSM
	port map (
        CLK             => CLK, 
        RST             => RST,
        DIN             => DIN,
        CNT_CLKS        => cnt_clks,            -- counter of clk signals
        READ_EN         => read_en,             -- reading data is enable
        CNT_BIT         => cnt_bit,             -- counter of received bits
        CNT_CLKS_EN     => cnt_clks_en,         -- counter enable
        DOUT_VLD        => do_vld
    );
			 
	clk_cycles : process (CLK)
	begin
		if rising_edge(CLK) then
			if cnt_clks_en = '1' then
				cnt_clks <= cnt_clks + 1;
				
				if read_en = '1' and (cnt_clks(3 downto 0) = "1111" or cnt_clks(4) = '1') then
					cnt_bit <= cnt_bit + 1;
					cnt_clks <= "00000";
				end if;
			else
				cnt_clks <= "00000";
				if do_vld = '0' then
					cnt_bit <= "0000";
				end if;
            end if;
		end if; -- CLK rising edge
	end process clk_cycles;
	
	write_out : process (CLK)
	begin
		if rising_edge(CLK) then
			if read_en = '1' and (cnt_clks(3 downto 0) = "1111" or cnt_clks(4) = '1') then
					case cnt_bit(2 downto 0) is
						when "000" => DOUT(0) <= DIN;
						when "001" => DOUT(1) <= DIN;
						when "010" => DOUT(2) <= DIN;
						when "011" => DOUT(3) <= DIN;
						when "100" => DOUT(4) <= DIN;
						when "101" => DOUT(5) <= DIN;
						when "110" => DOUT(6) <= DIN;
						when "111" => DOUT(7) <= DIN;
						
						when others => null;
					
					end case;
			end if;
		end if; -- CLK rising edge
	end process write_out;

	valid : process (do_vld)
	begin
		DOUT_VLD <= do_vld;
	end process;
	
end architecture;


