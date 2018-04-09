library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_memory is
end instr_memory;

architecture behavior of instr_memory is

component instr_memory is
port(
	clock: in std_logic;
	writedata: in std_logic_vector (31 downto 0);
	address: in std_logic_vector (31 downto 0);
	memwrite: in std_logic;
	memread: in std_logic;
	readdata: out std_logic_vector (31 downto 0);
	waitrequest: out std_logic
);
end component;


-- test signals
signal reset : std_logic := '0';
signal clock : std_logic := '0';
constant clk_period : time := 1 ns;
signal writedata: std_logic_vector (31 downto 0);
signal address: std_logic_vector (31 downto 0);
signal memwrite: std_logic;
signal memread: std_logic;
signal readdata:  std_logic_vector (31 downto 0);
signal waitrequest:  std_logic;

--signal s_addr : std_logic_vector (31 downto 0);

begin

instr_mem_instance: instr_memory
port map(
	clock => clock,
	writedata => writedata,
	address => address,
	memwrite => memwrite,
	memread => memread,
	readdata => readdata,
	waitrequest => waitrequest
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
	memread <= '1';
	address <= X"00000001";
	wait for 1 * clk_period;
	wait for 1 * clk_period;



	wait;

end process;

end;
