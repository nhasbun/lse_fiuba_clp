library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity vga_sync is 
    generic (
        PIXELS_DEPTH: in integer := 10);
    port ( 
        clk_25M: in std_logic;
        enable: in std_logic;
        hsync: out std_logic := '0';
        vsync: out std_logic := '0';
        data_enable: out std_logic := '0';
        h_current_pixel: out std_logic_vector(PIXELS_DEPTH-1 downto 0) := (others => '0');
        v_current_pixel: out std_logic_vector(PIXELS_DEPTH-1 downto 0) := (others => '0')
        );
end entity;

architecture rtl of vga_sync is 

-- timing for vga 640x480 60fps according to 
-- http://tinyvga.com/vga-timing/640x480@60Hz
-- front porch - sync pulse - back porch simple explanation 
-- https://electronics.stackexchange.com/questions/295130/vga-timing-sync-porch-positions-fpga

constant h_pixels: integer := 800;
constant h_pixels_visible: integer := 640;
constant v_pixels: integer := 525;
constant v_pixels_visible: integer := 480;
signal h_count: integer range 0 to h_pixels-1 := 0;
signal v_count: integer range 0 to v_pixels-1 := 0;

begin

    h_current_pixel <= std_logic_vector(to_unsigned(h_count, PIXELS_DEPTH));
    v_current_pixel <= std_logic_vector(to_unsigned(v_count, PIXELS_DEPTH));

    pixel_count: process(clk_25M) begin
        if rising_edge(clk_25M) then
            if enable = '0' then
                h_count <= h_pixels - 1;
                v_count <= v_pixels - 1;
            else
                if h_count = h_pixels - 1 then

                    h_count <= 0;
                    
                    if v_count = v_pixels - 1 then
                        v_count <= 0;
                    else
                        v_count <= v_count + 1;
                    end if;

                else
                    h_count <= h_count + 1;
                end if;
            end if;
        end if;
    end process;


    hsync_signals: process(clk_25M) begin

        if rising_edge(clk_25M) then

            if enable = '0' then
                hsync <= '0';
            else
                case h_count is 
                    when h_pixels - 1 => hsync <= '1';
                    -- visible area + front porch = 640 + 16 = 
                    when 656 - 1 => hsync <= '0';
                    -- back to back porch = 656 + 48 = 704
                    when 704 - 1 => hsync <= '1';

                    when others => hsync <= hsync;
                end case;
            end if;
        end if;
    end process;

    vsync_signals: process(clk_25M) begin

        if rising_edge(clk_25M) then

            if enable = '0' then
                vsync <= '0';
            else
                case v_count is 
                    when v_pixels - 1 => vsync <= '1';
                    -- visible area + front porch = 480 + 10 = 
                    when 490 - 1 => vsync <= '0';
                    -- back to back porch = 490 + 2 = 704
                    when 492 - 1 => vsync <= '1';

                    when others => vsync <= vsync;
                end case;
            end if;
        end if;
    end process;

    data_enable_signal: process(clk_25M) begin
        
        if rising_edge(clk_25M) then

            if enable = '0' then
                data_enable <= '0';
            elsif h_count >= 0 and h_count < h_pixels_visible-1 and v_count >= 0 and v_count < v_pixels_visible then
                data_enable <= '1';
            else 
                data_enable <= '0';
            end if; 
        end if;    
        
    end process;

end architecture;
