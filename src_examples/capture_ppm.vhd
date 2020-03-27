-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- entity
entity capture_ppm is
port (	ppm_in : in std_logic;
        capture_reg1, capture_reg2, capture_reg3, capture_reg4, capture_reg5, capture_reg6 : out std_logic_vector(31 downto 0);
	debug : out std_logic_vector(7 downto 0);
	counter_bit18, counter1_bit18 : out std_logic;
		CLK,CLR : in std_logic);
end capture_ppm;

-- architecture
architecture capture_ppm1 of capture_ppm is
	type state_type is (Initial,Idle,Lock,L1,L2,L3,L4,L5,L6,L7,CH1,CH2,CH3,CH4,CH5,CH6);
	signal PS,NS : state_type;
	signal counter : std_logic_vector(31 downto 0);
	signal counter_1 : std_logic_vector(31 downto 0);
	signal counter_2 : std_logic_vector(31 downto 0);
	signal reset : std_logic;
	signal reset_1 : std_logic;
	signal save :  std_logic_vector(7 downto 0);
	signal w_capture_reg1, w_capture_reg2, w_capture_reg3, w_capture_reg4, w_capture_reg5, w_capture_reg6 : std_logic_vector(31 downto 0);
	signal channel : std_logic_vector(7 downto 0);

	
	component debounce_ppm is
	port ( d_ppm_in : in STD_LOGIC;
           d_CLK : in STD_LOGIC;
           d_ppm_out : out STD_LOGIC);
	end component; 
	

