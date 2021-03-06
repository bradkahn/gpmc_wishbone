----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:38:54 06/23/2016 
-- Design Name: 
-- Module Name:    intercon - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity intercon is
--ports:
--inputs: clks, gpmc
--outputs: LEDS, gpios?
end intercon;

architecture Behavioral of intercon is

	-- SYSCON INTERFACE
	COMPONENT syscon
	PORT(
		EXTCLK : IN std_logic;
		EXTTST : IN std_logic;          
		CLK_O : OUT std_logic;
		RST_O : OUT std_logic
		);
	END COMPONENT;

	-- SLAVE DEVICE
	COMPONENT counter
	PORT(
		CLK_I : IN std_logic;
		DAT_I : IN std_logic_vector(7 downto 0);
		RST_I : IN std_logic;
		STB_I : IN std_logic;
		WE_I : IN std_logic;          
		ACK_O : OUT std_logic;
		DAT_O : OUT std_logic_vector(7 downto 0);
		PRT_O : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	-- MASTER DEVICE
	COMPONENT gpmc_wishbone
	PORT(
		gpmc_a : IN std_logic_vector(10 downto 1);
		gpmc_clk_i : IN std_logic;
		gpmc_n_cs : IN std_logic_vector(6 downto 0);
		gpmc_n_we : IN std_logic;
		gpmc_n_oe : IN std_logic;
		gpmc_n_adv_ale : IN std_logic;
		gpmc_n_wp : IN std_logic;
		ACK_I : IN std_logic;
		CLK_I : IN std_logic;
		DAT_I : IN std_logic_vector(31 downto 0);
		RST_I : IN std_logic;    
		gpmc_d : INOUT std_logic_vector(15 downto 0);      
		gpmc_clk : OUT std_logic;
		wb_rst : OUT std_logic;
		CYC_O : OUT std_logic;
		DAT_O : OUT std_logic_vector(31 downto 0);
		STB_O : OUT std_logic;
		WE_O : OUT std_logic
		);
	END COMPONENT;
	
	
	 ------------------------------------------------------------------
	 -- Define internal signals.
	 ------------------------------------------------------------------
	signal  ACK:        std_logic;
--	signal  ADR:        std_logic_vector(  4 downto 0 );
	signal  CLK:        std_logic;
	signal  GPMC_CLK    std_logic;
	signal  GPMC_RST    std_logic;
	signal  DRD:        std_logic_vector( 31 downto 0 );
	signal  DWR:        std_logic_vector( 31 downto 0 );
	signal  RST:        std_logic;
	signal  STB:        std_logic;
	signal  WE:         std_logic;

begin

	Inst_syscon: syscon PORT MAP(
			CLK_O => CLK,
			RST_O => RST,
			EXTCLK => GPMC_CLK,
			EXTTST => GPMC_RST
		);
		
	Inst_counter: counter PORT MAP(
		ACK_O => ACK,
		CLK_I => CLK,
		DAT_I => DWD,
		DAT_O => DRD,
		RST_I => RST,
		STB_I => STB,
		WE_I => WE,
		PRT_O => -- to LEDS
	);
	
	Inst_gpmc_wishbone: gpmc_wishbone PORT MAP(
		gpmc_a => ,
		gpmc_d => ,
		gpmc_clk_i => ,
		gpmc_n_cs => ,
		gpmc_n_we => ,
		gpmc_n_oe => ,
		gpmc_n_adv_ale => ,
		gpmc_n_wp => ,
		gpmc_clk => GPMC_CLK,
		wb_rst => GPMC_RST,
		ACK_I => ACK,
		CLK_I => CLK,
		--CYC_O => '0',
		DAT_I => DRD,
		DAT_O => DWD,
		RST_I => RST,
		STB_O => STB,
		WE_O => WE
	);
end Behavioral;

