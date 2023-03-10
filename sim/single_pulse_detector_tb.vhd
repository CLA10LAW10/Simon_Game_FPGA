LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use std.env.stop;

ENTITY single_pulse_detector_tb IS
END single_pulse_detector_tb;

ARCHITECTURE Behavioral OF single_pulse_detector_tb IS

    SIGNAL clk_tb : STD_LOGIC := '0';           -- Signal simulated clock 
    SIGNAL rst_tb : STD_LOGIC := '0';           -- Signal simulated reset button
    SIGNAL input_signal_tb : STD_LOGIC := '0';  -- Signal simulated input
    SIGNAL output_pulse_tb : STD_LOGIC := '0';  -- Signal simulated output

    CONSTANT CP : TIME := 10ns;

BEGIN

    -- Instantiate the unit under test
    uut : ENTITY work.single_pulse_detector
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            input_signal => input_signal_tb,
            output_pulse => output_pulse_tb
        );

    -- Clock generation process
    clk_gen : PROCESS
    BEGIN
        clk_tb <= '0';
        WAIT FOR CP/2;
        clk_tb <= '1';
        WAIT FOR CP/2;
    END PROCESS;

    -- Input vector
    input_gen : process
    BEGIN
        -- Reset single_pulse_detector
        rst_tb <= '1';
        wait for CP;
        rst_tb <= '0';
        wait for 2 * CP;

        -- Set input signal high, then low.
        -- Observe how although high for a long time, the high pulse is only high for one clock pulse.
        -- Will also only detect rising edges.
        input_signal_tb <= '1';
        wait for 5 * CP;
        input_signal_tb <= '0';
        wait for 5 * CP;
        stop;
    end process;

END Behavioral;