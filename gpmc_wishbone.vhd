----------------------------------------------------------------------------------
-- Company:			University of Cape Town
-- Engineer:		Bradley Kahn
-- 
-- Create Date:	15:20:07 06/22/2016 
-- Design Name: 
-- Module Name:	gpmc_wishbone - Behavioral 
-- Project Name:	gpmc_wishbone
-- Target Devices:RHINO (SPARTAN 6)
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity gpmc_wishbone is
	port (
		-- GPMC PORTS
		gpmc_a:			in std_logic_vector(10 downto 1);
		gpmc_d:			inout std_logic_vector(15 downto 0);
		gpmc_clk_i:		in std_logic;
		gpmc_n_cs:		in std_logic_vector(6 downto 0);
		gpmc_n_we:		in std_logic;
		gpmc_n_oe:		in std_logic;
		gpmc_n_adv_ale:in std_logic;
		gpmc_n_wp:		in std_logic;
		gpmc_clk:		out std_logic; -- feeds SYSCON
		
		wb_rst:			out std_logic; -- feeds SYSCON
		
		-- WISHBONE MASTER INTERFACE PORTS
		ACK_I:  in  std_logic;
--		ADR_O:  out std_logic_vector( 4  downto 0 );
		CLK_I:  in  std_logic;
		CYC_O:  out std_logic;
		DAT_I:  in  std_logic_vector( 31 downto 0 );
		DAT_O:  out std_logic_vector( 31 downto 0 );
		RST_I:  in  std_logic;
--		SEL_O:  out std_logic;
		STB_O:  out std_logic;
		WE_O:   out std_logic
	);
end gpmc_wishbone;

architecture Behavioral of gpmc_wishbone is

------------------------------------------------------------------------------------
-- Declare types
------------------------------------------------------------------------------------
  type ram_type is array (31 downto 0) of std_logic_vector(15 downto 0);   -- 32 X 16 memory block

------------------------------------------------------------------------------------
-- Declare signals
------------------------------------------------------------------------------------

	-- Define signals for the gpmc bus
	signal gpmc_clk_i_b	: std_logic;  --buffered  gpmc_clk_i
	signal gpmc_address	: std_logic_vector(25 downto 0):=(others => '0');         -- Full de-multiplexed address bus (ref. 16 bits)
	signal gpmc_data_o	: std_logic_vector(15 downto 0):="0000000000000000";      -- Register for output bus value
	signal gpmc_data_i	: std_logic_vector(15 downto 0):="0000000000000000";      -- Register for input bus value

	-- Other signals
	signal heartbeat : std_logic;
	signal dcm_locked: std_logic;
	signal rd_cs_en  : std_logic:='0';
	signal we_cs_en  : std_logic:='0';

	-- Debug signals
	signal reg_count  : std_logic_vector(15 downto 0) := "0000000000000000";

	ALIAS reg_bank_address	: std_logic_vector(3 downto 0) IS gpmc_address(25 downto 22);
	-- Currently each register is 64 x 16
	ALIAS reg_file_address : std_logic_vector(5 downto 0) IS gpmc_address(5 downto 0);

begin

------------------------------------------------------------------------------------
-- Instantiate input buffer for FPGA_PROC_BUS_CLK
------------------------------------------------------------------------------------

IBUFG_gpmc_clk_i : IBUFG
generic map
(
    IBUF_LOW_PWR => FALSE,
    IOSTANDARD => "DEFAULT"
)
port map
(
    I => gpmc_clk_i,
    O => gpmc_clk_i_b
);

gpmc_clk <= gpmc_clk_i_b;

-----------------------------------------------------------------------------------
-- Register File: Read
------------------------------------------------------------------------------------

-- SYM FILE REGISTERS
-- 0	count	3	0x08000000	0x02

process (gpmc_clk_i_b,gpmc_n_cs,gpmc_n_oe,gpmc_n_we,gpmc_n_adv_ale,gpmc_d,gpmc_a)
begin
  if (gpmc_n_cs /= "1111111")  then             -- CS 1
    if gpmc_clk_i_b'event and gpmc_clk_i_b = '1' then
		--First cycle of the bus transaction record the address
  		if (gpmc_n_adv_ale = '0') then
  			 gpmc_address <= gpmc_a & gpmc_d;   -- Address of 16 bit word

  		--Second cycle of the bus is read or write
  		--Check for read
  		elsif (gpmc_n_oe = '0') then
  			case to_integer(unsigned(reg_bank_address)) is
  				when 0 => gpmc_data_o <= reg_count;
  				when others => gpmc_data_o <= (others => '0');
  			end case;
  		--Check for write
  		elsif (gpmc_n_we = '0') then
  			case to_integer(unsigned(reg_bank_address)) is
  				when 0 => reg_count  <= gpmc_data_i;
  				when others => null;
  			end case;
  		end if;
     end if;
   end if;
end process;

------------------------------------------------------------------------------------
-- Manage the tri-state bus
---------------------------------------------------------------------------------
gpmc_d <= gpmc_data_o when (gpmc_n_oe = '0') else (others => 'Z');
gpmc_data_i <= gpmc_d;

end Behavioral;

