	component STSource is
		port (
			clk       : in  std_logic                     := 'X'; -- clk
			reset     : in  std_logic                     := 'X'; -- reset
			src_data  : out std_logic_vector(31 downto 0);        -- data
			src_valid : out std_logic_vector(0 downto 0);         -- valid
			src_ready : in  std_logic                     := 'X'  -- ready
		);
	end component STSource;

	u0 : component STSource
		port map (
			clk       => CONNECTED_TO_clk,       --       clk.clk
			reset     => CONNECTED_TO_reset,     -- clk_reset.reset
			src_data  => CONNECTED_TO_src_data,  --       src.data
			src_valid => CONNECTED_TO_src_valid, --          .valid
			src_ready => CONNECTED_TO_src_ready  --          .ready
		);

