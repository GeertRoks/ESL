library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity QuadratureEncoder is 
	generic(
		POSITION_WIDTH : integer
	);
	port (
		clk : in std_logic;
		a : in std_logic;
		b : in std_logic;
		reset : in std_logic; -- active low
		direction : out std_logic;
		position : out std_logic_vector(POSITION_WIDTH-1 DOWNTO 0) -- check range and whether it suffices
	);
end entity;

architecture behaviour of QuadratureEncoder is
	signal a_sreg : std_logic_vector(2 DOWNTO 0) := (OTHERS => '0'); -- Shift registers containing both the synchroniser and the history.
	signal b_sreg : std_logic_vector(2 DOWNTO 0) := (OTHERS => '0'); -- sreg(0) and sreg(1) are the synchorniser, sreg(2) is the previous value. So sreg(1) is the "current" value.
begin
	
	PROCESS(clk, reset)
		variable position_buffer : signed(POSITION_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
		variable direction_buffer : std_logic := '0';
		constant ticks : integer := 10;
	BEGIN

	IF (reset = '0') THEN
		position_buffer := (OTHERS => '0');
		direction_buffer := '0';
		-- reset registers
		a_sreg <= (OTHERS => '0');
		b_sreg <= (OTHERS => '0');
	ELSIF rising_edge(clk) THEN
		-- Synchroniser
		a_sreg <= std_logic_vector(shift_left(unsigned(a_sreg), 1));
		a_sreg(0) <= a;
		b_sreg <= std_logic_vector(shift_left(unsigned(b_sreg), 1));
		b_sreg(0) <= b;

		-- If a signal changes then update position and direction
		IF (((a_sreg(2) XOR a_sreg(1)) OR (b_sreg(2) XOR b_sreg(1))) = '1') THEN
			direction_buffer := a_sreg(1) XOR b_sreg(2);
			IF (direction_buffer = '0') THEN
				-- decrease poisition until min range: 0
				IF (position_buffer >= 1) THEN
					position_buffer := position_buffer - 1;
				END IF;
			ELSE
				-- increase position until max range: (2^POSITION_WIDTH) - 1
				IF (position_buffer <= (2**POSITION_WIDTH) -2) THEN
					position_buffer := position_buffer + 1;
				END IF;
			END IF;
		END IF;
		
		position <= std_logic_vector(position_buffer);
		direction <= direction_buffer;

	END IF;

	END PROCESS;
end behaviour;

