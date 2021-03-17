LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY mcl65_tb IS
END mcl65_tb;
 
ARCHITECTURE behavior OF mcl65_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MCL65
    PORT(
         CORE_CLK : IN     std_logic;
         RESET    : IN     std_logic;
         NMI_n    : IN     std_logic;
         IRQ_n    : IN     std_logic;
         SO       : IN     std_logic;
         SYNC     : OUT    std_logic;
         RDWR_n   : OUT    std_logic;
         READY    : IN     std_logic;
         A        : OUT    std_logic_vector(15 downto 0);
         DIN      : IN     std_logic_vector(7 downto 0);
         DOUT     : OUT    std_logic_vector(7 downto 0);
         WR       : OUT    std_logic);
    END COMPONENT;
    

   --Inputs
   signal CORE_CLK   : std_logic := '0';
   signal RESET      : std_logic := '0';
   signal NMI_n      : std_logic := '1';
   signal IRQ_n      : std_logic := '1';
   signal SO         : std_logic := '1';
   signal READY      : std_logic := '1';
   signal DIN        :  std_logic_vector(7 downto 0):= x"00";
   
 	--Outputs
   signal SYNC       : std_logic;
   signal RDWR_n     : std_logic;
   signal A          : std_logic_vector(15 downto 0);
   signal DOUT       : std_logic_vector(7 downto 0);
   signal WR         : std_logic;
   
   -- Clock period definitions
   constant CORE_CLK_period : time := 25 ns;
 
   --memoria RAM.
   type mram is array (natural range <>) of std_logic_vector(7 downto 0);
   signal ram  : mram (511 downto 0) := (others => (others => '0'));
 
   --decodificación
   signal din_ram, din_rom    :  std_logic_vector(7 downto 0);
   signal wr_ram              :  std_logic;
   
BEGIN
 
   process(CORE_CLK)
      variable i : natural range 0 to 511;
   begin
      if(rising_edge(CORE_CLK)) then
         i:= to_integer(unsigned(A(8 downto 0)));
         if(wr_ram = '1') then
            ram(i) <= dout;
         end if;
         din_ram <= ram(i);
      end if;
   end process;
 
   wr_ram   <= wr when A(15 downto 12) = x"0" else '0';
   din      <= din_ram when A(15 downto 12) = x"0" else din_rom;
 
   process(CORE_CLK)
   begin
      if(rising_edge(CORE_CLK)) then
         case A is
            when x"1000"   => din_rom <= x"E6";
            when x"1001"   => din_rom <= x"01";
            when x"1002"   => din_rom <= x"E6";
            when x"1003"   => din_rom <= x"01";
            when x"1004"   => din_rom <= x"20";
            when x"1005"   => din_rom <= x"00";
            when x"1006"   => din_rom <= x"20";
            when x"2000"   => din_rom <= x"60";
            when x"FFFC"   => din_rom <= x"00";
            when x"FFFD"   => din_rom <= x"10";
            when x"FFFE"   => din_rom <= x"00";
            when x"FFFF"   => din_rom <= x"10";
            when others    => din_rom <= x"C8"; 
         end case;
      end if;
   end process;
 
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MCL65 PORT MAP (
          CORE_CLK   => CORE_CLK,
          RESET      => RESET,
          NMI_n      => NMI_n,
          IRQ_n      => IRQ_n,
          SO         => SO,
          SYNC       => SYNC,
          RDWR_n     => RDWR_n,
          READY      => READY,
          A          => A,
          DIN        => DIN,
          DOUT       => DOUT,
          WR         => WR);

   -- Clock process definitions
   CORE_CLK_process :process
   begin
		CORE_CLK <= '1';
		wait for CORE_CLK_period/2;
		CORE_CLK <= '0';
		wait for CORE_CLK_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      RESET <= '1';
      wait for CORE_CLK_period*10;
      RESET <= '0';
      
      -- insert stimulus here 
      wait;
   end process;

END;
