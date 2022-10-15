library IEEE;
use IEEE.std_logic_1164.all;

entity vga_module_tb is
    -- component vga_module
    --     generic (
    --         BIT_DEPTH : natural
    --     );
    --     port (
    --         clk_25M : in std_logic;
    --         enable : in std_logic;
    --         hsync : out std_logic;
    --         vsync : out std_logic;
    --         red : out std_logic_vector(BIT_DEPTH-1 downto 0);
    --         green : out std_logic_vector(BIT_DEPTH-1 downto 0);
    --         blue : out std_logic_vector(BIT_DEPTH-1 downto 0)
    --     );
    -- end component;

end entity;

architecture rtl of vga_module_tb is 

    constant BIT_DEPTH: integer := 8;
    constant PIXELS_DEPTH: integer := 10;

    signal clk: std_logic := '0';
    signal enable: std_logic := '0';
    signal hsync: std_logic;
    signal vsync: std_logic;
    signal data_enable: std_logic;
    signal h_current_pixel : std_logic_vector(PIXELS_DEPTH-1 downto 0);
    signal v_current_pixel : std_logic_vector(PIXELS_DEPTH-1 downto 0);
    
    signal red: std_logic_vector(BIT_DEPTH-1 downto 0);
    signal green: std_logic_vector(BIT_DEPTH-1 downto 0);
    signal blue: std_logic_vector(BIT_DEPTH-1 downto 0);

begin

    clk <= not clk after 19.86 ns; -- ~25.175 MHz clock
    enable <= '1' after 400 ns, '0' after 17 ms;
    
    vga_sync_inst : entity work.vga_sync
        generic map (
            PIXELS_DEPTH => PIXELS_DEPTH
        )
        port map (
            clk_25M => clk,
            enable => enable,
            hsync => hsync,
            vsync => vsync,
            data_enable => data_enable,
            h_current_pixel => h_current_pixel,
            v_current_pixel => v_current_pixel
        );

    pattern_gen_inst : entity work.pattern_gen
        generic map (
          BIT_DEPTH => BIT_DEPTH,
          PIXELS_DEPTH => PIXELS_DEPTH
        )
        port map (
            enable => enable,
            h_current_pixel => h_current_pixel,
            v_current_pixel => v_current_pixel,
            red_enabled => '1',
            green_enabled => '1',
            blue_enabled => '1',
            RR => red,
            GG => green,
            BB => blue
        );
      

end architecture;
