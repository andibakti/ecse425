library ieee;
use ieee.std_logic_1164.all;

entity PC is
    port(
        clock: in std_logic;
        input: in std_logic_vector(31 downto 0);
        reset: in std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end entity;

architecture arch of PC is

begin
    counter: process (clock) begin
        if(reset = '1') then
            output <= (OTHERS => '0');
        elsif rising_edge(clock) then
            output <= input;
        end if;
    end process;
end arch;
