library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_alu_tb is
end ex_alu_tb;

architecture behavior of ex_alu_tb is

component alu is
port(
	clock : in std_logic;
	reset : in std_logic;
	a: in std_logic_vector(31 downto 0);
	b: in std_logic_vector(31 downto 0);
	signExtendImmediate: in std_logic_vector(31 downto 0);
	sel: in std_logic_vector(4 downto 0);
	zero: out std_logic;
	result: out std_logic_vector(31 downto 0)
);
end component;


-- test signals
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;
signal a: std_logic_vector(31 downto 0);
signal b: std_logic_vector(31 downto 0);
signal signExtendImmediate: std_logic_vector(31 downto 0);
signal sel: std_logic_vector(4 downto 0);
signal zero: std_logic;
signal result: std_logic_vector(31 downto 0);

--signal s_addr : std_logic_vector (31 downto 0);

begin

alu_instance: alu
port map(
	clock => clk,
	reset => reset,
	a => a,
	b => b,
	signExtendImmediate => signExtendImmediate,
	sel => sel,
	zero => zero,
	result => result
);


clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

-- begin by setting up the cache
reset <= '1';
wait for 1 * clk_period;
assert ( result = X"00000000") report "reset successfull" severity error;

reset <= '0';
wait for 1 * clk_period;


report "#1 test 'add'"; -- because we already wrote to the block when writing the 1st word, then the block is now dirty, but has been brought in the cache, so hit
a <= std_logic_vector( to_signed(40,32));
b <= std_logic_vector( to_signed(29,32));
sel <= "00000";
wait for 1 * clk_period;

assert ( result = std_logic_vector(to_signed(69,32))) report "1: 'add' successfull" severity error;





report "done testing";
wait;
end process;

end;
