LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity washing_machine is
port (
    clk : in std_logic;
    reset : in std_logic;
    start: in std_logic;
    door: in std_logic;
    SW: in STD_LOGIC_VECTOR(3 downto 0);
    SW2: in STD_LOGIC_VECTOR(2 downto 0);
    SW3: in STD_LOGIC_VECTOR(2 downto 0);
    number_segment: out STD_LOGIC_VECTOR(6 downto 0);
    time_segment: out STD_LOGIC_VECTOR(6 downto 0);
    temperature_segment: out STD_LOGIC_VECTOR(13 downto 0);
    rotation_segment: out STD_LOGIC_VECTOR(27 downto 0);
    LED: out STD_LOGIC_VECTOR(4 downto 0)
);
end entity;

architecture Behavioral of washing_machine is
    TYPE state_typ IS (S0,S1,S2,S3,S4);
    signal state: state_typ;
    TYPE programs IS (SZYBKI,SYNTETYK,ZIMNE,BAWELNA,DELIKATNE,WELNA,SPORT,MIX,MANUAL);
    SIGNAL rotation: integer range 0 to 1200:=0;
    SIGNAL temperature: integer range 0 to 90:=0;
    SIGNAL program: programs;
    SIGNAL count: integer range 0 to 9:=0;
    SIGNAL wash_time: std_logic_vector (3 downto 0) := "0000";
    SIGNAL flush_time: std_logic_vector (3 downto 0) := "0000";
    SIGNAL spin_time: std_logic_vector (3 downto 0) := "0000";
	SIGNAL display_1, display_2, display_3, display_4, display_5, display_6 : std_logic_vector(6 downto 0);
	signal internal_number_segment : STD_LOGIC_VECTOR(6 downto 0);
    signal internal_time_segment : STD_LOGIC_VECTOR(6 downto 0);
	
	-- Function that converts integer into 7 segment display
    function to_7_segment(digit: integer) return std_logic_vector is
        type seg_array is array (0 to 9) of std_logic_vector(6 downto 0);
        constant seg_lut: seg_array := (
            "1000000", -- 0
            "1111001", -- 1
            "0100100", -- 2
            "0110000", -- 3
            "0011001", -- 4
            "0010010", -- 5
            "0000010", -- 6
            "1111000", -- 7
            "0000000", -- 8
            "0011000"  -- 9
        );
    begin
        if digit >= 0 and digit <= 9 then
            return seg_lut(digit);
        else			   
            return "1111111"; 
        end if;
    end function; 
	
	function extract_digit(number: integer; digit: integer) return integer is
    begin
        return (number / (10 ** digit)) mod 10;
    end function;

