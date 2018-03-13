library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    port(
        clock: in std_logic;
        a: in std_logic_vector(31 downto 0);
	b: in std_logic_vector(31 downto 0);
	select: in std_logic_vector(5 downto 0);
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
		when "????" => temp <= a+b --add?
		when "????" => temp <= a-b--sub
		when "????" => temp <= std_logic_vector(signed(a)*signed(b))--mul
		when "????" => temp <= ????--div
		--slt
	
		when "????" => temp <= a and b--and
		when "????" => temp <= a or b--or
		when "????" => temp <= a nor b--nor
		when "????" => temp <= a xor b--xor

		--sll
		--srl
	

        end if;
    end process;
output <= temp;
--TO DO: IMPLEMENT ZERO?

end arch;
