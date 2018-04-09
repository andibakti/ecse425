library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection is
    port ( EN : in  std_logic
         ; regA_ex   : in   std_logic_vector (4 downto 0)
         ; regB_id   : in   std_logic_vector (4 downto 0)
         ; regA_id   : in   std_logic_vector (4 downto 0)
         ; hazOut : out  std_logic
        );
end hazard_detection;

architecture arch of hazard_detection is

begin

  process (EN, regA_ex, regB_id, regA_id) 
  begin 
  
    hazOut  <= '0';
    
    if EN = '1' then
		
	  if regA_ex = regB_id then
		--HAZARD DETECTED
        hazOut <= '1';
	  end if;
		
      if regA_ex = regA_id then
        --HAZARD DETECTED
        hazOut <= '1';
      end if;
	  
    end if;
  end process;

end arch;