library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity top_module is 
    generic (
        BIT_DEPTH: in integer := 8
    );
    port (
        CLK50_IN: in std_logic;
        RESET_IN: in std_logic;

        LED_ARRAY_OUT: out std_logic_vector(7 downto 0);

        HSYNC_OUT: out std_logic;
        VSYNC_OUT: out std_logic;
        RGB_OUT: out std_logic_vector(3*BIT_DEPTH-1 downto 0);
        R_ENABLED_IN: in std_logic;
        G_ENABLED_IN: in std_logic;
        B_ENABLED_IN: in std_logic;

        HDMI_TX_CLK: out std_logic;
        HDMI_TX_DE: out std_logic;
        HDMI_IIC_SCL: out std_logic;
        HDMI_IIC_SDA: inout std_logic;
        HDMI_TX_INT: in std_logic
    );
end entity;

architecture rtl of top_module is

    -- bits needed to represent max value of an horizontal window ~800 pixels
    constant PIXELS_DEPTH: integer := 10;

    signal clk_25M: std_logic;
    signal pll_locked: std_logic;

    signal h_current_pixel: std_logic_vector(PIXELS_DEPTH-1 downto 0);
    signal v_current_pixel: std_logic_vector(PIXELS_DEPTH-1 downto 0);

    signal hdmi_ready: std_logic;

    component pll_clk is
        -- component declaration was necessary for quartus compilation
		port (
			refclk: in  std_logic;
			rst: in  std_logic;
			outclk_0: out std_logic;
			locked: out std_logic
		);
	end component pll_clk;

    component I2C_HDMI_Config is
        -- component declaration was needed since source is in verilog file
        port (
            iCLK: in std_logic;
            iRST_N: in std_logic;
            I2C_SCLK: out std_logic;
            I2C_SDAT: inout std_logic;
            HDMI_TX_INT: in std_logic;
            READY: out std_logic
        );
    end component;

begin

    LED_ARRAY_OUT(7 downto 2) <= (others => '0');
    LED_ARRAY_OUT(1) <= hdmi_ready;
    LED_ARRAY_OUT(0) <= pll_locked;

    HDMI_TX_CLK <= clk_25M;

    pll_inst: component pll_clk
        port map (
            -- IN
            refclk => CLK50_IN,
            rst => RESET_IN,
            -- OUT
            outclk_0 => clk_25M,
            locked => pll_locked
        );

    vga_sync_inst: entity work.vga_sync
        generic map (
            PIXELS_DEPTH => PIXELS_DEPTH
        )
        port map (
            -- IN
            clk_25M => clk_25M,
            enable => pll_locked,
            -- OUT
            hsync => HSYNC_OUT,
            vsync => VSYNC_OUT,
            data_enable => HDMI_TX_DE,
            h_current_pixel => h_current_pixel,
            v_current_pixel => v_current_pixel
        );

    pattern_gen_inst: entity work.pattern_gen
        generic map (
            PIXELS_DEPTH => PIXELS_DEPTH,
            BIT_DEPTH => BIT_DEPTH
        )
        port map (
            -- IN
            enable => pll_locked,
            h_current_pixel => h_current_pixel,
            v_current_pixel => v_current_pixel,
            red_enabled => R_ENABLED_IN,
            green_enabled => G_ENABLED_IN,
            blue_enabled => B_ENABLED_IN,
            -- OUT
            RR => RGB_OUT(3*BIT_DEPTH-1 downto 2*BIT_DEPTH),
            GG => RGB_OUT(2*BIT_DEPTH-1 downto BIT_DEPTH),
            BB => RGB_OUT(BIT_DEPTH-1 downto 0)
        );
 
    hdmi_iic_config_inst: component I2C_HDMI_Config
        port map (
            -- IN
            iCLK => CLK50_IN,
            iRST_N => not RESET_IN,
            HDMI_TX_INT => HDMI_TX_INT,
            -- OUT INOUT,
            I2C_SCLK => HDMI_IIC_SCL,
            I2C_SDAT => HDMI_IIC_SDA,
            READY => hdmi_ready
        );

end architecture;
