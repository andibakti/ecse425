library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is

component cache is
generic(
    ram_size : INTEGER := 32768
);
port(
    clock : in std_logic;
    reset : in std_logic;

    -- Avalon interface --
    s_addr : in std_logic_vector (31 downto 0);
    s_read : in std_logic;
    s_readdata : out std_logic_vector (31 downto 0);
    s_write : in std_logic;
    s_writedata : in std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic; 

    m_addr : out integer range 0 to ram_size-1;
    m_read : out std_logic;
    m_readdata : in std_logic_vector (7 downto 0);
    m_write : out std_logic;
    m_writedata : out std_logic_vector (7 downto 0);
    m_waitrequest : in std_logic
);
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
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

-- begin by setting up
reset <= '1'; 
WAIT FOR 1 * clk_period;
reset <= '0';
s_read <='0';
s_write <='0';
WAIT FOR 1 * clk_period;

-- 32 bit adresses, so follow the x"0000 0000" format


-- 1   0   0   0
REPORT "First read, invalid, clean, miss";
s_read <='1'; --read to ensure write was successful
s_addr <= X"00F00000";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 
--WE ARE ASSUMING MEMORY IS INITIALIZED TO FFFFFFFF
ASSERT ( s_readdata = X"FFFFFFFF") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00F00004"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"FFFFFFFF") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00F00008";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"FFFFFFFF") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00F0000C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"FFFFFFFF") REPORT "Write unsuccessful" SEVERITY ERROR;
s_read <='0';



-- 0   0   0   0
REPORT "First write, invalid, clean, miss"; --write an entire word to the cache
s_write <='1';
s_writedata <= X"00000001"; --the x means hexadecimal value of "01"
s_addr <= X"00001000"; 
WAIT UNTIL falling_edge(s_waitrequest); -- wait until request = 0
WAIT FOR 1 * clk_period; --on next clock cycle

s_writedata <= X"00000002"; 
s_addr <= X"00001004";
WAIT UNTIL falling_edge(s_waitrequest); -- wait until request = 0
WAIT FOR 1 * clk_period; --on next clock cycle

s_writedata <= X"00000003";
s_addr <= X"00001008"; 
WAIT UNTIL falling_edge(s_waitrequest); -- wait until request = 0
WAIT FOR 1 * clk_period; --on next clock cycle

s_writedata <= X"00000004";
s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest); -- wait until request = 0
WAIT FOR 1 * clk_period; --on next clock cycle
s_write <='0';


-- 1   1   0   1
REPORT "Read what was written, valid, clean, hit ";
s_read <='1'; --read to ensure write was successful
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000001") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001004"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000002") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000003") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000004") REPORT "Write unsuccessful" SEVERITY ERROR;
s_read <='0';




-- 0   1   1   0
REPORT "Write to same cache location but different tag: valid, dirty, miss";
s_write <='1';
s_writedata <= X"00000011"; 
s_addr <= X"00002000"; --TO DO FIGURE OUT THE CORRECT ADDRESS WITH SAME OFFSET AND INDEX BUT DIFFERENT TAG
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

s_writedata <= X"00000012"; 
s_addr <= X"00002004";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

s_writedata <= X"00000013";
s_addr <= X"00002008"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

s_writedata <= X"00000014";
s_addr <= X"0000200C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 
s_write <='0';


-- 1   1   1   1
REPORT "Read what was written, valid, dirty, hit";
s_read <='1'; --read to ensure write was successful
s_addr <= X"00002000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000011") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00002004"; 
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000012") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00002008";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000013") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000200C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000014") REPORT "Write unsuccessful" SEVERITY ERROR;
s_read <='0';



-- 1   1   0   0
REPORT "Read from memory, triggers block replacement, valid, clean, miss"; --the reading itself is clean, but the block being replaced is dirty
s_read <='1';
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000001") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001004"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000002") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000003") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"00000004") REPORT "Write unsuccessful" SEVERITY ERROR;
s_read <='0';


-- 0   1   0   1
REPORT "Write to what is in the cache already, valid, clean, hit"; --block was clean, but writing to makes it dirty
s_write <='1';
s_writedata <= X"0000004A";
s_addr <= X"00001000"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

s_writedata <= X"0000004B"; 
s_addr <= X"00001004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period; 

s_writedata <= X"0000004C";
s_addr <= X"00001008"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

s_writedata <= X"0000004D";
s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 
s_write <='0';

-- 1   1   1   1
REPORT "Read what was written, valid, dirty, hit"; --the block we are reading is dirty
s_read <='1';
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"0000004A") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001004"; 
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"0000004B") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"0000004C") REPORT "Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest); 
WAIT FOR 1 * clk_period; 

ASSERT ( s_readdata = X"0000004D") REPORT "Write unsuccessful" SEVERITY ERROR;
s_read <='0';





-- test all possible cases of the cache fsm

-- the binary comments correspond to the cases:
-- read/write - valid/notvalid - dirty/not dirty - tag equal/tagnotequal



-- 0   0   0   0 DONE
REPORT "Testing for write, not valid, not dirty, tag not equal";

-- 0   0   0   1
REPORT "Testing for write, not valid, not dirty, tag equal";


-- 0   0   1   0
--Not testing for write, not valid, dirty, tag not equal because impossible


-- 0   0   1   1
--Not testing for write, not valid, dirty, tag equal because impossible

-- 0   1   0   0 
REPORT "Testing for write, valid, not dirty, tag not equal";


-- 0   1   0   1 DONE
REPORT "Testing for write, valid, not dirty, tag equal";


-- 0   1   1   0 DONE
REPORT "Testing for write, valid, dirty, tag not equal";


-- 0   1   1   1
REPORT "Testing for write, valid, dirty, tag equal";






--------------------------------------------------------------------------------------------------------------------

-- 1   0   0   0 DONE
REPORT "Testing for read, not valid, not dirty, tag not equal";


-- 1   0   0   1 
REPORT "Testing for read, not valid, not dirty, tag equal";


-- 1   0   1   0
--Not testing for read, not valid, dirty, tag not equal because impossible

-- 1   0   1   1
--Not testing for read, not valid, dirty, tag equal because impossible


-- 1   1   0   0 DONE
REPORT "Testing for read, valid, not dirty, tag not equal";


-- 1   1   0   1 DONE
REPORT "Testing for read, valid, not dirty, tag equal";


-- 1   1   1   0 
REPORT "Testing for read, valid, dirty, tag not equal";


-- 1   1   1   1 DONE
REPORT "Testing for read, valid, dirty, tag equal";




--------------------------------------------------------------------------------------------------------------------


--check if reset works
REPORT "Testing for reset";

	
end process;
	
end;