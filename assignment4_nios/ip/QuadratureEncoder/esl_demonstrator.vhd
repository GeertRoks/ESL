library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity esl_demonstrator is
	generic( DATA_WIDTH : integer := 32);
	port (
	-- CLOCK
	csi_clk	: in std_logic;
	rsi_reset_n : in std_logic;
	-- LEDs are only available on the DE0 Nano board.
	coe_LED		: out std_logic_vector(7 downto 0);
	coe_KEY		: in std_logic_vector(1 downto 0);
	coe_SW			: in std_logic_vector(3 downto 0);

	-- GPIO_0, GPIO_0 connect to GPIO Default
	coe_GPIO_0		: inout std_logic_vector(33 downto 0);
	coe_GPIO_0_IN	: in    std_logic_vector(1 downto 0);

	-- GPIO_1, GPIO_1 connect to GPIO Default
	coe_GPIO_1		: inout std_logic_vector(33 downto 0);
	coe_GPIO_1_IN	: in    std_logic_vector(1 downto 0);
	
	-- signals to connect to an Avalon-MM slave interface
	avs_s1_address          : in  std_logic_vector(7 downto 0);
	avs_s1_read             : in  std_logic;
	avs_s1_write            : in  std_logic;
	avs_s1_readdata         : out std_logic_vector(DATA_WIDTH-1 downto 0);
	avs_s1_writedata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
	avs_s1_byteenable       : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0)
	);
end entity;


architecture behavior of esl_demonstrator is
	constant POSITION_WIDTH: integer := 7;
	signal mem             : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_pos_mask    : std_logic_vector(POSITION_WIDTH-1 downto 0);
	signal mem_dir_mask    : std_logic;

begin
	encoder : entity work.QuadratureEncoder
		generic map ( POSITION_WIDTH => POSITION_WIDTH )
		port map (
			-- Map your encoder here to the I/O
			clk => csi_clk,
			reset => coe_SW(0),
			a => coe_KEY(0), --assignment 4
			b => coe_KEY(1), --assignment 4
			--a => GPIO_0(20), --assignment 5 (ENC0) header 25
			--b => GPIO_0(22), --assignment 5 (ENC0) header 27
			--a => GPIO_0(21), --assignment 5 (ENC1) header 26
			--b => GPIO_0(23), --assignment 5 (ENC1) header 28
			--direction => coe_LED(POSITION_WIDTH), -- send direction directly to the LED via a conduit
			--position => coe_LED(POSITION_WIDTH-1 DOWNTO 0) -- send position to the LEDs via a conduit
			direction => mem_dir_mask,
			position => mem_pos_mask
		);
		
	--pwm : entity work.PulseWidthModulator
		--port map (
			-- Map your pulse width modulator here to the I/O
		--);
	
	-- Communication with the bus
	p_avalon : process(csi_clk, rsi_reset_n)
	begin
		if (rsi_reset_n = '0') then
			mem <= (others => '0');
			mem_pos_mask <= (others => '0');
			mem_dir_mask <= '0';
		elsif (rising_edge(csi_clk)) then

			-- Send data to the bus
			if (avs_s1_read = '1') then
				mem(0) <= mem_dir_mask;
				mem(POSITION_WIDTH downto 1) <= mem_pos_mask;
				--mem <= X"000000" & mem_dir_mask & mem_pos_mask;
				avs_s1_readdata <= mem;
			end if;
			
			-- Read data of the bus
			if (avs_s1_write = '1') then
				mem <= avs_s1_writedata;
			end if;
		end if;
	end process;
end architecture;