begin
   
	capture_reg1 <= w_capture_reg1;
	capture_reg2 <= w_capture_reg2;
	capture_reg3 <= w_capture_reg3;
	capture_reg4 <= w_capture_reg4;
	capture_reg5 <= w_capture_reg5;
	capture_reg6 <= w_capture_reg6;
	debug <= channel;
	counter_bit18 <= counter(18);
	counter1_bit18 <= counter_1(18);

	sync_proc: process(CLK,NS,CLR) 
	begin
		-- take care of the asynchronous input 
		if (CLR = '1') then
			PS <= Initial;
		elsif (((counter_1 > 300000) and (PS /= Initial)) or (counter_2 > 300000)) then
			PS <= Idle;
		elsif (rising_edge(CLK)) then
			PS <= NS;
		end if;
	end process sync_proc;

	sync_proc1: process(CLK,reset,save,CLR) 
	begin
		-- counter for keeping track of pulse width
		if (CLR = '1' or reset = '1') then
			counter <= (others=>'0');
		elsif ( rising_edge(CLK)) then
			counter <= counter + 1;
		else 
			counter <= counter;
		end if;

		-- counter1 for searching idle channel
		if (CLR = '1' or reset = '1' or reset_1 = '1' or ppm_in = '0') then
			counter_1 <= (others=>'0');
		elsif ( (rising_edge(CLK))) then
			counter_1 <= counter_1 + 1;
		else 
			counter_1 <= counter_1;
		end if;

		-- counter2 for when its off
		if ((CLR = '1') or (ppm_in = '1')) then
			counter_2 <= (others=>'0');
		elsif ( (rising_edge(CLK)) and (ppm_in = '0')) then
			counter_2 <= counter_2 + 1;
		else 
			counter_2 <= counter_2;
		end if;



		if (CLR = '1') then
			w_capture_reg1 <= (others => '0');
			w_capture_reg2 <= (others => '0');
			w_capture_reg3 <= (others => '0');
			w_capture_reg4 <= (others => '0');
			w_capture_reg5 <= (others => '0');
			w_capture_reg6 <= (others => '0');
		
		elsif ( rising_edge(CLK) )then		
		case save is				
			when "00000001" => 
				w_capture_reg1 <= counter;
			when "00000010" =>
				w_capture_reg2 <= counter;
			when "00000100" =>
				w_capture_reg3 <= counter;
			when "00001000" => 
				w_capture_reg4 <= counter;
			when "00010000" =>
				w_capture_reg5 <= counter;
			when "00100000" =>
				w_capture_reg6 <= counter;
			when others =>
				w_capture_reg1 <= w_capture_reg1;
				w_capture_reg2 <= w_capture_reg2;
				w_capture_reg3 <= w_capture_reg3;
				w_capture_reg4 <= w_capture_reg4;
				w_capture_reg5 <= w_capture_reg5;
				w_capture_reg6 <= w_capture_reg6;
		end case;
		end if;

	end process sync_proc1;
			
	comb_proc: process(PS,ppm_in) 
	begin
		case PS is
			when Initial =>
				channel <= "10101010";
				if ( ppm_in = '1' and counter_1 > 500000) then NS <= Idle; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				else NS <= Initial; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;		
			
			when Idle => 
				channel <= "00000001";
				if ( ppm_in = '0') then NS <= L1; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				else NS <= Idle; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;
			
			when L1 => 
				channel <= "00000010";
				if (ppm_in = '1') then NS <= CH1; reset <= '1'; save <= (others => '0'); reset_1 <= '1';
				else NS <= L1; save <= (others => '0'); reset <= '0'; reset_1 <= '1';
				end if;
				
			when CH1 => 
				channel <= "00000011"; 
				if(counter_1 > 300000) then NS <= Idle; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				elsif ( ppm_in = '0') then NS <= L2; save <= "00000001"; reset_1 <= '1';
				else NS <= CH1; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;

			when L2 => 
				channel <= "00000100";
				if (ppm_in = '1') then NS <= CH2; reset <= '1'; save <= (others => '0'); reset_1 <= '1';
				else NS <= L2; save <= "10000000"; reset_1 <= '1'; 
				end if;

			when CH2 => 
				channel <= "00000101";
				if(counter_1 > 300000) then NS <= Idle; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				elsif ( ppm_in = '0') then NS <= L3; save <= "00000010"; reset_1 <= '1';
				else NS <= CH2; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;

			when L3 => 
				channel <= "00000110";
				if (ppm_in = '1') then NS <= CH3; reset <= '1'; save <= (others => '0'); reset_1 <= '1';
				else NS <= L3; save <= "10000000"; reset_1 <= '1';
				end if;

			when CH3 => 
				channel <= "00000111";
				if(counter_1 > 300000) then NS <= Idle; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				elsif (ppm_in = '0') then NS <= L4; save <= "00000100"; reset_1 <= '1';
				else NS <= CH3; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;

			when L4 => 
				channel <= "00001000";
				if (ppm_in = '1') then NS <= CH4; reset <= '1'; save <= (others => '0'); reset_1 <= '1';	
				else NS <= L4; save <= "10000000"; reset_1 <= '1';
				end if;

			when CH4 => 
				channel <= "00001001";
				if(counter_1 > 300000) then NS <= Idle; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				elsif (ppm_in = '0') then NS <= L5; save <= "00001000"; reset_1 <= '1';
				else NS <= CH4; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;

			when L5 => 
				channel <= "00001010";
				if (ppm_in = '1') then NS <= CH5; reset <= '1'; save <= (others => '0'); reset_1 <= '1';
				else NS <= L5; save <= "10000000"; reset_1 <= '1'; 
				end if;

			when CH5 => 
				channel <= "00001011";
				if(counter_1 > 300000) then NS <= Idle; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				elsif (ppm_in = '0') then NS <= L6; save <= "00010000"; reset_1 <= '1';
				else NS <= CH5; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;

			when L6 => 
				channel <= "00001100";
				if (ppm_in = '1') then NS <= CH6; reset <= '1'; save <= (others => '0'); reset_1 <= '1';
				else NS <= L6; save <= "10000000"; reset_1 <= '1'; 
				end if;

			when CH6 => 
				channel <= "00001101";
				if(counter_1 > 300000) then NS <= Initial; reset <= '1'; reset_1 <= '1'; save <= (others => '0');
				elsif (ppm_in = '0') then NS <= L7; save <= "00100000"; reset_1 <= '1';
				else NS <= CH6; reset <= '0'; reset_1 <= '0'; save <= (others => '0');
				end if;

			when L7 => 
				channel <= "00001110";
				if (ppm_in = '1') then NS <= Idle; reset <= '1'; save <= (others => '0'); reset_1 <= '1';
				else NS <= L7; save <= "10000000"; reset_1 <= '1'; 
				end if;				
			
			when others => -- the catch-all condition
				channel <= "11111111";
				NS <= Initial; -- make it to these two statements
				save <= (others => '0');
		end case;
	end process comb_proc;


end capture_ppm1;