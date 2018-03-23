library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ex_ALU is
    port(
        clock: in std_logic;
        a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		signExtendImmediate: in std_logic_vector(31 downto 0);
		sel: in std_logic_vector(4 downto 0);
        reset: in std_logic;
        zero: out std_logic;
        output: out std_logic_vector(31 downto 0)
        );
end entity;

architecture arch of ex_ALU is
--declare signals
signal temp: std_logic_vector(31 downto 0);
signal hi, lo: std_logic_vector(31 downto 0);
signal stall : std_logic;


begin
    process (clock) begin
        if(reset = '1') then
            output <= (OTHERS => '0');
        elsif rising_edge(clock) then
            case sel is
				when "00000" => temp <= std_logic_vector(signed(a) + signed(b)); --add?
				when "00001" => temp <= std_logic_vector(signed(a) - signed(b));--sub
				when "00010" => temp <= std_logic_vector(signed(a) + signed(signExtendImmediate));--add immediate
				when "00011" => temp <= std_logic_vector(signed(a)*signed(b));--mul
				when "00100" => 
					lo <= std_logic_vector(signed(a)/signed(b)); --div
					hi <= std_logic_vector(signed(a) mod signed(b)); --div

				when "00101" => --set less than (slt)
						if(signed(a) < signed(b)) then
							temp <= X"00000001";
						else
							temp <= (others => '0');
						end if;
				when "00110" => --set less than immediate (slti)
						if(signed(a) < signed(signExtendImmediate)) then
							temp <= X"00000001";
						else
							temp <= (others => '0');
						end if;
				when "00111" => temp <= a and b;--and
				when "01000" => temp <= a or b;--or
				when "01001" => temp <= a nor b;--nor
				when "01010" => temp <= a xor b;--xor
				when "01011" => temp <= a and signExtendImmediate; --and immediate
				when "01100" => temp <= a or signExtendImmediate; --or immediate
				when "01101" => temp <= a xor signExtendImmediate; --xor immediate
				when "01110" => temp <= hi;--move from HI 
				when "01111" => temp <= lo;--move from LO
				when "10000" => temp <= std_logic_vector(shift_left(signed(a),16));	--load upper immediate
				when "10001" => temp <= std_logic_vector(shift_left(unsigned(a), to_integer(signed(b)))); --shift left logical (unsigned)
				when "10010" => temp <= std_logic_vector(shift_right(unsigned(a), to_integer(signed(b)))); --shift right logical
				when "10011" => temp <= std_logic_vector(shift_left(signed(a), to_integer(signed(b)))); --shift right arithmetic (signed)
				when others => 
					temp <= (others => '0');
					-- stall
					stall <= '1';

				--when "????" =>  --branch on equal (beq)
				--		if(signed(a) = signed(b)) then
				--			temp <= ;
				--		else
				--			temp <= ;
				--		end if;
				--when "????" => temp <= ???? --branch on not equal (beq)
				--when "????" => temp <= ???? --jump
				--when "????" => temp <= ???? --jump register
				--when "????" => temp <= ???? --jump and link

				--when "????" => temp <= ???? --load word (lw)
				--when "????" => temp <= ???? --store word (sw)

			end case;

        end if;
    end process;
output <= temp;
zero <= stall;

end arch;
