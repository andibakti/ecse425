library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_write : in std_logic;
	s_waitrequest : out std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_writedata : in std_logic_vector (31 downto 0);
	 
    
    --	Connected with memory
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

-- declare signals here
	type mem_array is array(4096-1 downto 0) of std_logic_vector(41 downto 0);
	--bit table
	----------------------------------------------------------------------------
	--41 Valid | 40  Dirty | 39 	Tag	   32 | 31	 		Data 			0 --
	----------------------------------------------------------------------------

	type state_type is (Swait, Sread, Swrite);
	signal next_state, current_state: state_type;

begin

	states: process (clock, reset)
	begin
		if (reset = '1') then
            		current_state <= Swait;
		elsif (rising_edge(clock)) then
		   	current_state <= next_state;
		end if;
	end process;

	write_process: process(clock, s_addr, s_write)
	begin
		if (rising_edge(clock)) then
			if(s_write) then
				--look up the cache 
				-- thatrow = array.get(s_addr(6 downto 2))

				if(thatrow(39 downto 31) == s_addr(14 downto 7)) then

					if(thatrow(41) == '1') then --ie is the bit valid? (1 = a hit)
						thatrow()
					else then
						--	not valid => miss => go look in memory				
					end if;
				else then
				-- miss go look in mememory
					m_write <= '1';
					m_addr <= s_addr;

				end if;

				
			



			end if;


		end if;
	end process;


-- make circuits here

end arch;