library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity pattern_gen is
    generic (
        BIT_DEPTH: in integer := 8;
        PIXELS_DEPTH: in integer := 10
    );
    port(
        enable: in std_logic;
        h_current_pixel: in std_logic_vector(PIXELS_DEPTH-1 downto 0);
        v_current_pixel: in std_logic_vector(PIXELS_DEPTH-1 downto 0);
        red_enabled: in std_logic;
        green_enabled: in std_logic;
        blue_enabled: in std_logic;
        RR: out std_logic_vector(BIT_DEPTH-1 downto 0) := (others => '0');
        GG: out std_logic_vector(BIT_DEPTH-1 downto 0) := (others => '0');
        BB: out std_logic_vector(BIT_DEPTH-1 downto 0) := (others => '0')
    );
end entity;


architecture rtl of pattern_gen is

    constant h_pixels: integer := 800;
    constant h_pixels_displayed: integer := 640;
    constant v_pixels: integer := 525;
    constant v_pixels_displayed: integer := 480;
    signal h_pixel: integer range 0 to h_pixels-1;
    signal v_pixel: integer range 0 to h_pixels-1;

    constant max_video_signal_value: integer := 255;

    signal red: integer range 0 to max_video_signal_value := 0;
    signal green: integer range 0 to max_video_signal_value := 0;
    signal blue: integer range 0 to max_video_signal_value := 0;

    constant section1_limit: integer := 127;
    constant section2_limit: integer := 254;
    constant section3_limit: integer := 381;
    constant section4_limit: integer := h_pixels_displayed-1;


    function check_channel_enabled(value: integer; enabled: std_logic) return integer is
        -- Useful function to bypass RGB channels when aren't desired
        variable res: integer := 0;
    begin
        if enabled = '1' then
            res := value;
        else
            res := 0;
        end if;

        return res;
    end function;

begin

    h_pixel <= to_integer(unsigned(h_current_pixel));
    v_pixel <= to_integer(unsigned(v_current_pixel));

    RR <= std_logic_vector(to_unsigned(red, BIT_DEPTH)) when enable else (others => 'Z');
    GG <= std_logic_vector(to_unsigned(green, BIT_DEPTH)) when enable else (others => 'Z');
    BB <= std_logic_vector(to_unsigned(blue, BIT_DEPTH)) when enable else (others => 'Z');

    pattern_logic: process(h_pixel, v_pixel, red_enabled, green_enabled, blue_enabled) begin

        if v_pixel >= v_pixels_displayed or h_pixel >= h_pixels_displayed then
            red <= 0;
            green <= 0;
            blue <= 0;

        elsif h_pixel < section1_limit then
            red <= check_channel_enabled(max_video_signal_value, red_enabled);
            green <= 0;
            blue <= 0;

        elsif h_pixel < section2_limit then
            red <= 0;
            green <= check_channel_enabled(max_video_signal_value, green_enabled);
            blue <= 0;

        elsif h_pixel < section3_limit then
            red <= 0;
            green <= 0;
            blue <= check_channel_enabled(max_video_signal_value, blue_enabled);

        else 
            red <= check_channel_enabled(max_video_signal_value, red_enabled);
            green <= check_channel_enabled(max_video_signal_value, green_enabled);
            blue <= check_channel_enabled(max_video_signal_value, blue_enabled);
        end if;
    
    end process;
end architecture;


    