begin
    process(reset, clk)
    begin			 
        if rising_edge(clk) then
            if reset = '1' then
                state <= S0;
                count <= 0;
                rotation <= 0;
                temperature <= 0;
                program <= MANUAL;
                wash_time <= "0000";
                flush_time <= "0000";
                spin_time <= "0000";
                number_segment <= (others => '0');
                time_segment <= (others => '0');
                temperature_segment <= (others => '0');
                rotation_segment <= (others => '0');
                LED <= (others => '0');	
            else
                internal_number_segment <= "000" & SW;
                internal_time_segment <= "000" & wash_time;

                display_1 <= to_7_segment(extract_digit(rotation, 1));
                display_2 <= to_7_segment(extract_digit(rotation, 0));
                display_3 <= to_7_segment(extract_digit(temperature, 0));
                display_4 <= to_7_segment(to_integer(unsigned(internal_number_segment(3 downto 0))));
                display_5 <= to_7_segment(extract_digit(to_integer(unsigned(internal_time_segment)), 1));
                display_6 <= to_7_segment(extract_digit(to_integer(unsigned(internal_time_segment)), 0));

                number_segment <= internal_number_segment;
                time_segment <= internal_time_segment;
				
                case state is
					when S0 =>
						case SW is
                            when "0001" =>	-- PROGRAM 1
							program <= SZYBKI;
							temperature<= 30;
							rotation<= 900;
							when "0010" => -- PROGRAM 2
							program <= SYNTETYK;
							temperature<= 40;
							rotation<= 800;
							when "0011" => -- PROGRAM 3
							program <= ZIMNE;
							temperature<= 20;
							rotation<= 800;
							when "0100" => -- PROGRAM 4
							program <= BAWELNA;
							temperature<= 40;
							rotation<= 1100;
							when "0101" => -- PROGRAM 5
							program <= DELIKATNE;
							temperature<= 30;
							rotation<= 900;
							when "0110" => -- PROGRAM 6
							program <= WELNA;
							temperature<= 60;
							rotation<= 1200;
							when "0111" => -- PROGRAM 7
							program <= SPORT;
							temperature<= 60;
							rotation<= 1000;
							when "1000" => -- PROGRAM 8
							program <= MIX;
							temperature<= 60;
							rotation<= 1100;
							when "1001" => -- PROGRAM 9
							program <= MANUAL;
							case SW2 is
								when "000" => -- Ustawienie temperatury
								temperature<=0;
								when "001" =>
								temperature <=20;
								when "010" =>
								temperature <=30;
								when "011" =>
								temperature <=40;
								when "100" =>
								temperature <=60;
								when "101" =>
								temperature <=90;
								when others =>
								temperature <=0;
							end case;	
							
							case temperature is
                            when 0 =>
                                wash_time <= "0000";
                                flush_time <= "0000";
                            when 20 =>
                                wash_time <= "0011";
                                flush_time <= "0011";
                            when 30 =>
                                wash_time <= "0100";
                                flush_time <= "0100";
                            when 40 =>
                                wash_time <= "0101";
                                flush_time <= "0101";
                            when 60 =>
                                wash_time <= "0111";
                                flush_time <= "0111";
                            when 90 =>
                                wash_time <= "1000";
                                flush_time <= "1000";
                            when others =>
                                wash_time <= "0000";
                                flush_time <= "0000";
                        	end case; 
							
							case SW3 is
							    when "000" =>
							        rotation <= 0;
							    when "001" =>
							        rotation <= 800;
							    when "010" =>
							        rotation <= 900;
							    when "011" =>
							        rotation <= 1000;
							    when "100" =>
							        rotation <= 1100;
							    when "101" =>
							        rotation <= 1200;
							    when others =>
							        rotation <= 0;
							end case;
							
							case rotation is
							    when 0 =>
							        spin_time <= "0000";
							    when 800 =>
							        spin_time <= "0011";
							    when 900 =>
							        spin_time <= "0100";
							    when 1000 =>
							        spin_time <= "0101";
							    when 1100 =>
							        spin_time <= "0111";
							    when 1200 =>
							        spin_time <= "1000";
							    when others =>
							        spin_time <= "0000";
							end case;
							
							when others =>
							program <= MANUAL;
                        end case;

					
					
	                    if start = '1' and door = '0' then
	                        state <= S1;
	                    end if;
                    when S1 =>
					    led(1) <= '1';
					    if count < to_integer(unsigned(wash_time)) then
					        count <= count + 1;
					    else
					        count <= 0;
					        state <= S2;
					    end if;
					
					when S2 =>
					    led(2) <= '1';
					    if count < to_integer(unsigned(flush_time)) then
					        count <= count + 1;
					    else
					        count <= 0;
					        state <= S3;
					    end if;
					
					when S3 =>
					    led(3) <= '1';
					    if count < to_integer(unsigned(spin_time)) then
					        count <= count + 1;
					    else
					        count <= 0;
					        state <= S4;
					    end if;
					
					when S4 =>
                        led <= (others => '0');
                        count <= 0;
                        rotation <= 0;
                        temperature <= 0;
                        program <= MANUAL;
                        wash_time <= "0000";
                        flush_time <= "0000";
                        spin_time <= "0000";
                        number_segment <= (others => '0');
                        time_segment <= (others => '0');
                        temperature_segment <= (others => '0');
                        rotation_segment <= (others => '0');
                        state <= S0;
						
                    when others =>
                        state <= S0; 
					
                end case;
            end if;
        end if;
    end process;
end Behavioral;
