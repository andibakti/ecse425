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
signal m_waitrequest : std_logic:= '0';

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

-- begin by setting up the cache
reset <= '1';
WAIT FOR 1 * clk_period;
reset <= '0';
s_read <='0';
s_write <='0';
WAIT FOR 1 * clk_period;

-- 32 bit adresses, so follow the x"0000 0000" format


-- 0   0   0   0
-- TEST 1: write an entire block to the cache
REPORT "#1 First write, invalid, clean, miss"; --1st access will be a miss, clean since from memory, invalid because no valid data is stored yet
s_write <='1';
s_writedata <= X"00000001"; --the x means hexadecimal value
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest); -- wait until request = 0
WAIT FOR 1 * clk_period; --on next clock cycle

-- 0   1   1   1
REPORT "#1 Continue write to same block, valid, dirty, hit"; -- because we already wrote to the block when writing the 1st word, then the block is now dirty, but has been brought in the cache, so hit
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


-- 1   1   1   1
-- TEST 2: read the same block
REPORT "#2 Read what was written, valid, dirty, hit "; --dirty because has been written to, hit bc is in cache, and data valid from the write
s_read <='1'; --read to ensure write was successful
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000001") REPORT "1: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000002") REPORT "2: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000003") REPORT "3: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000004") REPORT "4: Write unsuccessful" SEVERITY ERROR;
s_read <='0';


-- 0   0   1   0
-- TEST 3: Writing to same block, but different tag. Forces the data from Test #1 to be written back to the memory
REPORT "#3 Write to same cache location but different tag: invalid, dirty, miss"; --the previous block is dirty
s_write <='1';
s_writedata <= X"00000011";
s_addr <= X"00000808"; 
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

-- 0   1   1   1
REPORT "#3 Continue writing from same block, so now: valid, dirty, hit";
s_writedata <= X"00000012";
s_addr <= X"00000804";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

s_writedata <= X"00000013";
s_addr <= X"00000808";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

s_writedata <= X"00000014";
s_addr <= X"0000080C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;
s_write <='0';
-- now since this one has been swapped with the previous block, remember to check if it was succesfully written back

-- 1   1   1   1
-- TEST 4: Read data from test 5 to check if write was succesful
REPORT "#4 Read what was written, valid, dirty, hit";
s_read <='1'; 
s_addr <= X"00000808";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000011") REPORT "5: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00000804";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000012") REPORT "6: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00000808";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000013") REPORT "7: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000080C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000014") REPORT "8: Write unsuccessful" SEVERITY ERROR;
s_read <='0';


-- 1   1   1   0
-- TEST 5: read data from test 2, which triggers yet another block replacement
REPORT "#5 Read from memory what we replaced from test 2, valid, dirty, miss"; -- valid and dirty because the previous block is dirty
s_read <='1';
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000001") REPORT "9: Write back unsuccessful" SEVERITY ERROR;

-- 1   1   0   1
REPORT "#5 Continue reading words from same block, valid, clean, hit";
s_addr <= X"00001004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000002") REPORT "10: Write back unsuccessful" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000003") REPORT "11: Write back unsuccessful" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000004") REPORT "12: Write back unsuccessful" SEVERITY ERROR;
s_read <='0';



-- 0   1   0   0
-- TEST 6: Write directly to a block that we know is in memory and that we have written to before
REPORT "#6 Write to the block that was swapped back to memory in test 5, valid, not dirty, miss";
s_write <='1';
s_writedata <= X"00000011";
s_addr <= X"00000800";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

-- 0   1   1   1
REPORT "#6 Continue writing to same block, so now: valid, dirty, hit"; --block now back in cache,hit, and dirty since we have written to it
s_writedata <= X"00000012";
s_addr <= X"00000804";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

s_writedata <= X"00000013";
s_addr <= X"00000808";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

s_writedata <= X"00000014";
s_addr <= X"0000080C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;
s_write <='0';


-- 1   1   1   1
-- TEST 7: read data from test 6, to verify it has been written
REPORT "#7 Read block from test 6, valid, dirty, hit"; -- data is valid and dirty we wrote to it previously
s_read <='1';
s_addr <= X"00000800";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000011") REPORT "13: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00000804";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000012") REPORT "14: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00000808";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000013") REPORT "15: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000080C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000014") REPORT "16: Write unsuccessful" SEVERITY ERROR;
s_read <='0';


-- 1   1   1   0
-- TEST 8: bring back a valid clean block for test 9
REPORT "#8 Read from memory a valid, clean block, but the dirty block from test 7 is sent back";
s_read <='1';
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000001") REPORT "17: Block not brought back properly" SEVERITY ERROR;

