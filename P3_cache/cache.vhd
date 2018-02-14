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
	type mem_array is array(32-1 downto 0) of std_logic_vector(137 downto 0);
	signal ram: mem_array;
	signal rowFound : std_logic_vector(137 downto 0);
	signal default_waitrequest : std_logic := '1';

	--bit table
	----------------------------------------------------------------------------
	--137 Valid | 136 Dirty | 135 	Tag	   128 | 127	 	Block Data		0 --
	----------------------------------------------------------------------------


	-- How data is stored (Big Endian)
	-- Word table stored in data block
	---_______________________________________________
	--| 127 	96 | 95		64 | 65		32 | 31 	0 |
	--|-----------------------------------------------|

begin
	


	write_process: process(clock, s_addr, s_write)
	begin
		if (rising_edge(clock)) then
			if(s_write) then
				--look up the cache 
				rowFound <= ram(s_addr(6 downto 2));	-- 12 bits needed to find the correct index in a 4096 bit (word aligned)


				if(rowFound(135 downto 128) == s_addr(14 downto 7)) then	--check if the tag is the same

					if(rowFound(137) == '1') then --ie is the bit valid? (1 = a hit)
						
						-- select the word to be replaced
						case s_addr(1) & s_addr(0) is
							when 00 => rowFound(31 downto 0)  <= s_writedata;
							when 01 => rowFound(63 downto 32)  <= s_writedata;
							when 10 => rowFound(95 downto 64)  <= s_writedata;
							when 11 => rowFound(127 downto 96)  <= s_writedata;
						end case;

						rowFound(136) <= '1';	--set the bit to be dirty
						--then update the cache
						ram(s_addr(6 downto 2)) <=  rowFound;
						
					else then
						m_write <= '1';
						m_addr <= s_addr;
						m_writedata <= s_writedata;
						wait until m_waitrequest = '0';

						--	not valid => miss => go look in memory				
					end if;
				else then
				-- miss go look in memory
					m_write <= '1';
					m_addr <= s_addr;
					m_writedata <= s_writedata;
					wait until m_waitrequest = '0';

				end if;

			elsif (s_read) then

				rowFound <= ram(s_addr(6 downto 2)) 	-- 5 bits needed to find the correct index of the 32 blocks

				if(rowFound(135 downto 128) == s_addr(14 downto 7)) then

					if(rowFound(137) == '1') then --ie is the bit valid? (1 = a hit)
						
						-- select the word to be read
						case s_addr(1) & s_addr(0) is
							when 00 =>  s_readdata <= rowFound(31 downto 0);  
							when 01 =>  s_readdata <= rowFound(63 downto 32);
							when 10 =>  s_readdata <= rowFound(95 downto 64);
							when 11 =>  s_readdata <= rowFound(127 downto 96);
						end case;

						s_waitrequest <= '0'; 	--data is on the bus 
						
					else then
						--	not valid => miss => go look in memory	
						--	(if the block to be replaced is dirty, send the old block to a buffer, save the new block and service the read
						--		then write back the correct value in memory.)			
					end if;
				else then
				-- miss go look in memory
					m_read <= '1';
					m_addr <= s_addr;
					wait until m_waitrequest = '0';
					s_readdata <= m_readdata;

				end if;

			end if; -- if (s_write)
		end if; --rising edge
	end process;

	--Setting the default wait request value
	s_waitrequest <= default_waitrequest;

-- make circuits here

end arch;