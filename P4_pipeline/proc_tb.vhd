library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proc_tb is
end proc_tb;

architecture behavior of proc_tb is

component proc is
port(
	clock, rst: in std_logic
);
end component;


-- test signals
signal rst : std_logic := '0';
signal clock : std_logic := '0';
constant clk_period : time := 1 ns;
signal a, b: std_logic_vector(31 downto 0);
signal signExtendImmediate: std_logic_vector(15 downto 0);
signal sel, funct: std_logic_vector(5 downto 0);
signal zero: std_logic;
signal output: std_logic_vector(31 downto 0);

--signal s_addr : std_logic_vector (31 downto 0);

begin

proc_instance: proc
port map(
	clock => clock,
	rst => rst
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
--rst <= '1';
--wait for 1 * clk_period;
--assert ( output = X"00000000") report "reset successfull" severity error;

--rst <= '0';
--wait for 1 * clk_period;


--report "#1 test 'add'"; -- because we already wrote to the block when writing the 1st word, then the block is now dirty, but has been brought in the cache, so hit
--a <= std_logic_vector( to_signed(40,32));
--b <= std_logic_vector( to_signed(29,32));
--sel <= "000000";
--funct <= "100000";
--wait for 1 * clk_period;

--assert ( output = std_logic_vector(to_signed(69,32))) report "1: 'add' successfull" severity error;


--report "done testing";
--wait;
end process;

end;