-- 1   1   0   1
REPORT "#8 Continue reading words from same block, valid, clean, hit"; --block in cache is now clean
s_addr <= X"00001004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000002") REPORT "18: Block not brought back properly" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000003") REPORT "19: Block not brought back properly" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000004") REPORT "20: Block not brought back properly" SEVERITY ERROR;
s_read <='0';

-- 0   1   0   1
-- TEST 9: Write to a block which we know is in the cache
REPORT "#9 Write to what is in the cache already, valid, clean, hit";
s_write <='1';
s_writedata <= X"0000004A";
s_addr <= X"000001000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

-- 0   1   1   1
REPORT "#9 Write to what is in the cache already, valid, dirty, hit"; --block was clean, but writing to makes it dirty
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
-- Test 10: read what we wrote to verify
REPORT "#10 Read what was written, valid, dirty, hit"; --the block we are reading is dirty
s_read <='1';
s_addr <= X"00001000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"0000004A") REPORT "21: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"0000004B") REPORT "22: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00001008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"0000004C") REPORT "23: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"0000100C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"0000004D") REPORT "24: Write unsuccessful" SEVERITY ERROR;
s_read <='0';


-- 1   0   0   0
-- TEST 11: Testing for write, not valid, not dirty, tag equal ---- to do so, must read first from random unaccessed memory where nothing has been written to (bc then it is invalid)
REPORT "#11 Read some random memory location, not valid, not dirty, miss";
s_read <='1';
s_addr <= X"00FF0000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000000") REPORT "25: Cache not initialised" SEVERITY ERROR;

-- block gets brought from memory to cache after the miss
-- 1   0   0   1
REPORT "#11 Continue reading from same block,so not valid, not dirty, hit";
s_addr <= X"00FF0004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000000") REPORT "26: Cache not initialised" SEVERITY ERROR;

s_addr <= X"00FF0008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000000") REPORT "27: Cache not initialised" SEVERITY ERROR;

s_addr <= X"00FF000C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"00000000") REPORT "28: Cache not initialised" SEVERITY ERROR;
s_read <='0';


-- 0   0   0   1
--Test 12: write to that random block
REPORT "#12 Write to an invalid block, invalid, clean, hit";
s_write <='1';
s_writedata <= X"FFFFFFFF";
s_addr <= X"00FF0000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

-- 0   1   1   1
REPORT "#12 Continue writing to same block, which is now valid, dirty, hit"; --block was clean, but writing to makes it dirty
s_writedata <= X"EEEEEEEE";
s_addr <= X"00FF0004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

s_writedata <= X"DDDDDDDD";
s_addr <= X"00FF0008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

s_writedata <= X"CCCCCCCC";
s_addr <= X"00FF000C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;
s_write <='0';

-- 1   1   1   1
-- Test 13: read to verify
REPORT "#13 Read to check if written properly: valid, dirty, hit";
s_read <='1';
s_addr <= X"00FF0000";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"FFFFFFFF") REPORT "29: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00FF0004";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"EEEEEEEE") REPORT "30: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00FF0008";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"DDDDDDDD") REPORT "31: Write unsuccessful" SEVERITY ERROR;

s_addr <= X"00FF000C";
WAIT UNTIL falling_edge(s_waitrequest);
WAIT FOR 1 * clk_period;

ASSERT ( s_readdata = X"CCCCCCCC") REPORT "32: Write unsuccessful" SEVERITY ERROR;
s_read <='0';




-- test all possible cases of the cache fsm

-- the binary comments correspond to the cases:
-- read/write - valid/notvalid - dirty/not dirty - tag equal/tagnotequal



-- 0   0   0   0 DONE
REPORT "Testing for write, not valid, not dirty, tag not equal";

-- 0   0   0   1 DONE
REPORT "Testing for write, not valid, not dirty, tag equal";


-- 0   0   1   0 DONE
--Not testing for write, not valid, dirty, tag not equal because impossible


-- 0   0   1   1
--Not testing for write, not valid, dirty, tag equal because impossible

-- 0   1   0   0 DONE
REPORT "Testing for write, valid, not dirty, tag not equal";


-- 0   1   0   1 DONE
REPORT "Testing for write, valid, not dirty, tag equal";


-- 0   1   1   0
-- REPORT "Testing for write, valid, dirty, tag not equal";


-- 0   1   1   1 DONE
REPORT "Testing for write, valid, dirty, tag equal";






--------------------------------------------------------------------------------------------------------------------

-- 1   0   0   0 DONE
REPORT "Testing for read, not valid, not dirty, tag not equal";


-- 1   0   0   1 DONE
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
--REPORT "Testing for read, valid, dirty, tag not equal";


-- 1   1   1   1 DONE
REPORT "Testing for read, valid, dirty, tag equal";




--------------------------------------------------------------------------------------------------------------------


--check if reset works
REPORT "Testing for reset";


end process;

end;
