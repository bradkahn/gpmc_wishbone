----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:12:15 06/23/2016 
-- Design Name: 
-- Module Name:    counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
port	(
		-- WISHBONE SLAVE interface:
		ACK_O:	out std_logic;
		CLK_I:	in std_logic;
		DAT_I:	in std_logic_vector(7 downto 0);
		DAT_O:	out std_logic_vector(7 downto 0);
		RST_I:	in	std_logic;
		STB_I:	in std_logic;
		WE_I:		in std_logic;
		
		-- OUTPUT PORT (non-WISHBONE signals)
		PRT_O:	out std_logic_vector( 7 downto 0)
		);
end counter;

architecture Behavioral of counter is
signal count : unsigned ( 7 downto 0 ) := "00000000";
begin

	process ( CLK_I )
	begin
		if ( rising_edge( CLK_I ) ) then
			-- synchronous reset
			if ( RST_I = '1' ) then
				count <= "00000000";
			-- load counter
			elsif ( ( STB_I and WE_I ) = '1' ) then
				count <= unsigned ( DAT_I( 7 downto 0 ) );
			-- increment counter
			else
				count <= count + "00000001";
			end if;
		end if;
	end process;
	
	ACK_O <= STB_I;
	DAT_O <= std_logic_vector ( count );
	PRT_O <= std_logic_vector ( count );

end Behavioral;

