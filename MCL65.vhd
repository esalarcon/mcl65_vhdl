library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MCL65 is 
   Port (   CORE_CLK    :  in    STD_LOGIC;
            RESET       :  in    STD_LOGIC;
            NMI_n       :  in    STD_LOGIC;
            IRQ_n       :  in    STD_LOGIC;
            SO          :  in    STD_LOGIC;
            SYNC        :  out   STD_LOGIC;
            RDWR_n      :  out   STD_LOGIC;
            READY       :  in    STD_LOGIC;
            A           :  out   STD_LOGIC_VECTOR(15 downto 0);
            din         :  in    STD_LOGIC_VECTOR(7 downto 0);
            dout        :  out   STD_LOGIC_VECTOR(7 downto 0);
            WR          :  out   STD_LOGIC);
end MCL65;
   
            
architecture Behavioral of MCL65 is
   signal   add_carry8     :  std_logic := '0';
   signal   add_overflow8  :  std_logic := '0';
   signal   clk1_out_int   :  std_logic := '0';
   signal   clk2_out_int   :  std_logic := '0';
   signal   clk0_int_d1    :  std_logic := '1';
   signal   clk0_int_d2    :  std_logic := '1';
   signal   clk0_int_d3    :  std_logic := '0';
   signal   clk0_int_d4    :  std_logic := '0';
   signal   reset_n_d1     :  std_logic := '0';
   signal   reset_n_d2     :  std_logic := '0';
   signal   nmi_n_d1       :  std_logic := '0';
   signal   nmi_n_d2       :  std_logic := '0';    
   signal   nmi_n_d3       :  std_logic := '0';
   signal   nmi_asserted   :  std_logic := '0';
   signal   irq_d1         :  std_logic := '0';
   signal   irq_d2         :  std_logic := '0';
   signal   irq_d3         :  std_logic := '0';
   signal   irq_d4         :  std_logic := '0';
   signal   irq_gated      :  std_logic := '0';
   signal   so_n_d1        :  std_logic := '0'; 
   signal   so_n_d2        :  std_logic := '0'; 
   signal   so_n_d3        :  std_logic := '0';
   signal   so_asserted    :  std_logic := '0';
   signal   stall_pipeline :  std_logic := '0';
   signal   sync_int_d1    :  std_logic := '0';
   signal   rdwr_n_int_d1  :  std_logic := '0';
   signal   rdwr_n_int_d2  :  std_logic := '0';
   signal   ready_int_d1   :  std_logic := '0';
   signal   ready_int_d2   :  std_logic := '0';
   signal   ready_int_d3   :  std_logic := '0';
   signal   dataout_enable :  std_logic := '0';  
   signal   flag_i         :  std_logic;
   signal   nmi_debounce   :  std_logic;
   signal   so_debounce    :  std_logic;
   signal   opcode_jump_call: std_logic;
   signal   jump_boolean   :  std_logic;
   signal   sync_int       :  std_logic;
   signal   rdwr_n_int     :  std_logic;
   signal   rom_address    :  std_logic_vector(10 downto 0) := (others => '0');
   signal   calling_address:  std_logic_vector(21 downto 0) := (others => '0');
   signal   register_a     :  std_logic_vector( 7 downto 0) := (others => '0');
   signal   register_x     :  std_logic_vector( 7 downto 0) := (others => '0');
   signal   register_y     :  std_logic_vector( 7 downto 0) := (others => '0');
   signal   register_pc    :  std_logic_vector(15 downto 0) := (others => '0');
   signal   register_sp    :  std_logic_vector( 7 downto 0) := (others => '0');
   signal   register_r0    :  std_logic_vector(15 downto 0) := (others => '0');
   signal   register_r1    :  std_logic_vector(15 downto 0) := (others => '0');
   signal   register_r2    :  std_logic_vector(15 downto 0) := (others => '0');
   signal   register_r3    :  std_logic_vector(15 downto 0) := (others => '0');
   signal   alu_last_result:  std_logic_vector(15 downto 0) := (others => '0');
   signal   address_out    :  std_logic_vector(15 downto 0) := (others => '0');
   signal   system_output  :  std_logic_vector( 4 downto 0) := "00001";
   signal   data_out       :  std_logic_vector( 7 downto 0) := (others => '0');
   signal   data_in_d2     :  std_logic_vector( 7 downto 0) := (others => '0');
   signal   register_flags :  std_logic_vector( 7 downto 0) := (others => '0'); 
   signal   a_out_int      :  std_logic_vector(15 downto 0) := (others => '0');    
   signal   d_out_int      :  std_logic_vector( 7 downto 0) := (others => '0');    
   signal   adder_out      :  std_logic_vector(15 downto 0);
   signal   carry          :  std_logic_vector(16 downto 0);
   signal   opcode_type    :  std_logic_vector( 2 downto 0);
   signal   opcode_dst_sel :  std_logic_vector( 3 downto 0);
   signal   opcode_op0_sel :  std_logic_vector( 3 downto 0);
   signal   opcode_op1_sel :  std_logic_vector( 3 downto 0);
   signal   opcode_inmediate: std_logic_vector(15 downto 0);
   signal   opcode_jump_src:  std_logic_vector( 2 downto 0);
   signal   opcode_jump_cond: std_logic_vector( 3 downto 0);
   signal   system_status  :  std_logic_vector(15 downto 0);
   signal   alu2           :  std_logic_vector(15 downto 0);
   signal   alu3           :  std_logic_vector(15 downto 0);
   signal   alu4           :  std_logic_vector(15 downto 0);
   signal   alu5           :  std_logic_vector(15 downto 0);
   signal   alu6           :  std_logic_vector(15 downto 0);
   signal   alu_out        :  std_logic_vector(15 downto 0);
   signal   operand0       :  std_logic_vector(15 downto 0);
   signal   operand1       :  std_logic_vector(15 downto 0);
   signal   rom_data       :  std_logic_vector(31 downto 0);
   
   COMPONENT microcode_rom
   PORT (clka  : IN STD_LOGIC;
         addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
         douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
   END COMPONENT;
   
begin


------------------------------------------------------------------------
--
--  2Kx32 Microcode ROM
--
------------------------------------------------------------------------                                    
mcode_2Kx32:   microcode_rom
               port map(clka  => CORE_CLK,
                        addra => rom_address,
                        douta => rom_data);


------------------------------------------------------------------------
--
-- Combinationals
--
------------------------------------------------------------------------
   A                 <= a_out_int;
   dout              <= d_out_int;
   --DIR0              <= dataout_enable;
   --DIR1              <= dataout_enable;
   so_debounce       <= system_output(4);
   nmi_debounce      <= system_output(3);
   sync_int          <= system_output(1);
   rdwr_n_int        <= system_output(0);
   SYNC              <= sync_int_d1;
   RDWR_n            <= rdwr_n_int_d1;
   WR                <= dataout_enable    and 
                        (not rdwr_n_int)  and
                        clk0_int_d4       and
                        (not clk0_int_d3);
   
   
   --// Microcode ROM opcode decoder
   opcode_type       <= rom_data(30 downto 28);
   opcode_dst_sel    <= rom_data(27 downto 24);
   opcode_op0_sel    <= rom_data(23 downto 20);
   opcode_op1_sel    <= rom_data(19 downto 16);
   opcode_inmediate  <= rom_data(15 downto 0);

   opcode_jump_call  <= rom_data(24);
   opcode_jump_src   <= rom_data(22 downto 20);
   opcode_jump_cond  <= rom_data(19 downto 16);
   
   with opcode_op0_sel select
      operand0 <= register_r0                when "0000",
                  register_r1                when "0001",
                  register_r2                when "0010",
                  register_r3                when "0011",
                  x"00"&register_a           when "0100",
                  x"00"&register_x           when "0101",
                  x"00"&register_y           when "0110",
                  register_pc                when "0111",
                  x"01"&register_sp          when "1000",
                  x"00"&register_flags       when "1001",
                  address_out                when "1010",
                  data_in_d2&data_in_d2      when "1011",
                  system_status              when "1100",
                  x"00"&"000"&system_output  when "1101",
                  opcode_inmediate           when others;


  with opcode_op1_sel select
      operand1 <= register_r0                                        when "0000",
                  register_r1                                        when "0001",
                  register_r2                                        when "0010",
                  register_r3                                        when "0011",
                  x"00"&register_a                                   when "0100",
                  x"00"&register_x                                   when "0101",
                  x"00"&register_y                                   when "0110",
                  register_pc(7 downto 0)&register_pc(15 downto 8)   when "0111",
                  x"01"&register_sp                                  when "1000",
                  x"00"&register_flags                               when "1001",
                  address_out                                        when "1010",
                  data_in_d2&data_in_d2                              when "1011",
                  system_status                                      when "1100",
                  x"00"&"000"&system_output                          when "1101",
                  opcode_inmediate                                   when others;
   

   --// JUMP condition codes
  jump_boolean <= '1' when opcode_jump_cond = x"0" else                                                                          --// Unconditional jump
                  '1' when opcode_jump_cond = x"1" and alu_last_result /= x"0000"                                          else  --// Jump Not Zero
                  '1' when opcode_jump_cond = x"2" and alu_last_result = x"0000"                                           else  --// Jump Zero
                  '1' when opcode_jump_cond = x"3" and clk0_int_d1 = '0'                                                   else  --// Jump backwards until CLK=1
                  '1' when opcode_jump_cond = x"4" and rdwr_n_int_d1 = '0' and clk0_int_d2 = '1'                           else  --// Jump backwards until CLK=0 for write cycles. READY ignored
                  '1' when opcode_jump_cond = x"4" and rdwr_n_int_d1 = '1' and (clk0_int_d2 = '1' or ready_int_d3 = '0')   else  --// Jump backwards until CLK=0 for read cycles with READY active
                  '0';
   
   --// System status
   system_status(15 downto 7) <= (others => '0');
   system_status(6)           <= add_overflow8;
   system_status(5)           <= irq_gated;
   system_status(4)           <= so_asserted;
   system_status(3)           <= nmi_asserted;
   system_status(2)           <= '0';
   system_status(1)           <= '0';
   system_status(0)           <= add_carry8;

--   flag_n                     <= register_flags(7);
--   flag_v                     <= register_flags(6);
--   flag_b                     <= register_flags(4);
--   flag_d                     <= register_flags(3);
     flag_i                     <= register_flags(2);
--   flag_z                     <= register_flags(1);
--   flag_c                     <= register_flags(0);

   --// Microsequencer ALU Operations
   --// ------------------------------------------
   --//     alu0 = NOP
   --//     alu1 = JUMP
   alu2 <= adder_out;                                --// ADD
   alu3 <= operand0 and operand1;                    --// AND
   alu4 <= operand0 or  operand1;                    --// OR
   alu5 <= operand0 xor operand1;                    --// XOR
   alu6 <= "0"&operand0(15 downto 1);                --// SHR 

   --// Mux the ALU operations
   with opcode_type select
      alu_out  <= alu2        when "010",
                  alu3        when "011",
                  alu4        when "100",
                  alu5        when "101",
                  alu6        when "110",
                  x"EEEE"     when others;

   --// Generate 16-bit full adder 
   carry(0) <= '0';
   adder: for i in 0 to 15 generate
      gadd: adder_out(i)   <=  operand0(i) xor operand1(i) xor carry(i);
      gcry: carry(i+1)     <= (operand0(i) and operand1(i)) or
                              (operand0(i) and carry(i))    or
                              (operand1(i) and carry(i));
   end generate;

   --//------------------------------------------------------------------------------------------  
   --//
   --// Microsequencer
   --//
   --//------------------------------------------------------------------------------------------ 
   process(CORE_CLK)
   begin
      if(rising_edge(CORE_CLK)) then
         clk0_int_d1    <= clk0_int_d4;
         clk0_int_d2    <= clk0_int_d1;
         clk0_int_d3    <= clk0_int_d2;
         clk0_int_d4    <= clk0_int_d3;

         
         reset_n_d1     <= not RESET;
         reset_n_d2     <= reset_n_d1;
         ready_int_d1   <= READY;
         ready_int_d2   <= ready_int_d1;
         ready_int_d3   <= ready_int_d2;   
         sync_int_d1    <= sync_int;
         rdwr_n_int_d1  <= rdwr_n_int;
         rdwr_n_int_d2  <= rdwr_n_int_d1;
         a_out_int      <= address_out;
         d_out_int      <= data_out;
         irq_d1         <= not IRQ_n;
         --data_in_d1     <= din;
         irq_gated      <= irq_d4 and (not flag_i);              


         --// Store data and sample IRQ_n on falling edge of clk      
         if (clk0_int_d3='1' and clk0_int_d2='0') then    
            data_in_d2  <= din; --data_in_d1;          
            irq_d2      <= irq_d1;
            irq_d3      <= irq_d2;
            irq_d4      <= irq_d3;
         end if;
         
         
         if (rdwr_n_int_d1='0' and clk0_int_d4='1') then
            dataout_enable <= '1';
         elsif (rdwr_n_int_d2='0' and  rdwr_n_int_d1='1') then
            dataout_enable <= '0';
         end if;
         
         nmi_n_d1 <= NMI_n;
         nmi_n_d2 <= nmi_n_d1;
         nmi_n_d3 <= nmi_n_d2;       
         if (nmi_debounce='1') then
            nmi_asserted <= '0';
         elsif (nmi_n_d3='1' and nmi_n_d2='0') then --// Falling edge of NMI_n
            nmi_asserted <= '1';
         end if;
         
         so_n_d1 <= SO;
         so_n_d2 <=so_n_d1;
         so_n_d3 <=so_n_d2;      
         if (so_debounce='1') then
            so_asserted <= '0';
         elsif (so_n_d3='1'  and so_n_d2='0') then --// Falling edge of SO
            so_asserted <= '1';
         end if;

         -- // Generate and store flags for addition
         if (stall_pipeline='0' and opcode_type="010") then
            add_carry8     <= carry(8);
            add_overflow8  <= carry(8) xor carry(7);             
         end if;

         --    // Register writeback   
         if (stall_pipeline='0' and opcode_type/="000" and  opcode_type/="001") then 
            alu_last_result <= alu_out;
            case opcode_dst_sel is
               when "0000" => register_r0    <= alu_out;
               when "0001" => register_r1    <= alu_out;
               when "0010" => register_r2    <= alu_out;
               when "0011" => register_r3    <= alu_out;
               when "0100" => register_a     <= alu_out(7 downto 0);
               when "0101" => register_x     <= alu_out(7 downto 0);
               when "0110" => register_y     <= alu_out(7 downto 0);
               when "0111" => register_pc    <= alu_out;
               when "1000" => register_sp    <= alu_out(7 downto 0);
               when "1001" => register_flags <= alu_out(7 downto 6)&"11"&alu_out(3 downto 0);
               when "1010" => address_out    <= alu_out;
               when "1011" => data_out       <= alu_out(7 downto 0);
               when "1101" => system_output  <= alu_out(4 downto 0);
               when others => null;
            end case;
         end if;

         if (reset_n_d2='0') then
            rom_address <= "111"&x"D0";   --// Microcode starts here after reset
            stall_pipeline <= '0';
         
         --// JUMP Opcode
         elsif (stall_pipeline='0' and opcode_type="001" and jump_boolean='1') then
            stall_pipeline <= '1';
            --// For subroutine CALLs, store next opcode address
            if (opcode_jump_call='1') then
               calling_address(21 downto 0) <= calling_address(10 downto 0)&rom_address(10 downto 0);  --// Two deep stack for calling addresses
            end if;           

            case (opcode_jump_src) is   --//synthesis parallel_case
               when "000"  => rom_address <= opcode_inmediate(10 downto 0);
               when "001"  => rom_address <= "000"&data_in_d2(7 downto 0);
               when "010"  => rom_address <= calling_address(10 downto 0);
                              calling_address(10 downto 0) <= calling_address(21 downto 11);
               when "011"  => rom_address <= std_logic_vector(unsigned(rom_address)-1);
               when others => null;
            end case;                
         else
            stall_pipeline <= '0'; --// Debounce the pipeline stall
            rom_address <= std_logic_vector(unsigned(rom_address) + 1);
         end if;
      end if;
   end process;
end Behavioral;