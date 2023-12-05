
module FLOATING_32BIT_ADD_SUB #(
	parameter
		ZERO = {8'h00, 23'h000000},
		INF  = {8'hFF, 23'h000000},
		NAN  = {8'hFF, 23'h400000}
) (
	input  wire         OPS,
	input  wire [31:00] INA, INB,
	output wire [31:00] OUT
);

	wire         maxcomp = (INA[30:00] < INB[30:00]);
	wire [31:00] float_l = (maxcomp) ? INB : INA;
	wire [31:00] float_s = (maxcomp) ? INA : INB;

	wire  ops = OPS ^ float_l[31] ^ float_s[31];
	wire sign = (maxcomp) ? ops ^ float_l[31] : float_l[31];

	wire eq_mag = (   float_l[30:00] == float_s[30:00]);
	wire exp00l = (   float_l[30:23] == 8'h00         );
	wire exp00s = (   float_s[30:23] == 8'h00         );
	wire expffl = (   float_l[30:23] == 8'hFF         );
	wire expffs = (   float_s[30:23] == 8'hFF         );
	wire snf_0l =   ~|float_l[22:00];
	wire snf_0s =   ~|float_s[22:00];

	wire [07:00] exp_dif = float_l[30:23] - float_s[30:23];
	wire		 exp_u26 = ( exp_dif >= 8'd26 );
	wire [49:00] snf_psf = ( exp_u26 ) ? { 26'h0000000, ~exp00s, float_s[22:00] } : ( { ~exp00s, float_s[22:00], 26'h0000000 } >> exp_dif );
	wire		 stk_psf = |snf_psf[23:00];
	wire [27:00] snf_ais = { 1'b0, snf_psf[49:24], stk_psf };
	wire [27:00] snf_ail = { 1'b0, ~exp00l, float_l[22:00], 3'h0 };
	wire [07:00] exp_ail = float_l[30:23];
	
	wire [27:00] snf_2cs = ( ops ) ? ~snf_ais + 1'b1 :snf_ais ;
	wire [27:00] snf_res = snf_ail + snf_2cs ;

	wire	[04:00] exp_usf ; 
	assign			exp_usf[04]	= ~|snf_res[27:12];
	wire	[27:00] snf_st4	    = ( ~exp_usf[04] ) ? snf_res[27:00] : { snf_res[11:00],16'h0000 };
	assign			exp_usf[03]	= ~|snf_st4[27:20];
	wire	[27:00] snf_st3		= ( ~exp_usf[03] ) ? snf_st4[27:00] : { snf_st4[19:00], 8'h00   };
	assign			exp_usf[02]	= ~|snf_st3[27:24];
	wire	[27:00] snf_st2		= ( ~exp_usf[02] ) ? snf_st3[27:00] : { snf_st3[23:00], 4'h0   	};
	assign			exp_usf[01]	= ~|snf_st2[27:26];
	wire	[27:00] snf_st1		= ( ~exp_usf[01] ) ? snf_st2[27:00] : { snf_st2[25:00], 2'h0 	};
	assign			exp_usf[00]	= ~|snf_st1[27] ;
	wire	[27:00] snf_st0		= ( ~exp_usf[00] ) ? snf_st1[27:00] : { snf_st1[26:00], 1'h0 	};
	wire	[09:00] exp_st0		= exp_ail - exp_usf + 1'b1;

	wire b_ulp	 = snf_st0[04];
	wire b_uulp1 = snf_st0[03];
	wire b_uulp2 = snf_st0[02];
	wire b_uulp3 = snf_st0[01];
	wire b_uulp4 = snf_st0[00];

	wire all_1  = &snf_st0[27:04];
	wire en_inc = b_uulp1 & ( b_ulp | b_uulp2 | b_uulp3 | b_uulp4 );
	
	wire [23:00] snf_5a = snf_st0[27:04] + en_inc;
	wire [09:00] exp_5a = exp_st0 + ( en_inc & all_1 ) ;

	wire [22:00] snf_6a	= ( exp_5a[09] ) ? 23'h000000 : 
						  ( exp_5a[08] ) ? 23'h000000 : snf_5a[22:00];
	wire [07:00] exp_6a	= ( exp_5a[09] ) ? 8'h00	  : 
	                  	  ( exp_5a[08] ) ? 8'hff      : exp_5a[07:00];

	function [31:00] fexcpt ;
		input exp00a ,exp00b ;
		input expffa ,expffb ;
		input snf_0a ,snf_0b ;
		input op_sub ,eq_mag ;
		input [30:00] nom_in ;
		casex ( { exp00a, expffa, snf_0a, exp00b, expffb, snf_0b, op_sub, eq_mag } )
			8'b10x_10x_0x : fexcpt = {1'b1,ZERO	  }; // 0   +  0   = 0
			8'b10x_10x_1x : fexcpt = {1'b0,ZERO	  }; // 0    - 0   = 0
			8'b10x_011_xx : fexcpt = {1'b1,INF    }; // 0   +- inf = inf
			8'b10x_010_xx : fexcpt = {1'b1,NAN    }; // 0   +- NaN = NaN
			8'b10x_00x_xx : fexcpt = {1'b1,nom_in }; // 0   +- nom = nom
			8'b011_10x_xx : fexcpt = {1'b1,INF    }; // inf +- 0   = inf
			8'b011_011_0x : fexcpt = {1'b1,INF    }; // inf +  inf = inf
			8'b011_011_1x : fexcpt = {1'b1,NAN    }; // inf  - inf = NaN
			8'b011_010_xx : fexcpt = {1'b1,NAN    }; // inf +- NaN = NaN
			8'b011_00x_xx : fexcpt = {1'b1,INF    }; // inf +- nom = inf
			8'b010_xxx_xx : fexcpt = {1'b1,NAN    }; // NaN +- any = NaN
			8'b00x_10x_xx : fexcpt = {1'b1,nom_in }; // nom +- 0   = nom
			8'b00x_011_xx : fexcpt = {1'b1,INF    }; // nom +- inf = inf
			8'b00x_010_xx : fexcpt = {1'b1,NAN    }; // nom +- NaN = NaN
			8'b00x_00x_0x : fexcpt = {1'b1,nom_in }; // nom +  nom = nom
			8'b00x_00x_10 : fexcpt = {1'b1,nom_in }; // nom  - nom = nom
			8'b00x_00x_11 : fexcpt = {1'b0,ZERO   }; // nom  - nom = 0
			default 	  : fexcpt = {1'b1,NAN    }; // error      = NaN
		endcase
	endfunction

	wire [22:00] snf_7a;
	wire [07:00] exp_7a;
	wire         en_sin ;
	assign {en_sin, exp_7a, snf_7a} = fexcpt(exp00l, exp00s, expffl, expffs, snf_0l, snf_0s, ops, eq_mag, {exp_6a, snf_6a});

	wire [22:00] fl_snf = snf_7a;
	wire [07:00] fl_exp = exp_7a;
	wire         fl_sin = en_sin & sign;

	assign OUT = {fl_sin, fl_exp, fl_snf};

endmodule

module FLOATING_32BIT_ADD (
    input  wire [31:0] INA, INB,
    output wire [31:0] OUT
);

    FLOATING_32BIT_ADD_SUB uADD(.OPS(1'b0), .INA(INA), .INB(INB), .OUT(OUT));

endmodule

module FLOATING_32BIT_SUB (
    input  wire [31:0] INA, INB,
    output wire [31:0] OUT
);

    FLOATING_32BIT_ADD_SUB uSUB(.OPS(1'b1), .INA(INA), .INB(INB), .OUT(OUT));

endmodule

module FLOATING_32BIT_MUL #(
	parameter
		OFST = 127,
		ZERO = {8'h00, 23'h000000},
		INF  = {8'hFF, 23'h000000},
		NAN  = {8'hFF, 23'h400000}
) (
	input  wire [31:0] INA, INB,
    output wire [31:0] OUT
);

	wire exp00a = (   INA[30:23] == 8'h00 );
	wire exp00b = (   INB[30:23] == 8'h00 );
	wire expffa = (   INA[30:23] == 8'hFF );
	wire expffb = (   INB[30:23] == 8'hFF );
	wire snf_0a =   ~|INA[22:00];
	wire snf_0b =   ~|INB[22:00];

	wire [47:00] snf_1a = { ~exp00a, INA[22:00] } * { ~exp00b, INB[22:00] };
	wire [09:00] exp_1a = INA[30:23] + INB[30:23] - OFST;
	wire         sin_1a = INA[31] ^ INB[31];

	wire [47:21] snf_2a = { snf_1a[47:22], (|snf_1a[21:00]) };
	wire [46:20] snf_2b = ( snf_1a[47] ) ? snf_2a[47:21] : { snf_2a[46:21],1'b0 };
	wire [09:00] exp_2a = exp_1a + snf_1a[47] ;

	wire b_least = snf_2b[23];
	wire b_guard = snf_2b[22];
	wire b_round = snf_2b[21];
	wire b_stiky = snf_2b[20];
	wire all_1   = &snf_2a[46:24] ;
	wire en_inc  = b_guard & ( b_least | b_round | b_stiky );

	wire [23:00] snf_3a = snf_2b[46:23]	+ en_inc;
	wire [09:00] exp_3a = exp_2a + ( en_inc & all_1 ) ;
    wire [22:00] snf_4a = ( exp_3a[09] ) ? 23'h000000 :
						  ( exp_3a[08] ) ? 23'h000000 : snf_3a[22:00];
	wire [07:00] exp_4a = ( exp_3a[09] ) ? 8'h00 :
						  ( exp_3a[08] ) ? 8'hff : exp_3a[07:00];

	function [30:00] fexcpt;
		input exp00a, exp00b;
		input expffa, expffb;
		input snf_0a, snf_0b;
		input [30:00] nom_in;
		casex ({ exp00a, expffa, snf_0a, exp00b, expffb, snf_0b })
			6'b10x_10x : fexcpt = ZERO	;	// 0   * 0   = 0
			6'b10x_011 : fexcpt = NAN	;	// 0   * INF = NAN
			6'b10x_010 : fexcpt = NAN	;	// 0   * NAN = NAN
			6'b10x_00x : fexcpt = ZERO	;	// 0   * nom = 0
			6'b011_10x : fexcpt = NAN	;	// INF * 0   = NAN
			6'b011_011 : fexcpt = INF	;	// INF * INF = INF
			6'b011_010 : fexcpt = NAN	;	// INF * NAN = NAN
			6'b011_00x : fexcpt = INF	;	// INF * nom = INF
			6'b010_xxx : fexcpt = NAN	;	// NAN * any = NAN
			6'b00x_10x : fexcpt = ZERO	;	// nom * 0   = 0
			6'b00x_011 : fexcpt = INF	;	// nom * INF = INF
			6'b00x_010 : fexcpt = NAN	;	// nom * NAN = NAN
			6'b00x_00x : fexcpt = nom_in;	// nom * nom = nom
			default    : fexcpt = NAN	;	// error     = NAN
		endcase
	endfunction

	wire [22:00] snf_5a;
	wire [07:00] exp_5a;
	assign {exp_5a,snf_5a} = fexcpt	(exp00a, exp00b, expffa, expffb, snf_0a, snf_0b, {exp_4a, snf_4a});

    wire [22:00] fl_snf = snf_5a;
	wire [07:00] fl_exp = exp_5a;
	wire fl_sin = sin_1a;

	assign OUT = {fl_sin, fl_exp, fl_snf} ;					  

endmodule

module FLOATING_32BIT_DIV #(
	parameter
		OFST = 127,
		ZERO = {8'h00, 23'h000000},
		INF  = {8'hFF, 23'h000000},
		NAN  = {8'hFF, 23'h400000}
) (
	input  wire [31:0] INA, INB,
    output wire [31:0] OUT
);

	wire exp00a = ( INA[30:23] == 8'h00 );
	wire exp00b = ( INB[30:23] == 8'h00 );
	wire expffa = ( INA[30:23] == 8'hff );
	wire expffb = ( INB[30:23] == 8'hff );
	wire snf_0a = ~|INA[22:00];
	wire snf_0b = ~|INB[22:00];

	wire [49:00] snf_1a	= ( { ~exp00a,INA[22:00] } << 25 ) / { ~exp00b,INB[22:00] };
	wire [09:00] exp_1a	= INA[30:23] - INB[30:23] + OFST;
	wire 		 sin_1a = INA[31] ^ INB[31];

	wire [26:00] snf_2a = ( snf_1a[25] ) ? { snf_1a,1'b1 } : { snf_1a[24:00],2'b11 };
	wire [09:00] exp_2a = exp_1a - !snf_1a[25];

	wire b_least = snf_2a[03];
	wire b_guard = snf_2a[02];
	wire b_round = snf_2a[01];
	wire b_stiky = snf_2a[00];

	wire all_1  = &snf_2a[26:03];
	wire en_inc = b_guard & ( b_least | b_round | b_stiky);

	wire [23:00] snf_3a = snf_2a[26:03] +   en_inc;
	wire [09:00] exp_3a = exp_2a		+ ( en_inc & all_1 );
	wire [22:00] snf_4a = ( exp_3a[09] ) ? 23'h000000 :
						  ( exp_3a[08] ) ? 23'h000000 : snf_3a[22:00];
	wire [07:00] exp_4a = ( exp_3a[09] ) ? 8'h00 :
						  ( exp_3a[08] ) ? 8'hff : exp_3a[07:00];

	function [30:00] fexcpt;
		input exp00a, exp00b;
		input expffa, expffb;
		input snf_0a, snf_0b;
		input [30:00] nom_in;
		casex ({ exp00a, expffa, snf_0a, exp00b, expffb, snf_0b })
		 6'b10x_10x : fexcpt = NAN	  ;	// 0   / 0   = NAN
		 6'b10x_011 : fexcpt = ZERO	  ;	// 0   / INF = 0
		 6'b10x_010 : fexcpt = NAN	  ;	// 0   / NAN = NAN
		 6'b10x_00x : fexcpt = ZERO	  ;	// 0   / nom = 0
		 6'b011_10x : fexcpt = INF	  ;	// INF / 0   = INF
		 6'b011_011 : fexcpt = NAN	  ;	// INF / INF = NAN
		 6'b011_010 : fexcpt = NAN	  ;	// INF / NAN = NAN
		 6'b011_00x : fexcpt = INF	  ;	// INF / nom = INF
		 6'b010_xxx : fexcpt = NAN	  ;	// NAN / any = NAN
		 6'b00x_10x : fexcpt = INF	  ;	// nom / 0   = INF
		 6'b00x_011 : fexcpt = ZERO	  ;	// nom / INF = 0
		 6'b00x_010 : fexcpt = NAN	  ;	// nom / NAN = NAN
		 6'b00x_00x : fexcpt = nom_in ;	// nom / nom = nom
		 default	: fexcpt = NAN	  ;	// error     = NAN
		endcase
	endfunction

	wire [22:00] snf_5a;
	wire [07:00] exp_5a;
	assign {exp_5a, snf_5a} = fexcpt(exp00a, exp00b, expffa, expffb, snf_0a, snf_0b, {exp_4a, snf_4a});

	wire [22:00] fl_snf = snf_5a;
	wire [07:00] fl_exp = exp_5a;
	wire fl_sin = sin_1a;

	assign OUT = { fl_sin, fl_exp, fl_snf };

endmodule