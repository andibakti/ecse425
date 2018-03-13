library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    port(
        clock: in std_logic;
        A: in std_logic_vector(31 downto 0);
	B: in std_logic_vector(31 downto 0);
	select: in std_logic_vector(3 downto 0);
        reset: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end entity;

architecture arch of ALU is
--declare signals
signal temp: std_logic_vector(31 downto 0);

begin
    process (clock) begin
        if(reset = '1') then
            output <= (OTHERS => '0');
        elsif rising_edge(clock) then
            case select is
		when "????" => temp <= A+B --add?
		--put other shit
        end if;
    end process;
output <= temp;
--TO DO: IMPLEMENT ZERO?

end arch;
