LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY mcl65_tb IS
END mcl65_tb;
 
ARCHITECTURE behavior OF mcl65_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MCL65
    PORT(
         CORE_CLK : IN  std_logic;
         CLK0 : IN  std_logic;
         CLK1 : OUT  std_logic;
         CLK2 : OUT  std_logic;
         RESET_n : IN  std_logic;
         NMI_n : IN  std_logic;
         IRQ_n : IN  std_logic;
         SO : IN  std_logic;
         SYNC : OUT  std_logic;
         RDWR_n : OUT  std_logic;
         READY : IN  std_logic;
         A : OUT  std_logic_vector(15 downto 0);
         --D : INOUT  std_logic_vector(7 downto 0);
         DIN   :  IN std_logic_vector(7 downto 0);
         DOUT  : OUT std_logic_vector(7 downto 0);
         DIR0 : OUT  std_logic;
         DIR1 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CORE_CLK : std_logic := '0';
   signal CLK0 : std_logic := '0';
   signal RESET_n : std_logic := '0';
   signal NMI_n : std_logic := '1';
   signal IRQ_n : std_logic := '1';
   signal SO : std_logic := '1';
   signal READY : std_logic := '1';
   signal DIN  :  std_logic_vector(7 downto 0) := x"AA";
   
 	--Outputs
   signal CLK1 : std_logic;
   signal CLK2 : std_logic;
   signal SYNC : std_logic;
   signal RDWR_n : std_logic;
   signal A : std_logic_vector(15 downto 0);
   signal DIR0 : std_logic;
   signal DIR1 : std_logic;
   signal DOUT :  std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CORE_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MCL65 PORT MAP (
          CORE_CLK => CORE_CLK,
          CLK0 => CLK0,
          CLK1 => CLK1,
          CLK2 => CLK2,
          RESET_n => RESET_n,
          NMI_n => NMI_n,
          IRQ_n => IRQ_n,
          SO => SO,
          SYNC => SYNC,
          RDWR_n => RDWR_n,
          READY => READY,
          A => A,
          DIN => DIN,
          DOUT => DOUT,
          DIR0 => DIR0,
          DIR1 => DIR1
        );

   -- Clock process definitions
   CORE_CLK_process :process
   begin
		CORE_CLK <= '1';
		wait for CORE_CLK_period/2;
		CORE_CLK <= '0';
		wait for CORE_CLK_period/2;
   end process;
 
   CLK0_process :process
   begin
		CLK0 <= '1';
		wait for CORE_CLK_period*2;
		CLK0 <= '0';
		wait for CORE_CLK_period*2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      RESET_n <= '0';
      wait for CORE_CLK_period*10;
      RESET_n <= '1';
      
      -- insert stimulus here 

      wait;
   end process;

END;
