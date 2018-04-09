library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proc_tb is
end proc_tb;

architecture behavior of proc_tb is

component proc is
port(
	clock, reset: in std_logic
);
end component;


-- test signals
signal reset : std_logic := '0';
signal clock : std_logic := '0';
constant clk_period : time := 1 ns;


begin

proc_instance: proc
port map(
	clock => clock,
	reset => reset
);


clk_process : process
begin
  clock <= '0';
  wait for clk_period/2;
  clock <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

---- begin by setting up the cache


	wait for 1 * clk_period;
	reset <= '1';
	wait for 1 * clk_period;
	reset <= '0';
	wait for 1 * clk_period/2;


	assert ( data_out = X"00000000") report "reset successfull" severity error;

	wait for 1 * clk_period;
	wait for 1 * clk_period;
	wait for 1 * clk_period;


--

--rst <= '0';


--report "#1 test 'add'"; -- because we already wrote to the block when writing the 1st word, then the block is now dirty, but has been brought in the cache, so hit
--a <= std_logic_vector( to_signed(40,32));
--b <= std_logic_vector( to_signed(29,32));
--sel <= "000000";
--funct <= "100000";
--wait for 1 * clk_period;

--assert ( output = std_logic_vector(to_signed(69,32))) report "1: 'add' successfull" severity error;


--report "done testing";
	wait;
end process;

end;
