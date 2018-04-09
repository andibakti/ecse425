library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC_adder is
    port(
        override: in std_logic;
        pc: in std_logic_vector(31 downto 0);
        override_pc: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0)
        );
end entity;

architecture arch of PC_adder is

begin
    with override select output <=
        override_pc when '1',
        std_logic_vector(unsigned(pc) + 4) when others;
end arch;
