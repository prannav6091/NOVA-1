module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] mem [0:4095];
    integer i;

    initial begin

        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 32'h00000013;

        mem[0] = 32'h40000537; // x10 = NOVA-1 AI MMIO base
        mem[1] = 32'h00800593; // x11 = 8
        mem[2] = 32'h00B52423; // IMAGE WIDTH = 8
        mem[3] = 32'h00800593; // x11 = 8
        mem[4] = 32'h00B52623; // IMAGE HEIGHT = 8
        mem[5] = 32'h00001637; // x12 = input base 0x1000 [upper 0x00001]
        mem[6] = 32'h00C52823; // INPUT_BASE = 0x00001000
        mem[7] = 32'h00100593; // x11 = 1
        mem[8] = 32'h04B52223; // NETWORK Cin = 1
        mem[9] = 32'h00200593; // x11 = 2
        mem[10] = 32'h04B52023; // NETWORK NUM_LAYERS = 2
        mem[11] = 32'h00004637; // x12 = buffer A 0x4000 [upper 0x00004]
        mem[12] = 32'h04C52423; // BUFFER_A = 0x00004000
        mem[13] = 32'h00008637; // x12 = buffer B 0x8000 [upper 0x00008]
        mem[14] = 32'h04C52623; // BUFFER_B = 0x00008000
        mem[15] = 32'h00000593; // x11 = 0
        mem[16] = 32'h04B52823; // Descriptor layer = 0
        mem[17] = 32'h00400593; // x11 = 4
        mem[18] = 32'h04B52A23; // Layer 0 Cout = 4
        mem[19] = 32'h00200593; // x11 = 2
        mem[20] = 32'h04B52C23; // Layer 0 stride = 2
        mem[21] = 32'h00100593; // x11 = 1
        mem[22] = 32'h04B52E23; // COMMIT layer 0 descriptor
        mem[23] = 32'h00100593; // x11 = 1
        mem[24] = 32'h04B52823; // Descriptor layer = 1
        mem[25] = 32'h00800593; // x11 = 8
        mem[26] = 32'h04B52A23; // Layer 1 Cout = 8
        mem[27] = 32'h00100593; // x11 = 1
        mem[28] = 32'h04B52C23; // Layer 1 stride = 1
        mem[29] = 32'h00100593; // x11 = 1
        mem[30] = 32'h04B52E23; // COMMIT layer 1 descriptor
        mem[31] = 32'h00000593; // x11 = 0
        mem[32] = 32'h06B52423; // MODEL_LAYER = 0
        mem[33] = 32'h00000593; // x11 = 0
        mem[34] = 32'h06B52823; // L0 weight filter = 0
        mem[35] = 32'h00000593; // x11 = 0
        mem[36] = 32'h06B52A23; // L0 weight channel = 0
        mem[37] = 32'h00000593; // x11 = 0
        mem[38] = 32'h06B52C23; // L0 weight tap = 0
        mem[39] = 32'h01300593; // x11 = 19
        mem[40] = 32'h06B52E23; // L0 weight data = 19
        mem[41] = 32'h00100593; // x11 = 1
        mem[42] = 32'h08B52023; // COMMIT L0 F0 C0 T0 = 19
        mem[43] = 32'h00000593; // x11 = 0
        mem[44] = 32'h06B52823; // L0 weight filter = 0
        mem[45] = 32'h00000593; // x11 = 0
        mem[46] = 32'h06B52A23; // L0 weight channel = 0
        mem[47] = 32'h00100593; // x11 = 1
        mem[48] = 32'h06B52C23; // L0 weight tap = 1
        mem[49] = 32'h01700593; // x11 = 23
        mem[50] = 32'h06B52E23; // L0 weight data = 23
        mem[51] = 32'h00100593; // x11 = 1
        mem[52] = 32'h08B52023; // COMMIT L0 F0 C0 T1 = 23
        mem[53] = 32'h00000593; // x11 = 0
        mem[54] = 32'h06B52823; // L0 weight filter = 0
        mem[55] = 32'h00000593; // x11 = 0
        mem[56] = 32'h06B52A23; // L0 weight channel = 0
        mem[57] = 32'h00200593; // x11 = 2
        mem[58] = 32'h06B52C23; // L0 weight tap = 2
        mem[59] = 32'h01A00593; // x11 = 26
        mem[60] = 32'h06B52E23; // L0 weight data = 26
        mem[61] = 32'h00100593; // x11 = 1
        mem[62] = 32'h08B52023; // COMMIT L0 F0 C0 T2 = 26
        mem[63] = 32'h00000593; // x11 = 0
        mem[64] = 32'h06B52823; // L0 weight filter = 0
        mem[65] = 32'h00000593; // x11 = 0
        mem[66] = 32'h06B52A23; // L0 weight channel = 0
        mem[67] = 32'h00300593; // x11 = 3
        mem[68] = 32'h06B52C23; // L0 weight tap = 3
        mem[69] = 32'h07F00593; // x11 = 127
        mem[70] = 32'h06B52E23; // L0 weight data = 127
        mem[71] = 32'h00100593; // x11 = 1
        mem[72] = 32'h08B52023; // COMMIT L0 F0 C0 T3 = 127
        mem[73] = 32'h00000593; // x11 = 0
        mem[74] = 32'h06B52823; // L0 weight filter = 0
        mem[75] = 32'h00000593; // x11 = 0
        mem[76] = 32'h06B52A23; // L0 weight channel = 0
        mem[77] = 32'h00400593; // x11 = 4
        mem[78] = 32'h06B52C23; // L0 weight tap = 4
        mem[79] = 32'h05A00593; // x11 = 90
        mem[80] = 32'h06B52E23; // L0 weight data = 90
        mem[81] = 32'h00100593; // x11 = 1
        mem[82] = 32'h08B52023; // COMMIT L0 F0 C0 T4 = 90
        mem[83] = 32'h00000593; // x11 = 0
        mem[84] = 32'h06B52823; // L0 weight filter = 0
        mem[85] = 32'h00000593; // x11 = 0
        mem[86] = 32'h06B52A23; // L0 weight channel = 0
        mem[87] = 32'h00500593; // x11 = 5
        mem[88] = 32'h06B52C23; // L0 weight tap = 5
        mem[89] = 32'h03500593; // x11 = 53
        mem[90] = 32'h06B52E23; // L0 weight data = 53
        mem[91] = 32'h00100593; // x11 = 1
        mem[92] = 32'h08B52023; // COMMIT L0 F0 C0 T5 = 53
        mem[93] = 32'h00000593; // x11 = 0
        mem[94] = 32'h06B52823; // L0 weight filter = 0
        mem[95] = 32'h00000593; // x11 = 0
        mem[96] = 32'h06B52A23; // L0 weight channel = 0
        mem[97] = 32'h00600593; // x11 = 6
        mem[98] = 32'h06B52C23; // L0 weight tap = 6
        mem[99] = 32'h07100593; // x11 = 113
        mem[100] = 32'h06B52E23; // L0 weight data = 113
        mem[101] = 32'h00100593; // x11 = 1
        mem[102] = 32'h08B52023; // COMMIT L0 F0 C0 T6 = 113
        mem[103] = 32'h00000593; // x11 = 0
        mem[104] = 32'h06B52823; // L0 weight filter = 0
        mem[105] = 32'h00000593; // x11 = 0
        mem[106] = 32'h06B52A23; // L0 weight channel = 0
        mem[107] = 32'h00700593; // x11 = 7
        mem[108] = 32'h06B52C23; // L0 weight tap = 7
        mem[109] = 32'h06900593; // x11 = 105
        mem[110] = 32'h06B52E23; // L0 weight data = 105
        mem[111] = 32'h00100593; // x11 = 1
        mem[112] = 32'h08B52023; // COMMIT L0 F0 C0 T7 = 105
        mem[113] = 32'h00000593; // x11 = 0
        mem[114] = 32'h06B52823; // L0 weight filter = 0
        mem[115] = 32'h00000593; // x11 = 0
        mem[116] = 32'h06B52A23; // L0 weight channel = 0
        mem[117] = 32'h00800593; // x11 = 8
        mem[118] = 32'h06B52C23; // L0 weight tap = 8
        mem[119] = 32'h03300593; // x11 = 51
        mem[120] = 32'h06B52E23; // L0 weight data = 51
        mem[121] = 32'h00100593; // x11 = 1
        mem[122] = 32'h08B52023; // COMMIT L0 F0 C0 T8 = 51
        mem[123] = 32'h00100593; // x11 = 1
        mem[124] = 32'h06B52823; // L0 weight filter = 1
        mem[125] = 32'h00000593; // x11 = 0
        mem[126] = 32'h06B52A23; // L0 weight channel = 0
        mem[127] = 32'h00000593; // x11 = 0
        mem[128] = 32'h06B52C23; // L0 weight tap = 0
        mem[129] = 32'h00800593; // x11 = 8
        mem[130] = 32'h06B52E23; // L0 weight data = 8
        mem[131] = 32'h00100593; // x11 = 1
        mem[132] = 32'h08B52023; // COMMIT L0 F1 C0 T0 = 8
        mem[133] = 32'h00100593; // x11 = 1
        mem[134] = 32'h06B52823; // L0 weight filter = 1
        mem[135] = 32'h00000593; // x11 = 0
        mem[136] = 32'h06B52A23; // L0 weight channel = 0
        mem[137] = 32'h00100593; // x11 = 1
        mem[138] = 32'h06B52C23; // L0 weight tap = 1
        mem[139] = 32'hFF300593; // x11 = -13
        mem[140] = 32'h06B52E23; // L0 weight data = -13
        mem[141] = 32'h00100593; // x11 = 1
        mem[142] = 32'h08B52023; // COMMIT L0 F1 C0 T1 = -13
        mem[143] = 32'h00100593; // x11 = 1
        mem[144] = 32'h06B52823; // L0 weight filter = 1
        mem[145] = 32'h00000593; // x11 = 0
        mem[146] = 32'h06B52A23; // L0 weight channel = 0
        mem[147] = 32'h00200593; // x11 = 2
        mem[148] = 32'h06B52C23; // L0 weight tap = 2
        mem[149] = 32'hFF300593; // x11 = -13
        mem[150] = 32'h06B52E23; // L0 weight data = -13
        mem[151] = 32'h00100593; // x11 = 1
        mem[152] = 32'h08B52023; // COMMIT L0 F1 C0 T2 = -13
        mem[153] = 32'h00100593; // x11 = 1
        mem[154] = 32'h06B52823; // L0 weight filter = 1
        mem[155] = 32'h00000593; // x11 = 0
        mem[156] = 32'h06B52A23; // L0 weight channel = 0
        mem[157] = 32'h00300593; // x11 = 3
        mem[158] = 32'h06B52C23; // L0 weight tap = 3
        mem[159] = 32'h00400593; // x11 = 4
        mem[160] = 32'h06B52E23; // L0 weight data = 4
        mem[161] = 32'h00100593; // x11 = 1
        mem[162] = 32'h08B52023; // COMMIT L0 F1 C0 T3 = 4
        mem[163] = 32'h00100593; // x11 = 1
        mem[164] = 32'h06B52823; // L0 weight filter = 1
        mem[165] = 32'h00000593; // x11 = 0
        mem[166] = 32'h06B52A23; // L0 weight channel = 0
        mem[167] = 32'h00400593; // x11 = 4
        mem[168] = 32'h06B52C23; // L0 weight tap = 4
        mem[169] = 32'hFCC00593; // x11 = -52
        mem[170] = 32'h06B52E23; // L0 weight data = -52
        mem[171] = 32'h00100593; // x11 = 1
        mem[172] = 32'h08B52023; // COMMIT L0 F1 C0 T4 = -52
        mem[173] = 32'h00100593; // x11 = 1
        mem[174] = 32'h06B52823; // L0 weight filter = 1
        mem[175] = 32'h00000593; // x11 = 0
        mem[176] = 32'h06B52A23; // L0 weight channel = 0
        mem[177] = 32'h00500593; // x11 = 5
        mem[178] = 32'h06B52C23; // L0 weight tap = 5
        mem[179] = 32'hFD100593; // x11 = -47
        mem[180] = 32'h06B52E23; // L0 weight data = -47
        mem[181] = 32'h00100593; // x11 = 1
        mem[182] = 32'h08B52023; // COMMIT L0 F1 C0 T5 = -47
        mem[183] = 32'h00100593; // x11 = 1
        mem[184] = 32'h06B52823; // L0 weight filter = 1
        mem[185] = 32'h00000593; // x11 = 0
        mem[186] = 32'h06B52A23; // L0 weight channel = 0
        mem[187] = 32'h00600593; // x11 = 6
        mem[188] = 32'h06B52C23; // L0 weight tap = 6
        mem[189] = 32'hFF000593; // x11 = -16
        mem[190] = 32'h06B52E23; // L0 weight data = -16
        mem[191] = 32'h00100593; // x11 = 1
        mem[192] = 32'h08B52023; // COMMIT L0 F1 C0 T6 = -16
        mem[193] = 32'h00100593; // x11 = 1
        mem[194] = 32'h06B52823; // L0 weight filter = 1
        mem[195] = 32'h00000593; // x11 = 0
        mem[196] = 32'h06B52A23; // L0 weight channel = 0
        mem[197] = 32'h00700593; // x11 = 7
        mem[198] = 32'h06B52C23; // L0 weight tap = 7
        mem[199] = 32'hFE400593; // x11 = -28
        mem[200] = 32'h06B52E23; // L0 weight data = -28
        mem[201] = 32'h00100593; // x11 = 1
        mem[202] = 32'h08B52023; // COMMIT L0 F1 C0 T7 = -28
        mem[203] = 32'h00100593; // x11 = 1
        mem[204] = 32'h06B52823; // L0 weight filter = 1
        mem[205] = 32'h00000593; // x11 = 0
        mem[206] = 32'h06B52A23; // L0 weight channel = 0
        mem[207] = 32'h00800593; // x11 = 8
        mem[208] = 32'h06B52C23; // L0 weight tap = 8
        mem[209] = 32'h00800593; // x11 = 8
        mem[210] = 32'h06B52E23; // L0 weight data = 8
        mem[211] = 32'h00100593; // x11 = 1
        mem[212] = 32'h08B52023; // COMMIT L0 F1 C0 T8 = 8
        mem[213] = 32'h00200593; // x11 = 2
        mem[214] = 32'h06B52823; // L0 weight filter = 2
        mem[215] = 32'h00000593; // x11 = 0
        mem[216] = 32'h06B52A23; // L0 weight channel = 0
        mem[217] = 32'h00000593; // x11 = 0
        mem[218] = 32'h06B52C23; // L0 weight tap = 0
        mem[219] = 32'hFDD00593; // x11 = -35
        mem[220] = 32'h06B52E23; // L0 weight data = -35
        mem[221] = 32'h00100593; // x11 = 1
        mem[222] = 32'h08B52023; // COMMIT L0 F2 C0 T0 = -35
        mem[223] = 32'h00200593; // x11 = 2
        mem[224] = 32'h06B52823; // L0 weight filter = 2
        mem[225] = 32'h00000593; // x11 = 0
        mem[226] = 32'h06B52A23; // L0 weight channel = 0
        mem[227] = 32'h00100593; // x11 = 1
        mem[228] = 32'h06B52C23; // L0 weight tap = 1
        mem[229] = 32'hFD800593; // x11 = -40
        mem[230] = 32'h06B52E23; // L0 weight data = -40
        mem[231] = 32'h00100593; // x11 = 1
        mem[232] = 32'h08B52023; // COMMIT L0 F2 C0 T1 = -40
        mem[233] = 32'h00200593; // x11 = 2
        mem[234] = 32'h06B52823; // L0 weight filter = 2
        mem[235] = 32'h00000593; // x11 = 0
        mem[236] = 32'h06B52A23; // L0 weight channel = 0
        mem[237] = 32'h00200593; // x11 = 2
        mem[238] = 32'h06B52C23; // L0 weight tap = 2
        mem[239] = 32'h04A00593; // x11 = 74
        mem[240] = 32'h06B52E23; // L0 weight data = 74
        mem[241] = 32'h00100593; // x11 = 1
        mem[242] = 32'h08B52023; // COMMIT L0 F2 C0 T2 = 74
        mem[243] = 32'h00200593; // x11 = 2
        mem[244] = 32'h06B52823; // L0 weight filter = 2
        mem[245] = 32'h00000593; // x11 = 0
        mem[246] = 32'h06B52A23; // L0 weight channel = 0
        mem[247] = 32'h00300593; // x11 = 3
        mem[248] = 32'h06B52C23; // L0 weight tap = 3
        mem[249] = 32'hFFA00593; // x11 = -6
        mem[250] = 32'h06B52E23; // L0 weight data = -6
        mem[251] = 32'h00100593; // x11 = 1
        mem[252] = 32'h08B52023; // COMMIT L0 F2 C0 T3 = -6
        mem[253] = 32'h00200593; // x11 = 2
        mem[254] = 32'h06B52823; // L0 weight filter = 2
        mem[255] = 32'h00000593; // x11 = 0
        mem[256] = 32'h06B52A23; // L0 weight channel = 0
        mem[257] = 32'h00400593; // x11 = 4
        mem[258] = 32'h06B52C23; // L0 weight tap = 4
        mem[259] = 32'h01A00593; // x11 = 26
        mem[260] = 32'h06B52E23; // L0 weight data = 26
        mem[261] = 32'h00100593; // x11 = 1
        mem[262] = 32'h08B52023; // COMMIT L0 F2 C0 T4 = 26
        mem[263] = 32'h00200593; // x11 = 2
        mem[264] = 32'h06B52823; // L0 weight filter = 2
        mem[265] = 32'h00000593; // x11 = 0
        mem[266] = 32'h06B52A23; // L0 weight channel = 0
        mem[267] = 32'h00500593; // x11 = 5
        mem[268] = 32'h06B52C23; // L0 weight tap = 5
        mem[269] = 32'hFD000593; // x11 = -48
        mem[270] = 32'h06B52E23; // L0 weight data = -48
        mem[271] = 32'h00100593; // x11 = 1
        mem[272] = 32'h08B52023; // COMMIT L0 F2 C0 T5 = -48
        mem[273] = 32'h00200593; // x11 = 2
        mem[274] = 32'h06B52823; // L0 weight filter = 2
        mem[275] = 32'h00000593; // x11 = 0
        mem[276] = 32'h06B52A23; // L0 weight channel = 0
        mem[277] = 32'h00600593; // x11 = 6
        mem[278] = 32'h06B52C23; // L0 weight tap = 6
        mem[279] = 32'h00B00593; // x11 = 11
        mem[280] = 32'h06B52E23; // L0 weight data = 11
        mem[281] = 32'h00100593; // x11 = 1
        mem[282] = 32'h08B52023; // COMMIT L0 F2 C0 T6 = 11
        mem[283] = 32'h00200593; // x11 = 2
        mem[284] = 32'h06B52823; // L0 weight filter = 2
        mem[285] = 32'h00000593; // x11 = 0
        mem[286] = 32'h06B52A23; // L0 weight channel = 0
        mem[287] = 32'h00700593; // x11 = 7
        mem[288] = 32'h06B52C23; // L0 weight tap = 7
        mem[289] = 32'hFFE00593; // x11 = -2
        mem[290] = 32'h06B52E23; // L0 weight data = -2
        mem[291] = 32'h00100593; // x11 = 1
        mem[292] = 32'h08B52023; // COMMIT L0 F2 C0 T7 = -2
        mem[293] = 32'h00200593; // x11 = 2
        mem[294] = 32'h06B52823; // L0 weight filter = 2
        mem[295] = 32'h00000593; // x11 = 0
        mem[296] = 32'h06B52A23; // L0 weight channel = 0
        mem[297] = 32'h00800593; // x11 = 8
        mem[298] = 32'h06B52C23; // L0 weight tap = 8
        mem[299] = 32'hFE100593; // x11 = -31
        mem[300] = 32'h06B52E23; // L0 weight data = -31
        mem[301] = 32'h00100593; // x11 = 1
        mem[302] = 32'h08B52023; // COMMIT L0 F2 C0 T8 = -31
        mem[303] = 32'h00300593; // x11 = 3
        mem[304] = 32'h06B52823; // L0 weight filter = 3
        mem[305] = 32'h00000593; // x11 = 0
        mem[306] = 32'h06B52A23; // L0 weight channel = 0
        mem[307] = 32'h00000593; // x11 = 0
        mem[308] = 32'h06B52C23; // L0 weight tap = 0
        mem[309] = 32'hFFA00593; // x11 = -6
        mem[310] = 32'h06B52E23; // L0 weight data = -6
        mem[311] = 32'h00100593; // x11 = 1
        mem[312] = 32'h08B52023; // COMMIT L0 F3 C0 T0 = -6
        mem[313] = 32'h00300593; // x11 = 3
        mem[314] = 32'h06B52823; // L0 weight filter = 3
        mem[315] = 32'h00000593; // x11 = 0
        mem[316] = 32'h06B52A23; // L0 weight channel = 0
        mem[317] = 32'h00100593; // x11 = 1
        mem[318] = 32'h06B52C23; // L0 weight tap = 1
        mem[319] = 32'h00900593; // x11 = 9
        mem[320] = 32'h06B52E23; // L0 weight data = 9
        mem[321] = 32'h00100593; // x11 = 1
        mem[322] = 32'h08B52023; // COMMIT L0 F3 C0 T1 = 9
        mem[323] = 32'h00300593; // x11 = 3
        mem[324] = 32'h06B52823; // L0 weight filter = 3
        mem[325] = 32'h00000593; // x11 = 0
        mem[326] = 32'h06B52A23; // L0 weight channel = 0
        mem[327] = 32'h00200593; // x11 = 2
        mem[328] = 32'h06B52C23; // L0 weight tap = 2
        mem[329] = 32'hFFD00593; // x11 = -3
        mem[330] = 32'h06B52E23; // L0 weight data = -3
        mem[331] = 32'h00100593; // x11 = 1
        mem[332] = 32'h08B52023; // COMMIT L0 F3 C0 T2 = -3
        mem[333] = 32'h00300593; // x11 = 3
        mem[334] = 32'h06B52823; // L0 weight filter = 3
        mem[335] = 32'h00000593; // x11 = 0
        mem[336] = 32'h06B52A23; // L0 weight channel = 0
        mem[337] = 32'h00300593; // x11 = 3
        mem[338] = 32'h06B52C23; // L0 weight tap = 3
        mem[339] = 32'hFDB00593; // x11 = -37
        mem[340] = 32'h06B52E23; // L0 weight data = -37
        mem[341] = 32'h00100593; // x11 = 1
        mem[342] = 32'h08B52023; // COMMIT L0 F3 C0 T3 = -37
        mem[343] = 32'h00300593; // x11 = 3
        mem[344] = 32'h06B52823; // L0 weight filter = 3
        mem[345] = 32'h00000593; // x11 = 0
        mem[346] = 32'h06B52A23; // L0 weight channel = 0
        mem[347] = 32'h00400593; // x11 = 4
        mem[348] = 32'h06B52C23; // L0 weight tap = 4
        mem[349] = 32'h04300593; // x11 = 67
        mem[350] = 32'h06B52E23; // L0 weight data = 67
        mem[351] = 32'h00100593; // x11 = 1
        mem[352] = 32'h08B52023; // COMMIT L0 F3 C0 T4 = 67
        mem[353] = 32'h00300593; // x11 = 3
        mem[354] = 32'h06B52823; // L0 weight filter = 3
        mem[355] = 32'h00000593; // x11 = 0
        mem[356] = 32'h06B52A23; // L0 weight channel = 0
        mem[357] = 32'h00500593; // x11 = 5
        mem[358] = 32'h06B52C23; // L0 weight tap = 5
        mem[359] = 32'hFE700593; // x11 = -25
        mem[360] = 32'h06B52E23; // L0 weight data = -25
        mem[361] = 32'h00100593; // x11 = 1
        mem[362] = 32'h08B52023; // COMMIT L0 F3 C0 T5 = -25
        mem[363] = 32'h00300593; // x11 = 3
        mem[364] = 32'h06B52823; // L0 weight filter = 3
        mem[365] = 32'h00000593; // x11 = 0
        mem[366] = 32'h06B52A23; // L0 weight channel = 0
        mem[367] = 32'h00600593; // x11 = 6
        mem[368] = 32'h06B52C23; // L0 weight tap = 6
        mem[369] = 32'hFE600593; // x11 = -26
        mem[370] = 32'h06B52E23; // L0 weight data = -26
        mem[371] = 32'h00100593; // x11 = 1
        mem[372] = 32'h08B52023; // COMMIT L0 F3 C0 T6 = -26
        mem[373] = 32'h00300593; // x11 = 3
        mem[374] = 32'h06B52823; // L0 weight filter = 3
        mem[375] = 32'h00000593; // x11 = 0
        mem[376] = 32'h06B52A23; // L0 weight channel = 0
        mem[377] = 32'h00700593; // x11 = 7
        mem[378] = 32'h06B52C23; // L0 weight tap = 7
        mem[379] = 32'h04300593; // x11 = 67
        mem[380] = 32'h06B52E23; // L0 weight data = 67
        mem[381] = 32'h00100593; // x11 = 1
        mem[382] = 32'h08B52023; // COMMIT L0 F3 C0 T7 = 67
        mem[383] = 32'h00300593; // x11 = 3
        mem[384] = 32'h06B52823; // L0 weight filter = 3
        mem[385] = 32'h00000593; // x11 = 0
        mem[386] = 32'h06B52A23; // L0 weight channel = 0
        mem[387] = 32'h00800593; // x11 = 8
        mem[388] = 32'h06B52C23; // L0 weight tap = 8
        mem[389] = 32'hFC900593; // x11 = -55
        mem[390] = 32'h06B52E23; // L0 weight data = -55
        mem[391] = 32'h00100593; // x11 = 1
        mem[392] = 32'h08B52023; // COMMIT L0 F3 C0 T8 = -55
        mem[393] = 32'h00000593; // x11 = 0
        mem[394] = 32'h08B52223; // L0 bias filter = 0
        mem[395] = 32'h88300593; // x11 = -1917
        mem[396] = 32'h08B52423; // L0 bias data = -1917
        mem[397] = 32'h00100593; // x11 = 1
        mem[398] = 32'h08B52623; // COMMIT L0 bias F0 = -1917
        mem[399] = 32'h00100593; // x11 = 1
        mem[400] = 32'h08B52223; // L0 bias filter = 1
        mem[401] = 32'hC4800593; // x11 = -952
        mem[402] = 32'h08B52423; // L0 bias data = -952
        mem[403] = 32'h00100593; // x11 = 1
        mem[404] = 32'h08B52623; // COMMIT L0 bias F1 = -952
        mem[405] = 32'h00200593; // x11 = 2
        mem[406] = 32'h08B52223; // L0 bias filter = 2
        mem[407] = 32'h26B00593; // x11 = 619
        mem[408] = 32'h08B52423; // L0 bias data = 619
        mem[409] = 32'h00100593; // x11 = 1
        mem[410] = 32'h08B52623; // COMMIT L0 bias F2 = 619
        mem[411] = 32'h00300593; // x11 = 3
        mem[412] = 32'h08B52223; // L0 bias filter = 3
        mem[413] = 32'hCA000593; // x11 = -864
        mem[414] = 32'h08B52423; // L0 bias data = -864
        mem[415] = 32'h00100593; // x11 = 1
        mem[416] = 32'h08B52623; // COMMIT L0 bias F3 = -864
        mem[417] = 32'h00000593; // x11 = 0
        mem[418] = 32'h08B52823; // L0 quant filter = 0
        mem[419] = 32'h00A00593; // x11 = 10
        mem[420] = 32'h08B52A23; // L0 quant shift = 10
        mem[421] = 32'h00100593; // x11 = 1
        mem[422] = 32'h08B52C23; // COMMIT L0 quant F0 shift=10
        mem[423] = 32'h00100593; // x11 = 1
        mem[424] = 32'h08B52823; // L0 quant filter = 1
        mem[425] = 32'h00A00593; // x11 = 10
        mem[426] = 32'h08B52A23; // L0 quant shift = 10
        mem[427] = 32'h00100593; // x11 = 1
        mem[428] = 32'h08B52C23; // COMMIT L0 quant F1 shift=10
        mem[429] = 32'h00200593; // x11 = 2
        mem[430] = 32'h08B52823; // L0 quant filter = 2
        mem[431] = 32'h00A00593; // x11 = 10
        mem[432] = 32'h08B52A23; // L0 quant shift = 10
        mem[433] = 32'h00100593; // x11 = 1
        mem[434] = 32'h08B52C23; // COMMIT L0 quant F2 shift=10
        mem[435] = 32'h00300593; // x11 = 3
        mem[436] = 32'h08B52823; // L0 quant filter = 3
        mem[437] = 32'h00A00593; // x11 = 10
        mem[438] = 32'h08B52A23; // L0 quant shift = 10
        mem[439] = 32'h00100593; // x11 = 1
        mem[440] = 32'h08B52C23; // COMMIT L0 quant F3 shift=10
        mem[441] = 32'h00100593; // x11 = 1
        mem[442] = 32'h06B52423; // MODEL_LAYER = 1
        mem[443] = 32'h00000593; // x11 = 0
        mem[444] = 32'h06B52823; // L1 weight filter = 0
        mem[445] = 32'h00000593; // x11 = 0
        mem[446] = 32'h06B52A23; // L1 weight channel = 0
        mem[447] = 32'h00000593; // x11 = 0
        mem[448] = 32'h06B52C23; // L1 weight tap = 0
        mem[449] = 32'hFD900593; // x11 = -39
        mem[450] = 32'h06B52E23; // L1 weight data = -39
        mem[451] = 32'h00100593; // x11 = 1
        mem[452] = 32'h08B52023; // COMMIT L1 F0 C0 T0 = -39
        mem[453] = 32'h00000593; // x11 = 0
        mem[454] = 32'h06B52823; // L1 weight filter = 0
        mem[455] = 32'h00000593; // x11 = 0
        mem[456] = 32'h06B52A23; // L1 weight channel = 0
        mem[457] = 32'h00100593; // x11 = 1
        mem[458] = 32'h06B52C23; // L1 weight tap = 1
        mem[459] = 32'h01A00593; // x11 = 26
        mem[460] = 32'h06B52E23; // L1 weight data = 26
        mem[461] = 32'h00100593; // x11 = 1
        mem[462] = 32'h08B52023; // COMMIT L1 F0 C0 T1 = 26
        mem[463] = 32'h00000593; // x11 = 0
        mem[464] = 32'h06B52823; // L1 weight filter = 0
        mem[465] = 32'h00000593; // x11 = 0
        mem[466] = 32'h06B52A23; // L1 weight channel = 0
        mem[467] = 32'h00200593; // x11 = 2
        mem[468] = 32'h06B52C23; // L1 weight tap = 2
        mem[469] = 32'hFE500593; // x11 = -27
        mem[470] = 32'h06B52E23; // L1 weight data = -27
        mem[471] = 32'h00100593; // x11 = 1
        mem[472] = 32'h08B52023; // COMMIT L1 F0 C0 T2 = -27
        mem[473] = 32'h00000593; // x11 = 0
        mem[474] = 32'h06B52823; // L1 weight filter = 0
        mem[475] = 32'h00000593; // x11 = 0
        mem[476] = 32'h06B52A23; // L1 weight channel = 0
        mem[477] = 32'h00300593; // x11 = 3
        mem[478] = 32'h06B52C23; // L1 weight tap = 3
        mem[479] = 32'hFDF00593; // x11 = -33
        mem[480] = 32'h06B52E23; // L1 weight data = -33
        mem[481] = 32'h00100593; // x11 = 1
        mem[482] = 32'h08B52023; // COMMIT L1 F0 C0 T3 = -33
        mem[483] = 32'h00000593; // x11 = 0
        mem[484] = 32'h06B52823; // L1 weight filter = 0
        mem[485] = 32'h00000593; // x11 = 0
        mem[486] = 32'h06B52A23; // L1 weight channel = 0
        mem[487] = 32'h00400593; // x11 = 4
        mem[488] = 32'h06B52C23; // L1 weight tap = 4
        mem[489] = 32'h01500593; // x11 = 21
        mem[490] = 32'h06B52E23; // L1 weight data = 21
        mem[491] = 32'h00100593; // x11 = 1
        mem[492] = 32'h08B52023; // COMMIT L1 F0 C0 T4 = 21
        mem[493] = 32'h00000593; // x11 = 0
        mem[494] = 32'h06B52823; // L1 weight filter = 0
        mem[495] = 32'h00000593; // x11 = 0
        mem[496] = 32'h06B52A23; // L1 weight channel = 0
        mem[497] = 32'h00500593; // x11 = 5
        mem[498] = 32'h06B52C23; // L1 weight tap = 5
        mem[499] = 32'hFDF00593; // x11 = -33
        mem[500] = 32'h06B52E23; // L1 weight data = -33
        mem[501] = 32'h00100593; // x11 = 1
        mem[502] = 32'h08B52023; // COMMIT L1 F0 C0 T5 = -33
        mem[503] = 32'h00000593; // x11 = 0
        mem[504] = 32'h06B52823; // L1 weight filter = 0
        mem[505] = 32'h00000593; // x11 = 0
        mem[506] = 32'h06B52A23; // L1 weight channel = 0
        mem[507] = 32'h00600593; // x11 = 6
        mem[508] = 32'h06B52C23; // L1 weight tap = 6
        mem[509] = 32'hFEE00593; // x11 = -18
        mem[510] = 32'h06B52E23; // L1 weight data = -18
        mem[511] = 32'h00100593; // x11 = 1
        mem[512] = 32'h08B52023; // COMMIT L1 F0 C0 T6 = -18
        mem[513] = 32'h00000593; // x11 = 0
        mem[514] = 32'h06B52823; // L1 weight filter = 0
        mem[515] = 32'h00000593; // x11 = 0
        mem[516] = 32'h06B52A23; // L1 weight channel = 0
        mem[517] = 32'h00700593; // x11 = 7
        mem[518] = 32'h06B52C23; // L1 weight tap = 7
        mem[519] = 32'h02A00593; // x11 = 42
        mem[520] = 32'h06B52E23; // L1 weight data = 42
        mem[521] = 32'h00100593; // x11 = 1
        mem[522] = 32'h08B52023; // COMMIT L1 F0 C0 T7 = 42
        mem[523] = 32'h00000593; // x11 = 0
        mem[524] = 32'h06B52823; // L1 weight filter = 0
        mem[525] = 32'h00000593; // x11 = 0
        mem[526] = 32'h06B52A23; // L1 weight channel = 0
        mem[527] = 32'h00800593; // x11 = 8
        mem[528] = 32'h06B52C23; // L1 weight tap = 8
        mem[529] = 32'h00800593; // x11 = 8
        mem[530] = 32'h06B52E23; // L1 weight data = 8
        mem[531] = 32'h00100593; // x11 = 1
        mem[532] = 32'h08B52023; // COMMIT L1 F0 C0 T8 = 8
        mem[533] = 32'h00000593; // x11 = 0
        mem[534] = 32'h06B52823; // L1 weight filter = 0
        mem[535] = 32'h00100593; // x11 = 1
        mem[536] = 32'h06B52A23; // L1 weight channel = 1
        mem[537] = 32'h00000593; // x11 = 0
        mem[538] = 32'h06B52C23; // L1 weight tap = 0
        mem[539] = 32'hFF100593; // x11 = -15
        mem[540] = 32'h06B52E23; // L1 weight data = -15
        mem[541] = 32'h00100593; // x11 = 1
        mem[542] = 32'h08B52023; // COMMIT L1 F0 C1 T0 = -15
        mem[543] = 32'h00000593; // x11 = 0
        mem[544] = 32'h06B52823; // L1 weight filter = 0
        mem[545] = 32'h00100593; // x11 = 1
        mem[546] = 32'h06B52A23; // L1 weight channel = 1
        mem[547] = 32'h00100593; // x11 = 1
        mem[548] = 32'h06B52C23; // L1 weight tap = 1
        mem[549] = 32'hFF700593; // x11 = -9
        mem[550] = 32'h06B52E23; // L1 weight data = -9
        mem[551] = 32'h00100593; // x11 = 1
        mem[552] = 32'h08B52023; // COMMIT L1 F0 C1 T1 = -9
        mem[553] = 32'h00000593; // x11 = 0
        mem[554] = 32'h06B52823; // L1 weight filter = 0
        mem[555] = 32'h00100593; // x11 = 1
        mem[556] = 32'h06B52A23; // L1 weight channel = 1
        mem[557] = 32'h00200593; // x11 = 2
        mem[558] = 32'h06B52C23; // L1 weight tap = 2
        mem[559] = 32'h01600593; // x11 = 22
        mem[560] = 32'h06B52E23; // L1 weight data = 22
        mem[561] = 32'h00100593; // x11 = 1
        mem[562] = 32'h08B52023; // COMMIT L1 F0 C1 T2 = 22
        mem[563] = 32'h00000593; // x11 = 0
        mem[564] = 32'h06B52823; // L1 weight filter = 0
        mem[565] = 32'h00100593; // x11 = 1
        mem[566] = 32'h06B52A23; // L1 weight channel = 1
        mem[567] = 32'h00300593; // x11 = 3
        mem[568] = 32'h06B52C23; // L1 weight tap = 3
        mem[569] = 32'h00700593; // x11 = 7
        mem[570] = 32'h06B52E23; // L1 weight data = 7
        mem[571] = 32'h00100593; // x11 = 1
        mem[572] = 32'h08B52023; // COMMIT L1 F0 C1 T3 = 7
        mem[573] = 32'h00000593; // x11 = 0
        mem[574] = 32'h06B52823; // L1 weight filter = 0
        mem[575] = 32'h00100593; // x11 = 1
        mem[576] = 32'h06B52A23; // L1 weight channel = 1
        mem[577] = 32'h00400593; // x11 = 4
        mem[578] = 32'h06B52C23; // L1 weight tap = 4
        mem[579] = 32'hFDB00593; // x11 = -37
        mem[580] = 32'h06B52E23; // L1 weight data = -37
        mem[581] = 32'h00100593; // x11 = 1
        mem[582] = 32'h08B52023; // COMMIT L1 F0 C1 T4 = -37
        mem[583] = 32'h00000593; // x11 = 0
        mem[584] = 32'h06B52823; // L1 weight filter = 0
        mem[585] = 32'h00100593; // x11 = 1
        mem[586] = 32'h06B52A23; // L1 weight channel = 1
        mem[587] = 32'h00500593; // x11 = 5
        mem[588] = 32'h06B52C23; // L1 weight tap = 5
        mem[589] = 32'h00700593; // x11 = 7
        mem[590] = 32'h06B52E23; // L1 weight data = 7
        mem[591] = 32'h00100593; // x11 = 1
        mem[592] = 32'h08B52023; // COMMIT L1 F0 C1 T5 = 7
        mem[593] = 32'h00000593; // x11 = 0
        mem[594] = 32'h06B52823; // L1 weight filter = 0
        mem[595] = 32'h00100593; // x11 = 1
        mem[596] = 32'h06B52A23; // L1 weight channel = 1
        mem[597] = 32'h00600593; // x11 = 6
        mem[598] = 32'h06B52C23; // L1 weight tap = 6
        mem[599] = 32'hFF800593; // x11 = -8
        mem[600] = 32'h06B52E23; // L1 weight data = -8
        mem[601] = 32'h00100593; // x11 = 1
        mem[602] = 32'h08B52023; // COMMIT L1 F0 C1 T6 = -8
        mem[603] = 32'h00000593; // x11 = 0
        mem[604] = 32'h06B52823; // L1 weight filter = 0
        mem[605] = 32'h00100593; // x11 = 1
        mem[606] = 32'h06B52A23; // L1 weight channel = 1
        mem[607] = 32'h00700593; // x11 = 7
        mem[608] = 32'h06B52C23; // L1 weight tap = 7
        mem[609] = 32'hFF300593; // x11 = -13
        mem[610] = 32'h06B52E23; // L1 weight data = -13
        mem[611] = 32'h00100593; // x11 = 1
        mem[612] = 32'h08B52023; // COMMIT L1 F0 C1 T7 = -13
        mem[613] = 32'h00000593; // x11 = 0
        mem[614] = 32'h06B52823; // L1 weight filter = 0
        mem[615] = 32'h00100593; // x11 = 1
        mem[616] = 32'h06B52A23; // L1 weight channel = 1
        mem[617] = 32'h00800593; // x11 = 8
        mem[618] = 32'h06B52C23; // L1 weight tap = 8
        mem[619] = 32'h00E00593; // x11 = 14
        mem[620] = 32'h06B52E23; // L1 weight data = 14
        mem[621] = 32'h00100593; // x11 = 1
        mem[622] = 32'h08B52023; // COMMIT L1 F0 C1 T8 = 14
        mem[623] = 32'h00000593; // x11 = 0
        mem[624] = 32'h06B52823; // L1 weight filter = 0
        mem[625] = 32'h00200593; // x11 = 2
        mem[626] = 32'h06B52A23; // L1 weight channel = 2
        mem[627] = 32'h00000593; // x11 = 0
        mem[628] = 32'h06B52C23; // L1 weight tap = 0
        mem[629] = 32'h00F00593; // x11 = 15
        mem[630] = 32'h06B52E23; // L1 weight data = 15
        mem[631] = 32'h00100593; // x11 = 1
        mem[632] = 32'h08B52023; // COMMIT L1 F0 C2 T0 = 15
        mem[633] = 32'h00000593; // x11 = 0
        mem[634] = 32'h06B52823; // L1 weight filter = 0
        mem[635] = 32'h00200593; // x11 = 2
        mem[636] = 32'h06B52A23; // L1 weight channel = 2
        mem[637] = 32'h00100593; // x11 = 1
        mem[638] = 32'h06B52C23; // L1 weight tap = 1
        mem[639] = 32'h01300593; // x11 = 19
        mem[640] = 32'h06B52E23; // L1 weight data = 19
        mem[641] = 32'h00100593; // x11 = 1
        mem[642] = 32'h08B52023; // COMMIT L1 F0 C2 T1 = 19
        mem[643] = 32'h00000593; // x11 = 0
        mem[644] = 32'h06B52823; // L1 weight filter = 0
        mem[645] = 32'h00200593; // x11 = 2
        mem[646] = 32'h06B52A23; // L1 weight channel = 2
        mem[647] = 32'h00200593; // x11 = 2
        mem[648] = 32'h06B52C23; // L1 weight tap = 2
        mem[649] = 32'hFEE00593; // x11 = -18
        mem[650] = 32'h06B52E23; // L1 weight data = -18
        mem[651] = 32'h00100593; // x11 = 1
        mem[652] = 32'h08B52023; // COMMIT L1 F0 C2 T2 = -18
        mem[653] = 32'h00000593; // x11 = 0
        mem[654] = 32'h06B52823; // L1 weight filter = 0
        mem[655] = 32'h00200593; // x11 = 2
        mem[656] = 32'h06B52A23; // L1 weight channel = 2
        mem[657] = 32'h00300593; // x11 = 3
        mem[658] = 32'h06B52C23; // L1 weight tap = 3
        mem[659] = 32'hFE300593; // x11 = -29
        mem[660] = 32'h06B52E23; // L1 weight data = -29
        mem[661] = 32'h00100593; // x11 = 1
        mem[662] = 32'h08B52023; // COMMIT L1 F0 C2 T3 = -29
        mem[663] = 32'h00000593; // x11 = 0
        mem[664] = 32'h06B52823; // L1 weight filter = 0
        mem[665] = 32'h00200593; // x11 = 2
        mem[666] = 32'h06B52A23; // L1 weight channel = 2
        mem[667] = 32'h00400593; // x11 = 4
        mem[668] = 32'h06B52C23; // L1 weight tap = 4
        mem[669] = 32'hFFA00593; // x11 = -6
        mem[670] = 32'h06B52E23; // L1 weight data = -6
        mem[671] = 32'h00100593; // x11 = 1
        mem[672] = 32'h08B52023; // COMMIT L1 F0 C2 T4 = -6
        mem[673] = 32'h00000593; // x11 = 0
        mem[674] = 32'h06B52823; // L1 weight filter = 0
        mem[675] = 32'h00200593; // x11 = 2
        mem[676] = 32'h06B52A23; // L1 weight channel = 2
        mem[677] = 32'h00500593; // x11 = 5
        mem[678] = 32'h06B52C23; // L1 weight tap = 5
        mem[679] = 32'h00700593; // x11 = 7
        mem[680] = 32'h06B52E23; // L1 weight data = 7
        mem[681] = 32'h00100593; // x11 = 1
        mem[682] = 32'h08B52023; // COMMIT L1 F0 C2 T5 = 7
        mem[683] = 32'h00000593; // x11 = 0
        mem[684] = 32'h06B52823; // L1 weight filter = 0
        mem[685] = 32'h00200593; // x11 = 2
        mem[686] = 32'h06B52A23; // L1 weight channel = 2
        mem[687] = 32'h00600593; // x11 = 6
        mem[688] = 32'h06B52C23; // L1 weight tap = 6
        mem[689] = 32'hFE700593; // x11 = -25
        mem[690] = 32'h06B52E23; // L1 weight data = -25
        mem[691] = 32'h00100593; // x11 = 1
        mem[692] = 32'h08B52023; // COMMIT L1 F0 C2 T6 = -25
        mem[693] = 32'h00000593; // x11 = 0
        mem[694] = 32'h06B52823; // L1 weight filter = 0
        mem[695] = 32'h00200593; // x11 = 2
        mem[696] = 32'h06B52A23; // L1 weight channel = 2
        mem[697] = 32'h00700593; // x11 = 7
        mem[698] = 32'h06B52C23; // L1 weight tap = 7
        mem[699] = 32'hFEE00593; // x11 = -18
        mem[700] = 32'h06B52E23; // L1 weight data = -18
        mem[701] = 32'h00100593; // x11 = 1
        mem[702] = 32'h08B52023; // COMMIT L1 F0 C2 T7 = -18
        mem[703] = 32'h00000593; // x11 = 0
        mem[704] = 32'h06B52823; // L1 weight filter = 0
        mem[705] = 32'h00200593; // x11 = 2
        mem[706] = 32'h06B52A23; // L1 weight channel = 2
        mem[707] = 32'h00800593; // x11 = 8
        mem[708] = 32'h06B52C23; // L1 weight tap = 8
        mem[709] = 32'hFE300593; // x11 = -29
        mem[710] = 32'h06B52E23; // L1 weight data = -29
        mem[711] = 32'h00100593; // x11 = 1
        mem[712] = 32'h08B52023; // COMMIT L1 F0 C2 T8 = -29
        mem[713] = 32'h00000593; // x11 = 0
        mem[714] = 32'h06B52823; // L1 weight filter = 0
        mem[715] = 32'h00300593; // x11 = 3
        mem[716] = 32'h06B52A23; // L1 weight channel = 3
        mem[717] = 32'h00000593; // x11 = 0
        mem[718] = 32'h06B52C23; // L1 weight tap = 0
        mem[719] = 32'hFDD00593; // x11 = -35
        mem[720] = 32'h06B52E23; // L1 weight data = -35
        mem[721] = 32'h00100593; // x11 = 1
        mem[722] = 32'h08B52023; // COMMIT L1 F0 C3 T0 = -35
        mem[723] = 32'h00000593; // x11 = 0
        mem[724] = 32'h06B52823; // L1 weight filter = 0
        mem[725] = 32'h00300593; // x11 = 3
        mem[726] = 32'h06B52A23; // L1 weight channel = 3
        mem[727] = 32'h00100593; // x11 = 1
        mem[728] = 32'h06B52C23; // L1 weight tap = 1
        mem[729] = 32'h02900593; // x11 = 41
        mem[730] = 32'h06B52E23; // L1 weight data = 41
        mem[731] = 32'h00100593; // x11 = 1
        mem[732] = 32'h08B52023; // COMMIT L1 F0 C3 T1 = 41
        mem[733] = 32'h00000593; // x11 = 0
        mem[734] = 32'h06B52823; // L1 weight filter = 0
        mem[735] = 32'h00300593; // x11 = 3
        mem[736] = 32'h06B52A23; // L1 weight channel = 3
        mem[737] = 32'h00200593; // x11 = 2
        mem[738] = 32'h06B52C23; // L1 weight tap = 2
        mem[739] = 32'h00E00593; // x11 = 14
        mem[740] = 32'h06B52E23; // L1 weight data = 14
        mem[741] = 32'h00100593; // x11 = 1
        mem[742] = 32'h08B52023; // COMMIT L1 F0 C3 T2 = 14
        mem[743] = 32'h00000593; // x11 = 0
        mem[744] = 32'h06B52823; // L1 weight filter = 0
        mem[745] = 32'h00300593; // x11 = 3
        mem[746] = 32'h06B52A23; // L1 weight channel = 3
        mem[747] = 32'h00300593; // x11 = 3
        mem[748] = 32'h06B52C23; // L1 weight tap = 3
        mem[749] = 32'hFF100593; // x11 = -15
        mem[750] = 32'h06B52E23; // L1 weight data = -15
        mem[751] = 32'h00100593; // x11 = 1
        mem[752] = 32'h08B52023; // COMMIT L1 F0 C3 T3 = -15
        mem[753] = 32'h00000593; // x11 = 0
        mem[754] = 32'h06B52823; // L1 weight filter = 0
        mem[755] = 32'h00300593; // x11 = 3
        mem[756] = 32'h06B52A23; // L1 weight channel = 3
        mem[757] = 32'h00400593; // x11 = 4
        mem[758] = 32'h06B52C23; // L1 weight tap = 4
        mem[759] = 32'h02800593; // x11 = 40
        mem[760] = 32'h06B52E23; // L1 weight data = 40
        mem[761] = 32'h00100593; // x11 = 1
        mem[762] = 32'h08B52023; // COMMIT L1 F0 C3 T4 = 40
        mem[763] = 32'h00000593; // x11 = 0
        mem[764] = 32'h06B52823; // L1 weight filter = 0
        mem[765] = 32'h00300593; // x11 = 3
        mem[766] = 32'h06B52A23; // L1 weight channel = 3
        mem[767] = 32'h00500593; // x11 = 5
        mem[768] = 32'h06B52C23; // L1 weight tap = 5
        mem[769] = 32'hFF600593; // x11 = -10
        mem[770] = 32'h06B52E23; // L1 weight data = -10
        mem[771] = 32'h00100593; // x11 = 1
        mem[772] = 32'h08B52023; // COMMIT L1 F0 C3 T5 = -10
        mem[773] = 32'h00000593; // x11 = 0
        mem[774] = 32'h06B52823; // L1 weight filter = 0
        mem[775] = 32'h00300593; // x11 = 3
        mem[776] = 32'h06B52A23; // L1 weight channel = 3
        mem[777] = 32'h00600593; // x11 = 6
        mem[778] = 32'h06B52C23; // L1 weight tap = 6
        mem[779] = 32'hFE500593; // x11 = -27
        mem[780] = 32'h06B52E23; // L1 weight data = -27
        mem[781] = 32'h00100593; // x11 = 1
        mem[782] = 32'h08B52023; // COMMIT L1 F0 C3 T6 = -27
        mem[783] = 32'h00000593; // x11 = 0
        mem[784] = 32'h06B52823; // L1 weight filter = 0
        mem[785] = 32'h00300593; // x11 = 3
        mem[786] = 32'h06B52A23; // L1 weight channel = 3
        mem[787] = 32'h00700593; // x11 = 7
        mem[788] = 32'h06B52C23; // L1 weight tap = 7
        mem[789] = 32'h01000593; // x11 = 16
        mem[790] = 32'h06B52E23; // L1 weight data = 16
        mem[791] = 32'h00100593; // x11 = 1
        mem[792] = 32'h08B52023; // COMMIT L1 F0 C3 T7 = 16
        mem[793] = 32'h00000593; // x11 = 0
        mem[794] = 32'h06B52823; // L1 weight filter = 0
        mem[795] = 32'h00300593; // x11 = 3
        mem[796] = 32'h06B52A23; // L1 weight channel = 3
        mem[797] = 32'h00800593; // x11 = 8
        mem[798] = 32'h06B52C23; // L1 weight tap = 8
        mem[799] = 32'h01500593; // x11 = 21
        mem[800] = 32'h06B52E23; // L1 weight data = 21
        mem[801] = 32'h00100593; // x11 = 1
        mem[802] = 32'h08B52023; // COMMIT L1 F0 C3 T8 = 21
        mem[803] = 32'h00100593; // x11 = 1
        mem[804] = 32'h06B52823; // L1 weight filter = 1
        mem[805] = 32'h00000593; // x11 = 0
        mem[806] = 32'h06B52A23; // L1 weight channel = 0
        mem[807] = 32'h00000593; // x11 = 0
        mem[808] = 32'h06B52C23; // L1 weight tap = 0
        mem[809] = 32'h02000593; // x11 = 32
        mem[810] = 32'h06B52E23; // L1 weight data = 32
        mem[811] = 32'h00100593; // x11 = 1
        mem[812] = 32'h08B52023; // COMMIT L1 F1 C0 T0 = 32
        mem[813] = 32'h00100593; // x11 = 1
        mem[814] = 32'h06B52823; // L1 weight filter = 1
        mem[815] = 32'h00000593; // x11 = 0
        mem[816] = 32'h06B52A23; // L1 weight channel = 0
        mem[817] = 32'h00100593; // x11 = 1
        mem[818] = 32'h06B52C23; // L1 weight tap = 1
        mem[819] = 32'hFE600593; // x11 = -26
        mem[820] = 32'h06B52E23; // L1 weight data = -26
        mem[821] = 32'h00100593; // x11 = 1
        mem[822] = 32'h08B52023; // COMMIT L1 F1 C0 T1 = -26
        mem[823] = 32'h00100593; // x11 = 1
        mem[824] = 32'h06B52823; // L1 weight filter = 1
        mem[825] = 32'h00000593; // x11 = 0
        mem[826] = 32'h06B52A23; // L1 weight channel = 0
        mem[827] = 32'h00200593; // x11 = 2
        mem[828] = 32'h06B52C23; // L1 weight tap = 2
        mem[829] = 32'hFEC00593; // x11 = -20
        mem[830] = 32'h06B52E23; // L1 weight data = -20
        mem[831] = 32'h00100593; // x11 = 1
        mem[832] = 32'h08B52023; // COMMIT L1 F1 C0 T2 = -20
        mem[833] = 32'h00100593; // x11 = 1
        mem[834] = 32'h06B52823; // L1 weight filter = 1
        mem[835] = 32'h00000593; // x11 = 0
        mem[836] = 32'h06B52A23; // L1 weight channel = 0
        mem[837] = 32'h00300593; // x11 = 3
        mem[838] = 32'h06B52C23; // L1 weight tap = 3
        mem[839] = 32'h04200593; // x11 = 66
        mem[840] = 32'h06B52E23; // L1 weight data = 66
        mem[841] = 32'h00100593; // x11 = 1
        mem[842] = 32'h08B52023; // COMMIT L1 F1 C0 T3 = 66
        mem[843] = 32'h00100593; // x11 = 1
        mem[844] = 32'h06B52823; // L1 weight filter = 1
        mem[845] = 32'h00000593; // x11 = 0
        mem[846] = 32'h06B52A23; // L1 weight channel = 0
        mem[847] = 32'h00400593; // x11 = 4
        mem[848] = 32'h06B52C23; // L1 weight tap = 4
        mem[849] = 32'h01600593; // x11 = 22
        mem[850] = 32'h06B52E23; // L1 weight data = 22
        mem[851] = 32'h00100593; // x11 = 1
        mem[852] = 32'h08B52023; // COMMIT L1 F1 C0 T4 = 22
        mem[853] = 32'h00100593; // x11 = 1
        mem[854] = 32'h06B52823; // L1 weight filter = 1
        mem[855] = 32'h00000593; // x11 = 0
        mem[856] = 32'h06B52A23; // L1 weight channel = 0
        mem[857] = 32'h00500593; // x11 = 5
        mem[858] = 32'h06B52C23; // L1 weight tap = 5
        mem[859] = 32'h03600593; // x11 = 54
        mem[860] = 32'h06B52E23; // L1 weight data = 54
        mem[861] = 32'h00100593; // x11 = 1
        mem[862] = 32'h08B52023; // COMMIT L1 F1 C0 T5 = 54
        mem[863] = 32'h00100593; // x11 = 1
        mem[864] = 32'h06B52823; // L1 weight filter = 1
        mem[865] = 32'h00000593; // x11 = 0
        mem[866] = 32'h06B52A23; // L1 weight channel = 0
        mem[867] = 32'h00600593; // x11 = 6
        mem[868] = 32'h06B52C23; // L1 weight tap = 6
        mem[869] = 32'hFD500593; // x11 = -43
        mem[870] = 32'h06B52E23; // L1 weight data = -43
        mem[871] = 32'h00100593; // x11 = 1
        mem[872] = 32'h08B52023; // COMMIT L1 F1 C0 T6 = -43
        mem[873] = 32'h00100593; // x11 = 1
        mem[874] = 32'h06B52823; // L1 weight filter = 1
        mem[875] = 32'h00000593; // x11 = 0
        mem[876] = 32'h06B52A23; // L1 weight channel = 0
        mem[877] = 32'h00700593; // x11 = 7
        mem[878] = 32'h06B52C23; // L1 weight tap = 7
        mem[879] = 32'hF8E00593; // x11 = -114
        mem[880] = 32'h06B52E23; // L1 weight data = -114
        mem[881] = 32'h00100593; // x11 = 1
        mem[882] = 32'h08B52023; // COMMIT L1 F1 C0 T7 = -114
        mem[883] = 32'h00100593; // x11 = 1
        mem[884] = 32'h06B52823; // L1 weight filter = 1
        mem[885] = 32'h00000593; // x11 = 0
        mem[886] = 32'h06B52A23; // L1 weight channel = 0
        mem[887] = 32'h00800593; // x11 = 8
        mem[888] = 32'h06B52C23; // L1 weight tap = 8
        mem[889] = 32'hFB700593; // x11 = -73
        mem[890] = 32'h06B52E23; // L1 weight data = -73
        mem[891] = 32'h00100593; // x11 = 1
        mem[892] = 32'h08B52023; // COMMIT L1 F1 C0 T8 = -73
        mem[893] = 32'h00100593; // x11 = 1
        mem[894] = 32'h06B52823; // L1 weight filter = 1
        mem[895] = 32'h00100593; // x11 = 1
        mem[896] = 32'h06B52A23; // L1 weight channel = 1
        mem[897] = 32'h00000593; // x11 = 0
        mem[898] = 32'h06B52C23; // L1 weight tap = 0
        mem[899] = 32'h00700593; // x11 = 7
        mem[900] = 32'h06B52E23; // L1 weight data = 7
        mem[901] = 32'h00100593; // x11 = 1
        mem[902] = 32'h08B52023; // COMMIT L1 F1 C1 T0 = 7
        mem[903] = 32'h00100593; // x11 = 1
        mem[904] = 32'h06B52823; // L1 weight filter = 1
        mem[905] = 32'h00100593; // x11 = 1
        mem[906] = 32'h06B52A23; // L1 weight channel = 1
        mem[907] = 32'h00100593; // x11 = 1
        mem[908] = 32'h06B52C23; // L1 weight tap = 1
        mem[909] = 32'h01F00593; // x11 = 31
        mem[910] = 32'h06B52E23; // L1 weight data = 31
        mem[911] = 32'h00100593; // x11 = 1
        mem[912] = 32'h08B52023; // COMMIT L1 F1 C1 T1 = 31
        mem[913] = 32'h00100593; // x11 = 1
        mem[914] = 32'h06B52823; // L1 weight filter = 1
        mem[915] = 32'h00100593; // x11 = 1
        mem[916] = 32'h06B52A23; // L1 weight channel = 1
        mem[917] = 32'h00200593; // x11 = 2
        mem[918] = 32'h06B52C23; // L1 weight tap = 2
        mem[919] = 32'hFF500593; // x11 = -11
        mem[920] = 32'h06B52E23; // L1 weight data = -11
        mem[921] = 32'h00100593; // x11 = 1
        mem[922] = 32'h08B52023; // COMMIT L1 F1 C1 T2 = -11
        mem[923] = 32'h00100593; // x11 = 1
        mem[924] = 32'h06B52823; // L1 weight filter = 1
        mem[925] = 32'h00100593; // x11 = 1
        mem[926] = 32'h06B52A23; // L1 weight channel = 1
        mem[927] = 32'h00300593; // x11 = 3
        mem[928] = 32'h06B52C23; // L1 weight tap = 3
        mem[929] = 32'hFEF00593; // x11 = -17
        mem[930] = 32'h06B52E23; // L1 weight data = -17
        mem[931] = 32'h00100593; // x11 = 1
        mem[932] = 32'h08B52023; // COMMIT L1 F1 C1 T3 = -17
        mem[933] = 32'h00100593; // x11 = 1
        mem[934] = 32'h06B52823; // L1 weight filter = 1
        mem[935] = 32'h00100593; // x11 = 1
        mem[936] = 32'h06B52A23; // L1 weight channel = 1
        mem[937] = 32'h00400593; // x11 = 4
        mem[938] = 32'h06B52C23; // L1 weight tap = 4
        mem[939] = 32'hFF600593; // x11 = -10
        mem[940] = 32'h06B52E23; // L1 weight data = -10
        mem[941] = 32'h00100593; // x11 = 1
        mem[942] = 32'h08B52023; // COMMIT L1 F1 C1 T4 = -10
        mem[943] = 32'h00100593; // x11 = 1
        mem[944] = 32'h06B52823; // L1 weight filter = 1
        mem[945] = 32'h00100593; // x11 = 1
        mem[946] = 32'h06B52A23; // L1 weight channel = 1
        mem[947] = 32'h00500593; // x11 = 5
        mem[948] = 32'h06B52C23; // L1 weight tap = 5
        mem[949] = 32'h01300593; // x11 = 19
        mem[950] = 32'h06B52E23; // L1 weight data = 19
        mem[951] = 32'h00100593; // x11 = 1
        mem[952] = 32'h08B52023; // COMMIT L1 F1 C1 T5 = 19
        mem[953] = 32'h00100593; // x11 = 1
        mem[954] = 32'h06B52823; // L1 weight filter = 1
        mem[955] = 32'h00100593; // x11 = 1
        mem[956] = 32'h06B52A23; // L1 weight channel = 1
        mem[957] = 32'h00600593; // x11 = 6
        mem[958] = 32'h06B52C23; // L1 weight tap = 6
        mem[959] = 32'h00700593; // x11 = 7
        mem[960] = 32'h06B52E23; // L1 weight data = 7
        mem[961] = 32'h00100593; // x11 = 1
        mem[962] = 32'h08B52023; // COMMIT L1 F1 C1 T6 = 7
        mem[963] = 32'h00100593; // x11 = 1
        mem[964] = 32'h06B52823; // L1 weight filter = 1
        mem[965] = 32'h00100593; // x11 = 1
        mem[966] = 32'h06B52A23; // L1 weight channel = 1
        mem[967] = 32'h00700593; // x11 = 7
        mem[968] = 32'h06B52C23; // L1 weight tap = 7
        mem[969] = 32'hFF500593; // x11 = -11
        mem[970] = 32'h06B52E23; // L1 weight data = -11
        mem[971] = 32'h00100593; // x11 = 1
        mem[972] = 32'h08B52023; // COMMIT L1 F1 C1 T7 = -11
        mem[973] = 32'h00100593; // x11 = 1
        mem[974] = 32'h06B52823; // L1 weight filter = 1
        mem[975] = 32'h00100593; // x11 = 1
        mem[976] = 32'h06B52A23; // L1 weight channel = 1
        mem[977] = 32'h00800593; // x11 = 8
        mem[978] = 32'h06B52C23; // L1 weight tap = 8
        mem[979] = 32'h00A00593; // x11 = 10
        mem[980] = 32'h06B52E23; // L1 weight data = 10
        mem[981] = 32'h00100593; // x11 = 1
        mem[982] = 32'h08B52023; // COMMIT L1 F1 C1 T8 = 10
        mem[983] = 32'h00100593; // x11 = 1
        mem[984] = 32'h06B52823; // L1 weight filter = 1
        mem[985] = 32'h00200593; // x11 = 2
        mem[986] = 32'h06B52A23; // L1 weight channel = 2
        mem[987] = 32'h00000593; // x11 = 0
        mem[988] = 32'h06B52C23; // L1 weight tap = 0
        mem[989] = 32'hFFB00593; // x11 = -5
        mem[990] = 32'h06B52E23; // L1 weight data = -5
        mem[991] = 32'h00100593; // x11 = 1
        mem[992] = 32'h08B52023; // COMMIT L1 F1 C2 T0 = -5
        mem[993] = 32'h00100593; // x11 = 1
        mem[994] = 32'h06B52823; // L1 weight filter = 1
        mem[995] = 32'h00200593; // x11 = 2
        mem[996] = 32'h06B52A23; // L1 weight channel = 2
        mem[997] = 32'h00100593; // x11 = 1
        mem[998] = 32'h06B52C23; // L1 weight tap = 1
        mem[999] = 32'h01600593; // x11 = 22
        mem[1000] = 32'h06B52E23; // L1 weight data = 22
        mem[1001] = 32'h00100593; // x11 = 1
        mem[1002] = 32'h08B52023; // COMMIT L1 F1 C2 T1 = 22
        mem[1003] = 32'h00100593; // x11 = 1
        mem[1004] = 32'h06B52823; // L1 weight filter = 1
        mem[1005] = 32'h00200593; // x11 = 2
        mem[1006] = 32'h06B52A23; // L1 weight channel = 2
        mem[1007] = 32'h00200593; // x11 = 2
        mem[1008] = 32'h06B52C23; // L1 weight tap = 2
        mem[1009] = 32'hFEA00593; // x11 = -22
        mem[1010] = 32'h06B52E23; // L1 weight data = -22
        mem[1011] = 32'h00100593; // x11 = 1
        mem[1012] = 32'h08B52023; // COMMIT L1 F1 C2 T2 = -22
        mem[1013] = 32'h00100593; // x11 = 1
        mem[1014] = 32'h06B52823; // L1 weight filter = 1
        mem[1015] = 32'h00200593; // x11 = 2
        mem[1016] = 32'h06B52A23; // L1 weight channel = 2
        mem[1017] = 32'h00300593; // x11 = 3
        mem[1018] = 32'h06B52C23; // L1 weight tap = 3
        mem[1019] = 32'h00A00593; // x11 = 10
        mem[1020] = 32'h06B52E23; // L1 weight data = 10
        mem[1021] = 32'h00100593; // x11 = 1
        mem[1022] = 32'h08B52023; // COMMIT L1 F1 C2 T3 = 10
        mem[1023] = 32'h00100593; // x11 = 1
        mem[1024] = 32'h06B52823; // L1 weight filter = 1
        mem[1025] = 32'h00200593; // x11 = 2
        mem[1026] = 32'h06B52A23; // L1 weight channel = 2
        mem[1027] = 32'h00400593; // x11 = 4
        mem[1028] = 32'h06B52C23; // L1 weight tap = 4
        mem[1029] = 32'hFEE00593; // x11 = -18
        mem[1030] = 32'h06B52E23; // L1 weight data = -18
        mem[1031] = 32'h00100593; // x11 = 1
        mem[1032] = 32'h08B52023; // COMMIT L1 F1 C2 T4 = -18
        mem[1033] = 32'h00100593; // x11 = 1
        mem[1034] = 32'h06B52823; // L1 weight filter = 1
        mem[1035] = 32'h00200593; // x11 = 2
        mem[1036] = 32'h06B52A23; // L1 weight channel = 2
        mem[1037] = 32'h00500593; // x11 = 5
        mem[1038] = 32'h06B52C23; // L1 weight tap = 5
        mem[1039] = 32'hFE100593; // x11 = -31
        mem[1040] = 32'h06B52E23; // L1 weight data = -31
        mem[1041] = 32'h00100593; // x11 = 1
        mem[1042] = 32'h08B52023; // COMMIT L1 F1 C2 T5 = -31
        mem[1043] = 32'h00100593; // x11 = 1
        mem[1044] = 32'h06B52823; // L1 weight filter = 1
        mem[1045] = 32'h00200593; // x11 = 2
        mem[1046] = 32'h06B52A23; // L1 weight channel = 2
        mem[1047] = 32'h00600593; // x11 = 6
        mem[1048] = 32'h06B52C23; // L1 weight tap = 6
        mem[1049] = 32'h01200593; // x11 = 18
        mem[1050] = 32'h06B52E23; // L1 weight data = 18
        mem[1051] = 32'h00100593; // x11 = 1
        mem[1052] = 32'h08B52023; // COMMIT L1 F1 C2 T6 = 18
        mem[1053] = 32'h00100593; // x11 = 1
        mem[1054] = 32'h06B52823; // L1 weight filter = 1
        mem[1055] = 32'h00200593; // x11 = 2
        mem[1056] = 32'h06B52A23; // L1 weight channel = 2
        mem[1057] = 32'h00700593; // x11 = 7
        mem[1058] = 32'h06B52C23; // L1 weight tap = 7
        mem[1059] = 32'hFF400593; // x11 = -12
        mem[1060] = 32'h06B52E23; // L1 weight data = -12
        mem[1061] = 32'h00100593; // x11 = 1
        mem[1062] = 32'h08B52023; // COMMIT L1 F1 C2 T7 = -12
        mem[1063] = 32'h00100593; // x11 = 1
        mem[1064] = 32'h06B52823; // L1 weight filter = 1
        mem[1065] = 32'h00200593; // x11 = 2
        mem[1066] = 32'h06B52A23; // L1 weight channel = 2
        mem[1067] = 32'h00800593; // x11 = 8
        mem[1068] = 32'h06B52C23; // L1 weight tap = 8
        mem[1069] = 32'hFFB00593; // x11 = -5
        mem[1070] = 32'h06B52E23; // L1 weight data = -5
        mem[1071] = 32'h00100593; // x11 = 1
        mem[1072] = 32'h08B52023; // COMMIT L1 F1 C2 T8 = -5
        mem[1073] = 32'h00100593; // x11 = 1
        mem[1074] = 32'h06B52823; // L1 weight filter = 1
        mem[1075] = 32'h00300593; // x11 = 3
        mem[1076] = 32'h06B52A23; // L1 weight channel = 3
        mem[1077] = 32'h00000593; // x11 = 0
        mem[1078] = 32'h06B52C23; // L1 weight tap = 0
        mem[1079] = 32'hFF000593; // x11 = -16
        mem[1080] = 32'h06B52E23; // L1 weight data = -16
        mem[1081] = 32'h00100593; // x11 = 1
        mem[1082] = 32'h08B52023; // COMMIT L1 F1 C3 T0 = -16
        mem[1083] = 32'h00100593; // x11 = 1
        mem[1084] = 32'h06B52823; // L1 weight filter = 1
        mem[1085] = 32'h00300593; // x11 = 3
        mem[1086] = 32'h06B52A23; // L1 weight channel = 3
        mem[1087] = 32'h00100593; // x11 = 1
        mem[1088] = 32'h06B52C23; // L1 weight tap = 1
        mem[1089] = 32'hFD000593; // x11 = -48
        mem[1090] = 32'h06B52E23; // L1 weight data = -48
        mem[1091] = 32'h00100593; // x11 = 1
        mem[1092] = 32'h08B52023; // COMMIT L1 F1 C3 T1 = -48
        mem[1093] = 32'h00100593; // x11 = 1
        mem[1094] = 32'h06B52823; // L1 weight filter = 1
        mem[1095] = 32'h00300593; // x11 = 3
        mem[1096] = 32'h06B52A23; // L1 weight channel = 3
        mem[1097] = 32'h00200593; // x11 = 2
        mem[1098] = 32'h06B52C23; // L1 weight tap = 2
        mem[1099] = 32'hFF600593; // x11 = -10
        mem[1100] = 32'h06B52E23; // L1 weight data = -10
        mem[1101] = 32'h00100593; // x11 = 1
        mem[1102] = 32'h08B52023; // COMMIT L1 F1 C3 T2 = -10
        mem[1103] = 32'h00100593; // x11 = 1
        mem[1104] = 32'h06B52823; // L1 weight filter = 1
        mem[1105] = 32'h00300593; // x11 = 3
        mem[1106] = 32'h06B52A23; // L1 weight channel = 3
        mem[1107] = 32'h00300593; // x11 = 3
        mem[1108] = 32'h06B52C23; // L1 weight tap = 3
        mem[1109] = 32'hFF000593; // x11 = -16
        mem[1110] = 32'h06B52E23; // L1 weight data = -16
        mem[1111] = 32'h00100593; // x11 = 1
        mem[1112] = 32'h08B52023; // COMMIT L1 F1 C3 T3 = -16
        mem[1113] = 32'h00100593; // x11 = 1
        mem[1114] = 32'h06B52823; // L1 weight filter = 1
        mem[1115] = 32'h00300593; // x11 = 3
        mem[1116] = 32'h06B52A23; // L1 weight channel = 3
        mem[1117] = 32'h00400593; // x11 = 4
        mem[1118] = 32'h06B52C23; // L1 weight tap = 4
        mem[1119] = 32'hFE100593; // x11 = -31
        mem[1120] = 32'h06B52E23; // L1 weight data = -31
        mem[1121] = 32'h00100593; // x11 = 1
        mem[1122] = 32'h08B52023; // COMMIT L1 F1 C3 T4 = -31
        mem[1123] = 32'h00100593; // x11 = 1
        mem[1124] = 32'h06B52823; // L1 weight filter = 1
        mem[1125] = 32'h00300593; // x11 = 3
        mem[1126] = 32'h06B52A23; // L1 weight channel = 3
        mem[1127] = 32'h00500593; // x11 = 5
        mem[1128] = 32'h06B52C23; // L1 weight tap = 5
        mem[1129] = 32'hFFD00593; // x11 = -3
        mem[1130] = 32'h06B52E23; // L1 weight data = -3
        mem[1131] = 32'h00100593; // x11 = 1
        mem[1132] = 32'h08B52023; // COMMIT L1 F1 C3 T5 = -3
        mem[1133] = 32'h00100593; // x11 = 1
        mem[1134] = 32'h06B52823; // L1 weight filter = 1
        mem[1135] = 32'h00300593; // x11 = 3
        mem[1136] = 32'h06B52A23; // L1 weight channel = 3
        mem[1137] = 32'h00600593; // x11 = 6
        mem[1138] = 32'h06B52C23; // L1 weight tap = 6
        mem[1139] = 32'hFF800593; // x11 = -8
        mem[1140] = 32'h06B52E23; // L1 weight data = -8
        mem[1141] = 32'h00100593; // x11 = 1
        mem[1142] = 32'h08B52023; // COMMIT L1 F1 C3 T6 = -8
        mem[1143] = 32'h00100593; // x11 = 1
        mem[1144] = 32'h06B52823; // L1 weight filter = 1
        mem[1145] = 32'h00300593; // x11 = 3
        mem[1146] = 32'h06B52A23; // L1 weight channel = 3
        mem[1147] = 32'h00700593; // x11 = 7
        mem[1148] = 32'h06B52C23; // L1 weight tap = 7
        mem[1149] = 32'h01500593; // x11 = 21
        mem[1150] = 32'h06B52E23; // L1 weight data = 21
        mem[1151] = 32'h00100593; // x11 = 1
        mem[1152] = 32'h08B52023; // COMMIT L1 F1 C3 T7 = 21
        mem[1153] = 32'h00100593; // x11 = 1
        mem[1154] = 32'h06B52823; // L1 weight filter = 1
        mem[1155] = 32'h00300593; // x11 = 3
        mem[1156] = 32'h06B52A23; // L1 weight channel = 3
        mem[1157] = 32'h00800593; // x11 = 8
        mem[1158] = 32'h06B52C23; // L1 weight tap = 8
        mem[1159] = 32'hFF800593; // x11 = -8
        mem[1160] = 32'h06B52E23; // L1 weight data = -8
        mem[1161] = 32'h00100593; // x11 = 1
        mem[1162] = 32'h08B52023; // COMMIT L1 F1 C3 T8 = -8
        mem[1163] = 32'h00200593; // x11 = 2
        mem[1164] = 32'h06B52823; // L1 weight filter = 2
        mem[1165] = 32'h00000593; // x11 = 0
        mem[1166] = 32'h06B52A23; // L1 weight channel = 0
        mem[1167] = 32'h00000593; // x11 = 0
        mem[1168] = 32'h06B52C23; // L1 weight tap = 0
        mem[1169] = 32'h05000593; // x11 = 80
        mem[1170] = 32'h06B52E23; // L1 weight data = 80
        mem[1171] = 32'h00100593; // x11 = 1
        mem[1172] = 32'h08B52023; // COMMIT L1 F2 C0 T0 = 80
        mem[1173] = 32'h00200593; // x11 = 2
        mem[1174] = 32'h06B52823; // L1 weight filter = 2
        mem[1175] = 32'h00000593; // x11 = 0
        mem[1176] = 32'h06B52A23; // L1 weight channel = 0
        mem[1177] = 32'h00100593; // x11 = 1
        mem[1178] = 32'h06B52C23; // L1 weight tap = 1
        mem[1179] = 32'h01D00593; // x11 = 29
        mem[1180] = 32'h06B52E23; // L1 weight data = 29
        mem[1181] = 32'h00100593; // x11 = 1
        mem[1182] = 32'h08B52023; // COMMIT L1 F2 C0 T1 = 29
        mem[1183] = 32'h00200593; // x11 = 2
        mem[1184] = 32'h06B52823; // L1 weight filter = 2
        mem[1185] = 32'h00000593; // x11 = 0
        mem[1186] = 32'h06B52A23; // L1 weight channel = 0
        mem[1187] = 32'h00200593; // x11 = 2
        mem[1188] = 32'h06B52C23; // L1 weight tap = 2
        mem[1189] = 32'hF8100593; // x11 = -127
        mem[1190] = 32'h06B52E23; // L1 weight data = -127
        mem[1191] = 32'h00100593; // x11 = 1
        mem[1192] = 32'h08B52023; // COMMIT L1 F2 C0 T2 = -127
        mem[1193] = 32'h00200593; // x11 = 2
        mem[1194] = 32'h06B52823; // L1 weight filter = 2
        mem[1195] = 32'h00000593; // x11 = 0
        mem[1196] = 32'h06B52A23; // L1 weight channel = 0
        mem[1197] = 32'h00300593; // x11 = 3
        mem[1198] = 32'h06B52C23; // L1 weight tap = 3
        mem[1199] = 32'hFFA00593; // x11 = -6
        mem[1200] = 32'h06B52E23; // L1 weight data = -6
        mem[1201] = 32'h00100593; // x11 = 1
        mem[1202] = 32'h08B52023; // COMMIT L1 F2 C0 T3 = -6
        mem[1203] = 32'h00200593; // x11 = 2
        mem[1204] = 32'h06B52823; // L1 weight filter = 2
        mem[1205] = 32'h00000593; // x11 = 0
        mem[1206] = 32'h06B52A23; // L1 weight channel = 0
        mem[1207] = 32'h00400593; // x11 = 4
        mem[1208] = 32'h06B52C23; // L1 weight tap = 4
        mem[1209] = 32'hFFD00593; // x11 = -3
        mem[1210] = 32'h06B52E23; // L1 weight data = -3
        mem[1211] = 32'h00100593; // x11 = 1
        mem[1212] = 32'h08B52023; // COMMIT L1 F2 C0 T4 = -3
        mem[1213] = 32'h00200593; // x11 = 2
        mem[1214] = 32'h06B52823; // L1 weight filter = 2
        mem[1215] = 32'h00000593; // x11 = 0
        mem[1216] = 32'h06B52A23; // L1 weight channel = 0
        mem[1217] = 32'h00500593; // x11 = 5
        mem[1218] = 32'h06B52C23; // L1 weight tap = 5
        mem[1219] = 32'h00800593; // x11 = 8
        mem[1220] = 32'h06B52E23; // L1 weight data = 8
        mem[1221] = 32'h00100593; // x11 = 1
        mem[1222] = 32'h08B52023; // COMMIT L1 F2 C0 T5 = 8
        mem[1223] = 32'h00200593; // x11 = 2
        mem[1224] = 32'h06B52823; // L1 weight filter = 2
        mem[1225] = 32'h00000593; // x11 = 0
        mem[1226] = 32'h06B52A23; // L1 weight channel = 0
        mem[1227] = 32'h00600593; // x11 = 6
        mem[1228] = 32'h06B52C23; // L1 weight tap = 6
        mem[1229] = 32'hFD600593; // x11 = -42
        mem[1230] = 32'h06B52E23; // L1 weight data = -42
        mem[1231] = 32'h00100593; // x11 = 1
        mem[1232] = 32'h08B52023; // COMMIT L1 F2 C0 T6 = -42
        mem[1233] = 32'h00200593; // x11 = 2
        mem[1234] = 32'h06B52823; // L1 weight filter = 2
        mem[1235] = 32'h00000593; // x11 = 0
        mem[1236] = 32'h06B52A23; // L1 weight channel = 0
        mem[1237] = 32'h00700593; // x11 = 7
        mem[1238] = 32'h06B52C23; // L1 weight tap = 7
        mem[1239] = 32'hFB000593; // x11 = -80
        mem[1240] = 32'h06B52E23; // L1 weight data = -80
        mem[1241] = 32'h00100593; // x11 = 1
        mem[1242] = 32'h08B52023; // COMMIT L1 F2 C0 T7 = -80
        mem[1243] = 32'h00200593; // x11 = 2
        mem[1244] = 32'h06B52823; // L1 weight filter = 2
        mem[1245] = 32'h00000593; // x11 = 0
        mem[1246] = 32'h06B52A23; // L1 weight channel = 0
        mem[1247] = 32'h00800593; // x11 = 8
        mem[1248] = 32'h06B52C23; // L1 weight tap = 8
        mem[1249] = 32'h03100593; // x11 = 49
        mem[1250] = 32'h06B52E23; // L1 weight data = 49
        mem[1251] = 32'h00100593; // x11 = 1
        mem[1252] = 32'h08B52023; // COMMIT L1 F2 C0 T8 = 49
        mem[1253] = 32'h00200593; // x11 = 2
        mem[1254] = 32'h06B52823; // L1 weight filter = 2
        mem[1255] = 32'h00100593; // x11 = 1
        mem[1256] = 32'h06B52A23; // L1 weight channel = 1
        mem[1257] = 32'h00000593; // x11 = 0
        mem[1258] = 32'h06B52C23; // L1 weight tap = 0
        mem[1259] = 32'hFE800593; // x11 = -24
        mem[1260] = 32'h06B52E23; // L1 weight data = -24
        mem[1261] = 32'h00100593; // x11 = 1
        mem[1262] = 32'h08B52023; // COMMIT L1 F2 C1 T0 = -24
        mem[1263] = 32'h00200593; // x11 = 2
        mem[1264] = 32'h06B52823; // L1 weight filter = 2
        mem[1265] = 32'h00100593; // x11 = 1
        mem[1266] = 32'h06B52A23; // L1 weight channel = 1
        mem[1267] = 32'h00100593; // x11 = 1
        mem[1268] = 32'h06B52C23; // L1 weight tap = 1
        mem[1269] = 32'h01800593; // x11 = 24
        mem[1270] = 32'h06B52E23; // L1 weight data = 24
        mem[1271] = 32'h00100593; // x11 = 1
        mem[1272] = 32'h08B52023; // COMMIT L1 F2 C1 T1 = 24
        mem[1273] = 32'h00200593; // x11 = 2
        mem[1274] = 32'h06B52823; // L1 weight filter = 2
        mem[1275] = 32'h00100593; // x11 = 1
        mem[1276] = 32'h06B52A23; // L1 weight channel = 1
        mem[1277] = 32'h00200593; // x11 = 2
        mem[1278] = 32'h06B52C23; // L1 weight tap = 2
        mem[1279] = 32'h00F00593; // x11 = 15
        mem[1280] = 32'h06B52E23; // L1 weight data = 15
        mem[1281] = 32'h00100593; // x11 = 1
        mem[1282] = 32'h08B52023; // COMMIT L1 F2 C1 T2 = 15
        mem[1283] = 32'h00200593; // x11 = 2
        mem[1284] = 32'h06B52823; // L1 weight filter = 2
        mem[1285] = 32'h00100593; // x11 = 1
        mem[1286] = 32'h06B52A23; // L1 weight channel = 1
        mem[1287] = 32'h00300593; // x11 = 3
        mem[1288] = 32'h06B52C23; // L1 weight tap = 3
        mem[1289] = 32'h01000593; // x11 = 16
        mem[1290] = 32'h06B52E23; // L1 weight data = 16
        mem[1291] = 32'h00100593; // x11 = 1
        mem[1292] = 32'h08B52023; // COMMIT L1 F2 C1 T3 = 16
        mem[1293] = 32'h00200593; // x11 = 2
        mem[1294] = 32'h06B52823; // L1 weight filter = 2
        mem[1295] = 32'h00100593; // x11 = 1
        mem[1296] = 32'h06B52A23; // L1 weight channel = 1
        mem[1297] = 32'h00400593; // x11 = 4
        mem[1298] = 32'h06B52C23; // L1 weight tap = 4
        mem[1299] = 32'hFED00593; // x11 = -19
        mem[1300] = 32'h06B52E23; // L1 weight data = -19
        mem[1301] = 32'h00100593; // x11 = 1
        mem[1302] = 32'h08B52023; // COMMIT L1 F2 C1 T4 = -19
        mem[1303] = 32'h00200593; // x11 = 2
        mem[1304] = 32'h06B52823; // L1 weight filter = 2
        mem[1305] = 32'h00100593; // x11 = 1
        mem[1306] = 32'h06B52A23; // L1 weight channel = 1
        mem[1307] = 32'h00500593; // x11 = 5
        mem[1308] = 32'h06B52C23; // L1 weight tap = 5
        mem[1309] = 32'h01D00593; // x11 = 29
        mem[1310] = 32'h06B52E23; // L1 weight data = 29
        mem[1311] = 32'h00100593; // x11 = 1
        mem[1312] = 32'h08B52023; // COMMIT L1 F2 C1 T5 = 29
        mem[1313] = 32'h00200593; // x11 = 2
        mem[1314] = 32'h06B52823; // L1 weight filter = 2
        mem[1315] = 32'h00100593; // x11 = 1
        mem[1316] = 32'h06B52A23; // L1 weight channel = 1
        mem[1317] = 32'h00600593; // x11 = 6
        mem[1318] = 32'h06B52C23; // L1 weight tap = 6
        mem[1319] = 32'hFE300593; // x11 = -29
        mem[1320] = 32'h06B52E23; // L1 weight data = -29
        mem[1321] = 32'h00100593; // x11 = 1
        mem[1322] = 32'h08B52023; // COMMIT L1 F2 C1 T6 = -29
        mem[1323] = 32'h00200593; // x11 = 2
        mem[1324] = 32'h06B52823; // L1 weight filter = 2
        mem[1325] = 32'h00100593; // x11 = 1
        mem[1326] = 32'h06B52A23; // L1 weight channel = 1
        mem[1327] = 32'h00700593; // x11 = 7
        mem[1328] = 32'h06B52C23; // L1 weight tap = 7
        mem[1329] = 32'h00C00593; // x11 = 12
        mem[1330] = 32'h06B52E23; // L1 weight data = 12
        mem[1331] = 32'h00100593; // x11 = 1
        mem[1332] = 32'h08B52023; // COMMIT L1 F2 C1 T7 = 12
        mem[1333] = 32'h00200593; // x11 = 2
        mem[1334] = 32'h06B52823; // L1 weight filter = 2
        mem[1335] = 32'h00100593; // x11 = 1
        mem[1336] = 32'h06B52A23; // L1 weight channel = 1
        mem[1337] = 32'h00800593; // x11 = 8
        mem[1338] = 32'h06B52C23; // L1 weight tap = 8
        mem[1339] = 32'h02D00593; // x11 = 45
        mem[1340] = 32'h06B52E23; // L1 weight data = 45
        mem[1341] = 32'h00100593; // x11 = 1
        mem[1342] = 32'h08B52023; // COMMIT L1 F2 C1 T8 = 45
        mem[1343] = 32'h00200593; // x11 = 2
        mem[1344] = 32'h06B52823; // L1 weight filter = 2
        mem[1345] = 32'h00200593; // x11 = 2
        mem[1346] = 32'h06B52A23; // L1 weight channel = 2
        mem[1347] = 32'h00000593; // x11 = 0
        mem[1348] = 32'h06B52C23; // L1 weight tap = 0
        mem[1349] = 32'h00C00593; // x11 = 12
        mem[1350] = 32'h06B52E23; // L1 weight data = 12
        mem[1351] = 32'h00100593; // x11 = 1
        mem[1352] = 32'h08B52023; // COMMIT L1 F2 C2 T0 = 12
        mem[1353] = 32'h00200593; // x11 = 2
        mem[1354] = 32'h06B52823; // L1 weight filter = 2
        mem[1355] = 32'h00200593; // x11 = 2
        mem[1356] = 32'h06B52A23; // L1 weight channel = 2
        mem[1357] = 32'h00100593; // x11 = 1
        mem[1358] = 32'h06B52C23; // L1 weight tap = 1
        mem[1359] = 32'hFF500593; // x11 = -11
        mem[1360] = 32'h06B52E23; // L1 weight data = -11
        mem[1361] = 32'h00100593; // x11 = 1
        mem[1362] = 32'h08B52023; // COMMIT L1 F2 C2 T1 = -11
        mem[1363] = 32'h00200593; // x11 = 2
        mem[1364] = 32'h06B52823; // L1 weight filter = 2
        mem[1365] = 32'h00200593; // x11 = 2
        mem[1366] = 32'h06B52A23; // L1 weight channel = 2
        mem[1367] = 32'h00200593; // x11 = 2
        mem[1368] = 32'h06B52C23; // L1 weight tap = 2
        mem[1369] = 32'h00400593; // x11 = 4
        mem[1370] = 32'h06B52E23; // L1 weight data = 4
        mem[1371] = 32'h00100593; // x11 = 1
        mem[1372] = 32'h08B52023; // COMMIT L1 F2 C2 T2 = 4
        mem[1373] = 32'h00200593; // x11 = 2
        mem[1374] = 32'h06B52823; // L1 weight filter = 2
        mem[1375] = 32'h00200593; // x11 = 2
        mem[1376] = 32'h06B52A23; // L1 weight channel = 2
        mem[1377] = 32'h00300593; // x11 = 3
        mem[1378] = 32'h06B52C23; // L1 weight tap = 3
        mem[1379] = 32'h01300593; // x11 = 19
        mem[1380] = 32'h06B52E23; // L1 weight data = 19
        mem[1381] = 32'h00100593; // x11 = 1
        mem[1382] = 32'h08B52023; // COMMIT L1 F2 C2 T3 = 19
        mem[1383] = 32'h00200593; // x11 = 2
        mem[1384] = 32'h06B52823; // L1 weight filter = 2
        mem[1385] = 32'h00200593; // x11 = 2
        mem[1386] = 32'h06B52A23; // L1 weight channel = 2
        mem[1387] = 32'h00400593; // x11 = 4
        mem[1388] = 32'h06B52C23; // L1 weight tap = 4
        mem[1389] = 32'hFFE00593; // x11 = -2
        mem[1390] = 32'h06B52E23; // L1 weight data = -2
        mem[1391] = 32'h00100593; // x11 = 1
        mem[1392] = 32'h08B52023; // COMMIT L1 F2 C2 T4 = -2
        mem[1393] = 32'h00200593; // x11 = 2
        mem[1394] = 32'h06B52823; // L1 weight filter = 2
        mem[1395] = 32'h00200593; // x11 = 2
        mem[1396] = 32'h06B52A23; // L1 weight channel = 2
        mem[1397] = 32'h00500593; // x11 = 5
        mem[1398] = 32'h06B52C23; // L1 weight tap = 5
        mem[1399] = 32'hFF900593; // x11 = -7
        mem[1400] = 32'h06B52E23; // L1 weight data = -7
        mem[1401] = 32'h00100593; // x11 = 1
        mem[1402] = 32'h08B52023; // COMMIT L1 F2 C2 T5 = -7
        mem[1403] = 32'h00200593; // x11 = 2
        mem[1404] = 32'h06B52823; // L1 weight filter = 2
        mem[1405] = 32'h00200593; // x11 = 2
        mem[1406] = 32'h06B52A23; // L1 weight channel = 2
        mem[1407] = 32'h00600593; // x11 = 6
        mem[1408] = 32'h06B52C23; // L1 weight tap = 6
        mem[1409] = 32'hFFA00593; // x11 = -6
        mem[1410] = 32'h06B52E23; // L1 weight data = -6
        mem[1411] = 32'h00100593; // x11 = 1
        mem[1412] = 32'h08B52023; // COMMIT L1 F2 C2 T6 = -6
        mem[1413] = 32'h00200593; // x11 = 2
        mem[1414] = 32'h06B52823; // L1 weight filter = 2
        mem[1415] = 32'h00200593; // x11 = 2
        mem[1416] = 32'h06B52A23; // L1 weight channel = 2
        mem[1417] = 32'h00700593; // x11 = 7
        mem[1418] = 32'h06B52C23; // L1 weight tap = 7
        mem[1419] = 32'h02D00593; // x11 = 45
        mem[1420] = 32'h06B52E23; // L1 weight data = 45
        mem[1421] = 32'h00100593; // x11 = 1
        mem[1422] = 32'h08B52023; // COMMIT L1 F2 C2 T7 = 45
        mem[1423] = 32'h00200593; // x11 = 2
        mem[1424] = 32'h06B52823; // L1 weight filter = 2
        mem[1425] = 32'h00200593; // x11 = 2
        mem[1426] = 32'h06B52A23; // L1 weight channel = 2
        mem[1427] = 32'h00800593; // x11 = 8
        mem[1428] = 32'h06B52C23; // L1 weight tap = 8
        mem[1429] = 32'h00C00593; // x11 = 12
        mem[1430] = 32'h06B52E23; // L1 weight data = 12
        mem[1431] = 32'h00100593; // x11 = 1
        mem[1432] = 32'h08B52023; // COMMIT L1 F2 C2 T8 = 12
        mem[1433] = 32'h00200593; // x11 = 2
        mem[1434] = 32'h06B52823; // L1 weight filter = 2
        mem[1435] = 32'h00300593; // x11 = 3
        mem[1436] = 32'h06B52A23; // L1 weight channel = 3
        mem[1437] = 32'h00000593; // x11 = 0
        mem[1438] = 32'h06B52C23; // L1 weight tap = 0
        mem[1439] = 32'h03000593; // x11 = 48
        mem[1440] = 32'h06B52E23; // L1 weight data = 48
        mem[1441] = 32'h00100593; // x11 = 1
        mem[1442] = 32'h08B52023; // COMMIT L1 F2 C3 T0 = 48
        mem[1443] = 32'h00200593; // x11 = 2
        mem[1444] = 32'h06B52823; // L1 weight filter = 2
        mem[1445] = 32'h00300593; // x11 = 3
        mem[1446] = 32'h06B52A23; // L1 weight channel = 3
        mem[1447] = 32'h00100593; // x11 = 1
        mem[1448] = 32'h06B52C23; // L1 weight tap = 1
        mem[1449] = 32'hFF200593; // x11 = -14
        mem[1450] = 32'h06B52E23; // L1 weight data = -14
        mem[1451] = 32'h00100593; // x11 = 1
        mem[1452] = 32'h08B52023; // COMMIT L1 F2 C3 T1 = -14
        mem[1453] = 32'h00200593; // x11 = 2
        mem[1454] = 32'h06B52823; // L1 weight filter = 2
        mem[1455] = 32'h00300593; // x11 = 3
        mem[1456] = 32'h06B52A23; // L1 weight channel = 3
        mem[1457] = 32'h00200593; // x11 = 2
        mem[1458] = 32'h06B52C23; // L1 weight tap = 2
        mem[1459] = 32'hFF100593; // x11 = -15
        mem[1460] = 32'h06B52E23; // L1 weight data = -15
        mem[1461] = 32'h00100593; // x11 = 1
        mem[1462] = 32'h08B52023; // COMMIT L1 F2 C3 T2 = -15
        mem[1463] = 32'h00200593; // x11 = 2
        mem[1464] = 32'h06B52823; // L1 weight filter = 2
        mem[1465] = 32'h00300593; // x11 = 3
        mem[1466] = 32'h06B52A23; // L1 weight channel = 3
        mem[1467] = 32'h00300593; // x11 = 3
        mem[1468] = 32'h06B52C23; // L1 weight tap = 3
        mem[1469] = 32'h00400593; // x11 = 4
        mem[1470] = 32'h06B52E23; // L1 weight data = 4
        mem[1471] = 32'h00100593; // x11 = 1
        mem[1472] = 32'h08B52023; // COMMIT L1 F2 C3 T3 = 4
        mem[1473] = 32'h00200593; // x11 = 2
        mem[1474] = 32'h06B52823; // L1 weight filter = 2
        mem[1475] = 32'h00300593; // x11 = 3
        mem[1476] = 32'h06B52A23; // L1 weight channel = 3
        mem[1477] = 32'h00400593; // x11 = 4
        mem[1478] = 32'h06B52C23; // L1 weight tap = 4
        mem[1479] = 32'hFE600593; // x11 = -26
        mem[1480] = 32'h06B52E23; // L1 weight data = -26
        mem[1481] = 32'h00100593; // x11 = 1
        mem[1482] = 32'h08B52023; // COMMIT L1 F2 C3 T4 = -26
        mem[1483] = 32'h00200593; // x11 = 2
        mem[1484] = 32'h06B52823; // L1 weight filter = 2
        mem[1485] = 32'h00300593; // x11 = 3
        mem[1486] = 32'h06B52A23; // L1 weight channel = 3
        mem[1487] = 32'h00500593; // x11 = 5
        mem[1488] = 32'h06B52C23; // L1 weight tap = 5
        mem[1489] = 32'h00100593; // x11 = 1
        mem[1490] = 32'h06B52E23; // L1 weight data = 1
        mem[1491] = 32'h00100593; // x11 = 1
        mem[1492] = 32'h08B52023; // COMMIT L1 F2 C3 T5 = 1
        mem[1493] = 32'h00200593; // x11 = 2
        mem[1494] = 32'h06B52823; // L1 weight filter = 2
        mem[1495] = 32'h00300593; // x11 = 3
        mem[1496] = 32'h06B52A23; // L1 weight channel = 3
        mem[1497] = 32'h00600593; // x11 = 6
        mem[1498] = 32'h06B52C23; // L1 weight tap = 6
        mem[1499] = 32'h01000593; // x11 = 16
        mem[1500] = 32'h06B52E23; // L1 weight data = 16
        mem[1501] = 32'h00100593; // x11 = 1
        mem[1502] = 32'h08B52023; // COMMIT L1 F2 C3 T6 = 16
        mem[1503] = 32'h00200593; // x11 = 2
        mem[1504] = 32'h06B52823; // L1 weight filter = 2
        mem[1505] = 32'h00300593; // x11 = 3
        mem[1506] = 32'h06B52A23; // L1 weight channel = 3
        mem[1507] = 32'h00700593; // x11 = 7
        mem[1508] = 32'h06B52C23; // L1 weight tap = 7
        mem[1509] = 32'hFCE00593; // x11 = -50
        mem[1510] = 32'h06B52E23; // L1 weight data = -50
        mem[1511] = 32'h00100593; // x11 = 1
        mem[1512] = 32'h08B52023; // COMMIT L1 F2 C3 T7 = -50
        mem[1513] = 32'h00200593; // x11 = 2
        mem[1514] = 32'h06B52823; // L1 weight filter = 2
        mem[1515] = 32'h00300593; // x11 = 3
        mem[1516] = 32'h06B52A23; // L1 weight channel = 3
        mem[1517] = 32'h00800593; // x11 = 8
        mem[1518] = 32'h06B52C23; // L1 weight tap = 8
        mem[1519] = 32'h01300593; // x11 = 19
        mem[1520] = 32'h06B52E23; // L1 weight data = 19
        mem[1521] = 32'h00100593; // x11 = 1
        mem[1522] = 32'h08B52023; // COMMIT L1 F2 C3 T8 = 19
        mem[1523] = 32'h00300593; // x11 = 3
        mem[1524] = 32'h06B52823; // L1 weight filter = 3
        mem[1525] = 32'h00000593; // x11 = 0
        mem[1526] = 32'h06B52A23; // L1 weight channel = 0
        mem[1527] = 32'h00000593; // x11 = 0
        mem[1528] = 32'h06B52C23; // L1 weight tap = 0
        mem[1529] = 32'hFD300593; // x11 = -45
        mem[1530] = 32'h06B52E23; // L1 weight data = -45
        mem[1531] = 32'h00100593; // x11 = 1
        mem[1532] = 32'h08B52023; // COMMIT L1 F3 C0 T0 = -45
        mem[1533] = 32'h00300593; // x11 = 3
        mem[1534] = 32'h06B52823; // L1 weight filter = 3
        mem[1535] = 32'h00000593; // x11 = 0
        mem[1536] = 32'h06B52A23; // L1 weight channel = 0
        mem[1537] = 32'h00100593; // x11 = 1
        mem[1538] = 32'h06B52C23; // L1 weight tap = 1
        mem[1539] = 32'hFB700593; // x11 = -73
        mem[1540] = 32'h06B52E23; // L1 weight data = -73
        mem[1541] = 32'h00100593; // x11 = 1
        mem[1542] = 32'h08B52023; // COMMIT L1 F3 C0 T1 = -73
        mem[1543] = 32'h00300593; // x11 = 3
        mem[1544] = 32'h06B52823; // L1 weight filter = 3
        mem[1545] = 32'h00000593; // x11 = 0
        mem[1546] = 32'h06B52A23; // L1 weight channel = 0
        mem[1547] = 32'h00200593; // x11 = 2
        mem[1548] = 32'h06B52C23; // L1 weight tap = 2
        mem[1549] = 32'h01A00593; // x11 = 26
        mem[1550] = 32'h06B52E23; // L1 weight data = 26
        mem[1551] = 32'h00100593; // x11 = 1
        mem[1552] = 32'h08B52023; // COMMIT L1 F3 C0 T2 = 26
        mem[1553] = 32'h00300593; // x11 = 3
        mem[1554] = 32'h06B52823; // L1 weight filter = 3
        mem[1555] = 32'h00000593; // x11 = 0
        mem[1556] = 32'h06B52A23; // L1 weight channel = 0
        mem[1557] = 32'h00300593; // x11 = 3
        mem[1558] = 32'h06B52C23; // L1 weight tap = 3
        mem[1559] = 32'hFD400593; // x11 = -44
        mem[1560] = 32'h06B52E23; // L1 weight data = -44
        mem[1561] = 32'h00100593; // x11 = 1
        mem[1562] = 32'h08B52023; // COMMIT L1 F3 C0 T3 = -44
        mem[1563] = 32'h00300593; // x11 = 3
        mem[1564] = 32'h06B52823; // L1 weight filter = 3
        mem[1565] = 32'h00000593; // x11 = 0
        mem[1566] = 32'h06B52A23; // L1 weight channel = 0
        mem[1567] = 32'h00400593; // x11 = 4
        mem[1568] = 32'h06B52C23; // L1 weight tap = 4
        mem[1569] = 32'hFE100593; // x11 = -31
        mem[1570] = 32'h06B52E23; // L1 weight data = -31
        mem[1571] = 32'h00100593; // x11 = 1
        mem[1572] = 32'h08B52023; // COMMIT L1 F3 C0 T4 = -31
        mem[1573] = 32'h00300593; // x11 = 3
        mem[1574] = 32'h06B52823; // L1 weight filter = 3
        mem[1575] = 32'h00000593; // x11 = 0
        mem[1576] = 32'h06B52A23; // L1 weight channel = 0
        mem[1577] = 32'h00500593; // x11 = 5
        mem[1578] = 32'h06B52C23; // L1 weight tap = 5
        mem[1579] = 32'h00800593; // x11 = 8
        mem[1580] = 32'h06B52E23; // L1 weight data = 8
        mem[1581] = 32'h00100593; // x11 = 1
        mem[1582] = 32'h08B52023; // COMMIT L1 F3 C0 T5 = 8
        mem[1583] = 32'h00300593; // x11 = 3
        mem[1584] = 32'h06B52823; // L1 weight filter = 3
        mem[1585] = 32'h00000593; // x11 = 0
        mem[1586] = 32'h06B52A23; // L1 weight channel = 0
        mem[1587] = 32'h00600593; // x11 = 6
        mem[1588] = 32'h06B52C23; // L1 weight tap = 6
        mem[1589] = 32'h05D00593; // x11 = 93
        mem[1590] = 32'h06B52E23; // L1 weight data = 93
        mem[1591] = 32'h00100593; // x11 = 1
        mem[1592] = 32'h08B52023; // COMMIT L1 F3 C0 T6 = 93
        mem[1593] = 32'h00300593; // x11 = 3
        mem[1594] = 32'h06B52823; // L1 weight filter = 3
        mem[1595] = 32'h00000593; // x11 = 0
        mem[1596] = 32'h06B52A23; // L1 weight channel = 0
        mem[1597] = 32'h00700593; // x11 = 7
        mem[1598] = 32'h06B52C23; // L1 weight tap = 7
        mem[1599] = 32'h02600593; // x11 = 38
        mem[1600] = 32'h06B52E23; // L1 weight data = 38
        mem[1601] = 32'h00100593; // x11 = 1
        mem[1602] = 32'h08B52023; // COMMIT L1 F3 C0 T7 = 38
        mem[1603] = 32'h00300593; // x11 = 3
        mem[1604] = 32'h06B52823; // L1 weight filter = 3
        mem[1605] = 32'h00000593; // x11 = 0
        mem[1606] = 32'h06B52A23; // L1 weight channel = 0
        mem[1607] = 32'h00800593; // x11 = 8
        mem[1608] = 32'h06B52C23; // L1 weight tap = 8
        mem[1609] = 32'hFB800593; // x11 = -72
        mem[1610] = 32'h06B52E23; // L1 weight data = -72
        mem[1611] = 32'h00100593; // x11 = 1
        mem[1612] = 32'h08B52023; // COMMIT L1 F3 C0 T8 = -72
        mem[1613] = 32'h00300593; // x11 = 3
        mem[1614] = 32'h06B52823; // L1 weight filter = 3
        mem[1615] = 32'h00100593; // x11 = 1
        mem[1616] = 32'h06B52A23; // L1 weight channel = 1
        mem[1617] = 32'h00000593; // x11 = 0
        mem[1618] = 32'h06B52C23; // L1 weight tap = 0
        mem[1619] = 32'h00500593; // x11 = 5
        mem[1620] = 32'h06B52E23; // L1 weight data = 5
        mem[1621] = 32'h00100593; // x11 = 1
        mem[1622] = 32'h08B52023; // COMMIT L1 F3 C1 T0 = 5
        mem[1623] = 32'h00300593; // x11 = 3
        mem[1624] = 32'h06B52823; // L1 weight filter = 3
        mem[1625] = 32'h00100593; // x11 = 1
        mem[1626] = 32'h06B52A23; // L1 weight channel = 1
        mem[1627] = 32'h00100593; // x11 = 1
        mem[1628] = 32'h06B52C23; // L1 weight tap = 1
        mem[1629] = 32'h00600593; // x11 = 6
        mem[1630] = 32'h06B52E23; // L1 weight data = 6
        mem[1631] = 32'h00100593; // x11 = 1
        mem[1632] = 32'h08B52023; // COMMIT L1 F3 C1 T1 = 6
        mem[1633] = 32'h00300593; // x11 = 3
        mem[1634] = 32'h06B52823; // L1 weight filter = 3
        mem[1635] = 32'h00100593; // x11 = 1
        mem[1636] = 32'h06B52A23; // L1 weight channel = 1
        mem[1637] = 32'h00200593; // x11 = 2
        mem[1638] = 32'h06B52C23; // L1 weight tap = 2
        mem[1639] = 32'hFF200593; // x11 = -14
        mem[1640] = 32'h06B52E23; // L1 weight data = -14
        mem[1641] = 32'h00100593; // x11 = 1
        mem[1642] = 32'h08B52023; // COMMIT L1 F3 C1 T2 = -14
        mem[1643] = 32'h00300593; // x11 = 3
        mem[1644] = 32'h06B52823; // L1 weight filter = 3
        mem[1645] = 32'h00100593; // x11 = 1
        mem[1646] = 32'h06B52A23; // L1 weight channel = 1
        mem[1647] = 32'h00300593; // x11 = 3
        mem[1648] = 32'h06B52C23; // L1 weight tap = 3
        mem[1649] = 32'h02700593; // x11 = 39
        mem[1650] = 32'h06B52E23; // L1 weight data = 39
        mem[1651] = 32'h00100593; // x11 = 1
        mem[1652] = 32'h08B52023; // COMMIT L1 F3 C1 T3 = 39
        mem[1653] = 32'h00300593; // x11 = 3
        mem[1654] = 32'h06B52823; // L1 weight filter = 3
        mem[1655] = 32'h00100593; // x11 = 1
        mem[1656] = 32'h06B52A23; // L1 weight channel = 1
        mem[1657] = 32'h00400593; // x11 = 4
        mem[1658] = 32'h06B52C23; // L1 weight tap = 4
        mem[1659] = 32'h00A00593; // x11 = 10
        mem[1660] = 32'h06B52E23; // L1 weight data = 10
        mem[1661] = 32'h00100593; // x11 = 1
        mem[1662] = 32'h08B52023; // COMMIT L1 F3 C1 T4 = 10
        mem[1663] = 32'h00300593; // x11 = 3
        mem[1664] = 32'h06B52823; // L1 weight filter = 3
        mem[1665] = 32'h00100593; // x11 = 1
        mem[1666] = 32'h06B52A23; // L1 weight channel = 1
        mem[1667] = 32'h00500593; // x11 = 5
        mem[1668] = 32'h06B52C23; // L1 weight tap = 5
        mem[1669] = 32'hFE800593; // x11 = -24
        mem[1670] = 32'h06B52E23; // L1 weight data = -24
        mem[1671] = 32'h00100593; // x11 = 1
        mem[1672] = 32'h08B52023; // COMMIT L1 F3 C1 T5 = -24
        mem[1673] = 32'h00300593; // x11 = 3
        mem[1674] = 32'h06B52823; // L1 weight filter = 3
        mem[1675] = 32'h00100593; // x11 = 1
        mem[1676] = 32'h06B52A23; // L1 weight channel = 1
        mem[1677] = 32'h00600593; // x11 = 6
        mem[1678] = 32'h06B52C23; // L1 weight tap = 6
        mem[1679] = 32'h00E00593; // x11 = 14
        mem[1680] = 32'h06B52E23; // L1 weight data = 14
        mem[1681] = 32'h00100593; // x11 = 1
        mem[1682] = 32'h08B52023; // COMMIT L1 F3 C1 T6 = 14
        mem[1683] = 32'h00300593; // x11 = 3
        mem[1684] = 32'h06B52823; // L1 weight filter = 3
        mem[1685] = 32'h00100593; // x11 = 1
        mem[1686] = 32'h06B52A23; // L1 weight channel = 1
        mem[1687] = 32'h00700593; // x11 = 7
        mem[1688] = 32'h06B52C23; // L1 weight tap = 7
        mem[1689] = 32'hFEC00593; // x11 = -20
        mem[1690] = 32'h06B52E23; // L1 weight data = -20
        mem[1691] = 32'h00100593; // x11 = 1
        mem[1692] = 32'h08B52023; // COMMIT L1 F3 C1 T7 = -20
        mem[1693] = 32'h00300593; // x11 = 3
        mem[1694] = 32'h06B52823; // L1 weight filter = 3
        mem[1695] = 32'h00100593; // x11 = 1
        mem[1696] = 32'h06B52A23; // L1 weight channel = 1
        mem[1697] = 32'h00800593; // x11 = 8
        mem[1698] = 32'h06B52C23; // L1 weight tap = 8
        mem[1699] = 32'h01100593; // x11 = 17
        mem[1700] = 32'h06B52E23; // L1 weight data = 17
        mem[1701] = 32'h00100593; // x11 = 1
        mem[1702] = 32'h08B52023; // COMMIT L1 F3 C1 T8 = 17
        mem[1703] = 32'h00300593; // x11 = 3
        mem[1704] = 32'h06B52823; // L1 weight filter = 3
        mem[1705] = 32'h00200593; // x11 = 2
        mem[1706] = 32'h06B52A23; // L1 weight channel = 2
        mem[1707] = 32'h00000593; // x11 = 0
        mem[1708] = 32'h06B52C23; // L1 weight tap = 0
        mem[1709] = 32'h01000593; // x11 = 16
        mem[1710] = 32'h06B52E23; // L1 weight data = 16
        mem[1711] = 32'h00100593; // x11 = 1
        mem[1712] = 32'h08B52023; // COMMIT L1 F3 C2 T0 = 16
        mem[1713] = 32'h00300593; // x11 = 3
        mem[1714] = 32'h06B52823; // L1 weight filter = 3
        mem[1715] = 32'h00200593; // x11 = 2
        mem[1716] = 32'h06B52A23; // L1 weight channel = 2
        mem[1717] = 32'h00100593; // x11 = 1
        mem[1718] = 32'h06B52C23; // L1 weight tap = 1
        mem[1719] = 32'hFF100593; // x11 = -15
        mem[1720] = 32'h06B52E23; // L1 weight data = -15
        mem[1721] = 32'h00100593; // x11 = 1
        mem[1722] = 32'h08B52023; // COMMIT L1 F3 C2 T1 = -15
        mem[1723] = 32'h00300593; // x11 = 3
        mem[1724] = 32'h06B52823; // L1 weight filter = 3
        mem[1725] = 32'h00200593; // x11 = 2
        mem[1726] = 32'h06B52A23; // L1 weight channel = 2
        mem[1727] = 32'h00200593; // x11 = 2
        mem[1728] = 32'h06B52C23; // L1 weight tap = 2
        mem[1729] = 32'h02000593; // x11 = 32
        mem[1730] = 32'h06B52E23; // L1 weight data = 32
        mem[1731] = 32'h00100593; // x11 = 1
        mem[1732] = 32'h08B52023; // COMMIT L1 F3 C2 T2 = 32
        mem[1733] = 32'h00300593; // x11 = 3
        mem[1734] = 32'h06B52823; // L1 weight filter = 3
        mem[1735] = 32'h00200593; // x11 = 2
        mem[1736] = 32'h06B52A23; // L1 weight channel = 2
        mem[1737] = 32'h00300593; // x11 = 3
        mem[1738] = 32'h06B52C23; // L1 weight tap = 3
        mem[1739] = 32'hFFC00593; // x11 = -4
        mem[1740] = 32'h06B52E23; // L1 weight data = -4
        mem[1741] = 32'h00100593; // x11 = 1
        mem[1742] = 32'h08B52023; // COMMIT L1 F3 C2 T3 = -4
        mem[1743] = 32'h00300593; // x11 = 3
        mem[1744] = 32'h06B52823; // L1 weight filter = 3
        mem[1745] = 32'h00200593; // x11 = 2
        mem[1746] = 32'h06B52A23; // L1 weight channel = 2
        mem[1747] = 32'h00400593; // x11 = 4
        mem[1748] = 32'h06B52C23; // L1 weight tap = 4
        mem[1749] = 32'h02600593; // x11 = 38
        mem[1750] = 32'h06B52E23; // L1 weight data = 38
        mem[1751] = 32'h00100593; // x11 = 1
        mem[1752] = 32'h08B52023; // COMMIT L1 F3 C2 T4 = 38
        mem[1753] = 32'h00300593; // x11 = 3
        mem[1754] = 32'h06B52823; // L1 weight filter = 3
        mem[1755] = 32'h00200593; // x11 = 2
        mem[1756] = 32'h06B52A23; // L1 weight channel = 2
        mem[1757] = 32'h00500593; // x11 = 5
        mem[1758] = 32'h06B52C23; // L1 weight tap = 5
        mem[1759] = 32'h04600593; // x11 = 70
        mem[1760] = 32'h06B52E23; // L1 weight data = 70
        mem[1761] = 32'h00100593; // x11 = 1
        mem[1762] = 32'h08B52023; // COMMIT L1 F3 C2 T5 = 70
        mem[1763] = 32'h00300593; // x11 = 3
        mem[1764] = 32'h06B52823; // L1 weight filter = 3
        mem[1765] = 32'h00200593; // x11 = 2
        mem[1766] = 32'h06B52A23; // L1 weight channel = 2
        mem[1767] = 32'h00600593; // x11 = 6
        mem[1768] = 32'h06B52C23; // L1 weight tap = 6
        mem[1769] = 32'h00B00593; // x11 = 11
        mem[1770] = 32'h06B52E23; // L1 weight data = 11
        mem[1771] = 32'h00100593; // x11 = 1
        mem[1772] = 32'h08B52023; // COMMIT L1 F3 C2 T6 = 11
        mem[1773] = 32'h00300593; // x11 = 3
        mem[1774] = 32'h06B52823; // L1 weight filter = 3
        mem[1775] = 32'h00200593; // x11 = 2
        mem[1776] = 32'h06B52A23; // L1 weight channel = 2
        mem[1777] = 32'h00700593; // x11 = 7
        mem[1778] = 32'h06B52C23; // L1 weight tap = 7
        mem[1779] = 32'h00A00593; // x11 = 10
        mem[1780] = 32'h06B52E23; // L1 weight data = 10
        mem[1781] = 32'h00100593; // x11 = 1
        mem[1782] = 32'h08B52023; // COMMIT L1 F3 C2 T7 = 10
        mem[1783] = 32'h00300593; // x11 = 3
        mem[1784] = 32'h06B52823; // L1 weight filter = 3
        mem[1785] = 32'h00200593; // x11 = 2
        mem[1786] = 32'h06B52A23; // L1 weight channel = 2
        mem[1787] = 32'h00800593; // x11 = 8
        mem[1788] = 32'h06B52C23; // L1 weight tap = 8
        mem[1789] = 32'hFE400593; // x11 = -28
        mem[1790] = 32'h06B52E23; // L1 weight data = -28
        mem[1791] = 32'h00100593; // x11 = 1
        mem[1792] = 32'h08B52023; // COMMIT L1 F3 C2 T8 = -28
        mem[1793] = 32'h00300593; // x11 = 3
        mem[1794] = 32'h06B52823; // L1 weight filter = 3
        mem[1795] = 32'h00300593; // x11 = 3
        mem[1796] = 32'h06B52A23; // L1 weight channel = 3
        mem[1797] = 32'h00000593; // x11 = 0
        mem[1798] = 32'h06B52C23; // L1 weight tap = 0
        mem[1799] = 32'hFE900593; // x11 = -23
        mem[1800] = 32'h06B52E23; // L1 weight data = -23
        mem[1801] = 32'h00100593; // x11 = 1
        mem[1802] = 32'h08B52023; // COMMIT L1 F3 C3 T0 = -23
        mem[1803] = 32'h00300593; // x11 = 3
        mem[1804] = 32'h06B52823; // L1 weight filter = 3
        mem[1805] = 32'h00300593; // x11 = 3
        mem[1806] = 32'h06B52A23; // L1 weight channel = 3
        mem[1807] = 32'h00100593; // x11 = 1
        mem[1808] = 32'h06B52C23; // L1 weight tap = 1
        mem[1809] = 32'h00100593; // x11 = 1
        mem[1810] = 32'h06B52E23; // L1 weight data = 1
        mem[1811] = 32'h00100593; // x11 = 1
        mem[1812] = 32'h08B52023; // COMMIT L1 F3 C3 T1 = 1
        mem[1813] = 32'h00300593; // x11 = 3
        mem[1814] = 32'h06B52823; // L1 weight filter = 3
        mem[1815] = 32'h00300593; // x11 = 3
        mem[1816] = 32'h06B52A23; // L1 weight channel = 3
        mem[1817] = 32'h00200593; // x11 = 2
        mem[1818] = 32'h06B52C23; // L1 weight tap = 2
        mem[1819] = 32'h02100593; // x11 = 33
        mem[1820] = 32'h06B52E23; // L1 weight data = 33
        mem[1821] = 32'h00100593; // x11 = 1
        mem[1822] = 32'h08B52023; // COMMIT L1 F3 C3 T2 = 33
        mem[1823] = 32'h00300593; // x11 = 3
        mem[1824] = 32'h06B52823; // L1 weight filter = 3
        mem[1825] = 32'h00300593; // x11 = 3
        mem[1826] = 32'h06B52A23; // L1 weight channel = 3
        mem[1827] = 32'h00300593; // x11 = 3
        mem[1828] = 32'h06B52C23; // L1 weight tap = 3
        mem[1829] = 32'h00900593; // x11 = 9
        mem[1830] = 32'h06B52E23; // L1 weight data = 9
        mem[1831] = 32'h00100593; // x11 = 1
        mem[1832] = 32'h08B52023; // COMMIT L1 F3 C3 T3 = 9
        mem[1833] = 32'h00300593; // x11 = 3
        mem[1834] = 32'h06B52823; // L1 weight filter = 3
        mem[1835] = 32'h00300593; // x11 = 3
        mem[1836] = 32'h06B52A23; // L1 weight channel = 3
        mem[1837] = 32'h00400593; // x11 = 4
        mem[1838] = 32'h06B52C23; // L1 weight tap = 4
        mem[1839] = 32'h01B00593; // x11 = 27
        mem[1840] = 32'h06B52E23; // L1 weight data = 27
        mem[1841] = 32'h00100593; // x11 = 1
        mem[1842] = 32'h08B52023; // COMMIT L1 F3 C3 T4 = 27
        mem[1843] = 32'h00300593; // x11 = 3
        mem[1844] = 32'h06B52823; // L1 weight filter = 3
        mem[1845] = 32'h00300593; // x11 = 3
        mem[1846] = 32'h06B52A23; // L1 weight channel = 3
        mem[1847] = 32'h00500593; // x11 = 5
        mem[1848] = 32'h06B52C23; // L1 weight tap = 5
        mem[1849] = 32'h00C00593; // x11 = 12
        mem[1850] = 32'h06B52E23; // L1 weight data = 12
        mem[1851] = 32'h00100593; // x11 = 1
        mem[1852] = 32'h08B52023; // COMMIT L1 F3 C3 T5 = 12
        mem[1853] = 32'h00300593; // x11 = 3
        mem[1854] = 32'h06B52823; // L1 weight filter = 3
        mem[1855] = 32'h00300593; // x11 = 3
        mem[1856] = 32'h06B52A23; // L1 weight channel = 3
        mem[1857] = 32'h00600593; // x11 = 6
        mem[1858] = 32'h06B52C23; // L1 weight tap = 6
        mem[1859] = 32'h02F00593; // x11 = 47
        mem[1860] = 32'h06B52E23; // L1 weight data = 47
        mem[1861] = 32'h00100593; // x11 = 1
        mem[1862] = 32'h08B52023; // COMMIT L1 F3 C3 T6 = 47
        mem[1863] = 32'h00300593; // x11 = 3
        mem[1864] = 32'h06B52823; // L1 weight filter = 3
        mem[1865] = 32'h00300593; // x11 = 3
        mem[1866] = 32'h06B52A23; // L1 weight channel = 3
        mem[1867] = 32'h00700593; // x11 = 7
        mem[1868] = 32'h06B52C23; // L1 weight tap = 7
        mem[1869] = 32'hFFE00593; // x11 = -2
        mem[1870] = 32'h06B52E23; // L1 weight data = -2
        mem[1871] = 32'h00100593; // x11 = 1
        mem[1872] = 32'h08B52023; // COMMIT L1 F3 C3 T7 = -2
        mem[1873] = 32'h00300593; // x11 = 3
        mem[1874] = 32'h06B52823; // L1 weight filter = 3
        mem[1875] = 32'h00300593; // x11 = 3
        mem[1876] = 32'h06B52A23; // L1 weight channel = 3
        mem[1877] = 32'h00800593; // x11 = 8
        mem[1878] = 32'h06B52C23; // L1 weight tap = 8
        mem[1879] = 32'h03300593; // x11 = 51
        mem[1880] = 32'h06B52E23; // L1 weight data = 51
        mem[1881] = 32'h00100593; // x11 = 1
        mem[1882] = 32'h08B52023; // COMMIT L1 F3 C3 T8 = 51
        mem[1883] = 32'h00400593; // x11 = 4
        mem[1884] = 32'h06B52823; // L1 weight filter = 4
        mem[1885] = 32'h00000593; // x11 = 0
        mem[1886] = 32'h06B52A23; // L1 weight channel = 0
        mem[1887] = 32'h00000593; // x11 = 0
        mem[1888] = 32'h06B52C23; // L1 weight tap = 0
        mem[1889] = 32'h00200593; // x11 = 2
        mem[1890] = 32'h06B52E23; // L1 weight data = 2
        mem[1891] = 32'h00100593; // x11 = 1
        mem[1892] = 32'h08B52023; // COMMIT L1 F4 C0 T0 = 2
        mem[1893] = 32'h00400593; // x11 = 4
        mem[1894] = 32'h06B52823; // L1 weight filter = 4
        mem[1895] = 32'h00000593; // x11 = 0
        mem[1896] = 32'h06B52A23; // L1 weight channel = 0
        mem[1897] = 32'h00100593; // x11 = 1
        mem[1898] = 32'h06B52C23; // L1 weight tap = 1
        mem[1899] = 32'h00500593; // x11 = 5
        mem[1900] = 32'h06B52E23; // L1 weight data = 5
        mem[1901] = 32'h00100593; // x11 = 1
        mem[1902] = 32'h08B52023; // COMMIT L1 F4 C0 T1 = 5
        mem[1903] = 32'h00400593; // x11 = 4
        mem[1904] = 32'h06B52823; // L1 weight filter = 4
        mem[1905] = 32'h00000593; // x11 = 0
        mem[1906] = 32'h06B52A23; // L1 weight channel = 0
        mem[1907] = 32'h00200593; // x11 = 2
        mem[1908] = 32'h06B52C23; // L1 weight tap = 2
        mem[1909] = 32'hFED00593; // x11 = -19
        mem[1910] = 32'h06B52E23; // L1 weight data = -19
        mem[1911] = 32'h00100593; // x11 = 1
        mem[1912] = 32'h08B52023; // COMMIT L1 F4 C0 T2 = -19
        mem[1913] = 32'h00400593; // x11 = 4
        mem[1914] = 32'h06B52823; // L1 weight filter = 4
        mem[1915] = 32'h00000593; // x11 = 0
        mem[1916] = 32'h06B52A23; // L1 weight channel = 0
        mem[1917] = 32'h00300593; // x11 = 3
        mem[1918] = 32'h06B52C23; // L1 weight tap = 3
        mem[1919] = 32'h02800593; // x11 = 40
        mem[1920] = 32'h06B52E23; // L1 weight data = 40
        mem[1921] = 32'h00100593; // x11 = 1
        mem[1922] = 32'h08B52023; // COMMIT L1 F4 C0 T3 = 40
        mem[1923] = 32'h00400593; // x11 = 4
        mem[1924] = 32'h06B52823; // L1 weight filter = 4
        mem[1925] = 32'h00000593; // x11 = 0
        mem[1926] = 32'h06B52A23; // L1 weight channel = 0
        mem[1927] = 32'h00400593; // x11 = 4
        mem[1928] = 32'h06B52C23; // L1 weight tap = 4
        mem[1929] = 32'h02700593; // x11 = 39
        mem[1930] = 32'h06B52E23; // L1 weight data = 39
        mem[1931] = 32'h00100593; // x11 = 1
        mem[1932] = 32'h08B52023; // COMMIT L1 F4 C0 T4 = 39
        mem[1933] = 32'h00400593; // x11 = 4
        mem[1934] = 32'h06B52823; // L1 weight filter = 4
        mem[1935] = 32'h00000593; // x11 = 0
        mem[1936] = 32'h06B52A23; // L1 weight channel = 0
        mem[1937] = 32'h00500593; // x11 = 5
        mem[1938] = 32'h06B52C23; // L1 weight tap = 5
        mem[1939] = 32'h01700593; // x11 = 23
        mem[1940] = 32'h06B52E23; // L1 weight data = 23
        mem[1941] = 32'h00100593; // x11 = 1
        mem[1942] = 32'h08B52023; // COMMIT L1 F4 C0 T5 = 23
        mem[1943] = 32'h00400593; // x11 = 4
        mem[1944] = 32'h06B52823; // L1 weight filter = 4
        mem[1945] = 32'h00000593; // x11 = 0
        mem[1946] = 32'h06B52A23; // L1 weight channel = 0
        mem[1947] = 32'h00600593; // x11 = 6
        mem[1948] = 32'h06B52C23; // L1 weight tap = 6
        mem[1949] = 32'hFC700593; // x11 = -57
        mem[1950] = 32'h06B52E23; // L1 weight data = -57
        mem[1951] = 32'h00100593; // x11 = 1
        mem[1952] = 32'h08B52023; // COMMIT L1 F4 C0 T6 = -57
        mem[1953] = 32'h00400593; // x11 = 4
        mem[1954] = 32'h06B52823; // L1 weight filter = 4
        mem[1955] = 32'h00000593; // x11 = 0
        mem[1956] = 32'h06B52A23; // L1 weight channel = 0
        mem[1957] = 32'h00700593; // x11 = 7
        mem[1958] = 32'h06B52C23; // L1 weight tap = 7
        mem[1959] = 32'h00600593; // x11 = 6
        mem[1960] = 32'h06B52E23; // L1 weight data = 6
        mem[1961] = 32'h00100593; // x11 = 1
        mem[1962] = 32'h08B52023; // COMMIT L1 F4 C0 T7 = 6
        mem[1963] = 32'h00400593; // x11 = 4
        mem[1964] = 32'h06B52823; // L1 weight filter = 4
        mem[1965] = 32'h00000593; // x11 = 0
        mem[1966] = 32'h06B52A23; // L1 weight channel = 0
        mem[1967] = 32'h00800593; // x11 = 8
        mem[1968] = 32'h06B52C23; // L1 weight tap = 8
        mem[1969] = 32'hFEF00593; // x11 = -17
        mem[1970] = 32'h06B52E23; // L1 weight data = -17
        mem[1971] = 32'h00100593; // x11 = 1
        mem[1972] = 32'h08B52023; // COMMIT L1 F4 C0 T8 = -17
        mem[1973] = 32'h00400593; // x11 = 4
        mem[1974] = 32'h06B52823; // L1 weight filter = 4
        mem[1975] = 32'h00100593; // x11 = 1
        mem[1976] = 32'h06B52A23; // L1 weight channel = 1
        mem[1977] = 32'h00000593; // x11 = 0
        mem[1978] = 32'h06B52C23; // L1 weight tap = 0
        mem[1979] = 32'hFE100593; // x11 = -31
        mem[1980] = 32'h06B52E23; // L1 weight data = -31
        mem[1981] = 32'h00100593; // x11 = 1
        mem[1982] = 32'h08B52023; // COMMIT L1 F4 C1 T0 = -31
        mem[1983] = 32'h00400593; // x11 = 4
        mem[1984] = 32'h06B52823; // L1 weight filter = 4
        mem[1985] = 32'h00100593; // x11 = 1
        mem[1986] = 32'h06B52A23; // L1 weight channel = 1
        mem[1987] = 32'h00100593; // x11 = 1
        mem[1988] = 32'h06B52C23; // L1 weight tap = 1
        mem[1989] = 32'hFF700593; // x11 = -9
        mem[1990] = 32'h06B52E23; // L1 weight data = -9
        mem[1991] = 32'h00100593; // x11 = 1
        mem[1992] = 32'h08B52023; // COMMIT L1 F4 C1 T1 = -9
        mem[1993] = 32'h00400593; // x11 = 4
        mem[1994] = 32'h06B52823; // L1 weight filter = 4
        mem[1995] = 32'h00100593; // x11 = 1
        mem[1996] = 32'h06B52A23; // L1 weight channel = 1
        mem[1997] = 32'h00200593; // x11 = 2
        mem[1998] = 32'h06B52C23; // L1 weight tap = 2
        mem[1999] = 32'h01200593; // x11 = 18
        mem[2000] = 32'h06B52E23; // L1 weight data = 18
        mem[2001] = 32'h00100593; // x11 = 1
        mem[2002] = 32'h08B52023; // COMMIT L1 F4 C1 T2 = 18
        mem[2003] = 32'h00400593; // x11 = 4
        mem[2004] = 32'h06B52823; // L1 weight filter = 4
        mem[2005] = 32'h00100593; // x11 = 1
        mem[2006] = 32'h06B52A23; // L1 weight channel = 1
        mem[2007] = 32'h00300593; // x11 = 3
        mem[2008] = 32'h06B52C23; // L1 weight tap = 3
        mem[2009] = 32'h00500593; // x11 = 5
        mem[2010] = 32'h06B52E23; // L1 weight data = 5
        mem[2011] = 32'h00100593; // x11 = 1
        mem[2012] = 32'h08B52023; // COMMIT L1 F4 C1 T3 = 5
        mem[2013] = 32'h00400593; // x11 = 4
        mem[2014] = 32'h06B52823; // L1 weight filter = 4
        mem[2015] = 32'h00100593; // x11 = 1
        mem[2016] = 32'h06B52A23; // L1 weight channel = 1
        mem[2017] = 32'h00400593; // x11 = 4
        mem[2018] = 32'h06B52C23; // L1 weight tap = 4
        mem[2019] = 32'hFE600593; // x11 = -26
        mem[2020] = 32'h06B52E23; // L1 weight data = -26
        mem[2021] = 32'h00100593; // x11 = 1
        mem[2022] = 32'h08B52023; // COMMIT L1 F4 C1 T4 = -26
        mem[2023] = 32'h00400593; // x11 = 4
        mem[2024] = 32'h06B52823; // L1 weight filter = 4
        mem[2025] = 32'h00100593; // x11 = 1
        mem[2026] = 32'h06B52A23; // L1 weight channel = 1
        mem[2027] = 32'h00500593; // x11 = 5
        mem[2028] = 32'h06B52C23; // L1 weight tap = 5
        mem[2029] = 32'h00300593; // x11 = 3
        mem[2030] = 32'h06B52E23; // L1 weight data = 3
        mem[2031] = 32'h00100593; // x11 = 1
        mem[2032] = 32'h08B52023; // COMMIT L1 F4 C1 T5 = 3
        mem[2033] = 32'h00400593; // x11 = 4
        mem[2034] = 32'h06B52823; // L1 weight filter = 4
        mem[2035] = 32'h00100593; // x11 = 1
        mem[2036] = 32'h06B52A23; // L1 weight channel = 1
        mem[2037] = 32'h00600593; // x11 = 6
        mem[2038] = 32'h06B52C23; // L1 weight tap = 6
        mem[2039] = 32'h00800593; // x11 = 8
        mem[2040] = 32'h06B52E23; // L1 weight data = 8
        mem[2041] = 32'h00100593; // x11 = 1
        mem[2042] = 32'h08B52023; // COMMIT L1 F4 C1 T6 = 8
        mem[2043] = 32'h00400593; // x11 = 4
        mem[2044] = 32'h06B52823; // L1 weight filter = 4
        mem[2045] = 32'h00100593; // x11 = 1
        mem[2046] = 32'h06B52A23; // L1 weight channel = 1
        mem[2047] = 32'h00700593; // x11 = 7
        mem[2048] = 32'h06B52C23; // L1 weight tap = 7
        mem[2049] = 32'hFEF00593; // x11 = -17
        mem[2050] = 32'h06B52E23; // L1 weight data = -17
        mem[2051] = 32'h00100593; // x11 = 1
        mem[2052] = 32'h08B52023; // COMMIT L1 F4 C1 T7 = -17
        mem[2053] = 32'h00400593; // x11 = 4
        mem[2054] = 32'h06B52823; // L1 weight filter = 4
        mem[2055] = 32'h00100593; // x11 = 1
        mem[2056] = 32'h06B52A23; // L1 weight channel = 1
        mem[2057] = 32'h00800593; // x11 = 8
        mem[2058] = 32'h06B52C23; // L1 weight tap = 8
        mem[2059] = 32'h00400593; // x11 = 4
        mem[2060] = 32'h06B52E23; // L1 weight data = 4
        mem[2061] = 32'h00100593; // x11 = 1
        mem[2062] = 32'h08B52023; // COMMIT L1 F4 C1 T8 = 4
        mem[2063] = 32'h00400593; // x11 = 4
        mem[2064] = 32'h06B52823; // L1 weight filter = 4
        mem[2065] = 32'h00200593; // x11 = 2
        mem[2066] = 32'h06B52A23; // L1 weight channel = 2
        mem[2067] = 32'h00000593; // x11 = 0
        mem[2068] = 32'h06B52C23; // L1 weight tap = 0
        mem[2069] = 32'hFF400593; // x11 = -12
        mem[2070] = 32'h06B52E23; // L1 weight data = -12
        mem[2071] = 32'h00100593; // x11 = 1
        mem[2072] = 32'h08B52023; // COMMIT L1 F4 C2 T0 = -12
        mem[2073] = 32'h00400593; // x11 = 4
        mem[2074] = 32'h06B52823; // L1 weight filter = 4
        mem[2075] = 32'h00200593; // x11 = 2
        mem[2076] = 32'h06B52A23; // L1 weight channel = 2
        mem[2077] = 32'h00100593; // x11 = 1
        mem[2078] = 32'h06B52C23; // L1 weight tap = 1
        mem[2079] = 32'hFE900593; // x11 = -23
        mem[2080] = 32'h06B52E23; // L1 weight data = -23
        mem[2081] = 32'h00100593; // x11 = 1
        mem[2082] = 32'h08B52023; // COMMIT L1 F4 C2 T1 = -23
        mem[2083] = 32'h00400593; // x11 = 4
        mem[2084] = 32'h06B52823; // L1 weight filter = 4
        mem[2085] = 32'h00200593; // x11 = 2
        mem[2086] = 32'h06B52A23; // L1 weight channel = 2
        mem[2087] = 32'h00200593; // x11 = 2
        mem[2088] = 32'h06B52C23; // L1 weight tap = 2
        mem[2089] = 32'hFFC00593; // x11 = -4
        mem[2090] = 32'h06B52E23; // L1 weight data = -4
        mem[2091] = 32'h00100593; // x11 = 1
        mem[2092] = 32'h08B52023; // COMMIT L1 F4 C2 T2 = -4
        mem[2093] = 32'h00400593; // x11 = 4
        mem[2094] = 32'h06B52823; // L1 weight filter = 4
        mem[2095] = 32'h00200593; // x11 = 2
        mem[2096] = 32'h06B52A23; // L1 weight channel = 2
        mem[2097] = 32'h00300593; // x11 = 3
        mem[2098] = 32'h06B52C23; // L1 weight tap = 3
        mem[2099] = 32'h01200593; // x11 = 18
        mem[2100] = 32'h06B52E23; // L1 weight data = 18
        mem[2101] = 32'h00100593; // x11 = 1
        mem[2102] = 32'h08B52023; // COMMIT L1 F4 C2 T3 = 18
        mem[2103] = 32'h00400593; // x11 = 4
        mem[2104] = 32'h06B52823; // L1 weight filter = 4
        mem[2105] = 32'h00200593; // x11 = 2
        mem[2106] = 32'h06B52A23; // L1 weight channel = 2
        mem[2107] = 32'h00400593; // x11 = 4
        mem[2108] = 32'h06B52C23; // L1 weight tap = 4
        mem[2109] = 32'h00E00593; // x11 = 14
        mem[2110] = 32'h06B52E23; // L1 weight data = 14
        mem[2111] = 32'h00100593; // x11 = 1
        mem[2112] = 32'h08B52023; // COMMIT L1 F4 C2 T4 = 14
        mem[2113] = 32'h00400593; // x11 = 4
        mem[2114] = 32'h06B52823; // L1 weight filter = 4
        mem[2115] = 32'h00200593; // x11 = 2
        mem[2116] = 32'h06B52A23; // L1 weight channel = 2
        mem[2117] = 32'h00500593; // x11 = 5
        mem[2118] = 32'h06B52C23; // L1 weight tap = 5
        mem[2119] = 32'h00700593; // x11 = 7
        mem[2120] = 32'h06B52E23; // L1 weight data = 7
        mem[2121] = 32'h00100593; // x11 = 1
        mem[2122] = 32'h08B52023; // COMMIT L1 F4 C2 T5 = 7
        mem[2123] = 32'h00400593; // x11 = 4
        mem[2124] = 32'h06B52823; // L1 weight filter = 4
        mem[2125] = 32'h00200593; // x11 = 2
        mem[2126] = 32'h06B52A23; // L1 weight channel = 2
        mem[2127] = 32'h00600593; // x11 = 6
        mem[2128] = 32'h06B52C23; // L1 weight tap = 6
        mem[2129] = 32'hFED00593; // x11 = -19
        mem[2130] = 32'h06B52E23; // L1 weight data = -19
        mem[2131] = 32'h00100593; // x11 = 1
        mem[2132] = 32'h08B52023; // COMMIT L1 F4 C2 T6 = -19
        mem[2133] = 32'h00400593; // x11 = 4
        mem[2134] = 32'h06B52823; // L1 weight filter = 4
        mem[2135] = 32'h00200593; // x11 = 2
        mem[2136] = 32'h06B52A23; // L1 weight channel = 2
        mem[2137] = 32'h00700593; // x11 = 7
        mem[2138] = 32'h06B52C23; // L1 weight tap = 7
        mem[2139] = 32'hFD900593; // x11 = -39
        mem[2140] = 32'h06B52E23; // L1 weight data = -39
        mem[2141] = 32'h00100593; // x11 = 1
        mem[2142] = 32'h08B52023; // COMMIT L1 F4 C2 T7 = -39
        mem[2143] = 32'h00400593; // x11 = 4
        mem[2144] = 32'h06B52823; // L1 weight filter = 4
        mem[2145] = 32'h00300593; // x11 = 3
        mem[2146] = 32'h06B52A23; // L1 weight channel = 3
        mem[2147] = 32'h00000593; // x11 = 0
        mem[2148] = 32'h06B52C23; // L1 weight tap = 0
        mem[2149] = 32'hFF800593; // x11 = -8
        mem[2150] = 32'h06B52E23; // L1 weight data = -8
        mem[2151] = 32'h00100593; // x11 = 1
        mem[2152] = 32'h08B52023; // COMMIT L1 F4 C3 T0 = -8
        mem[2153] = 32'h00400593; // x11 = 4
        mem[2154] = 32'h06B52823; // L1 weight filter = 4
        mem[2155] = 32'h00300593; // x11 = 3
        mem[2156] = 32'h06B52A23; // L1 weight channel = 3
        mem[2157] = 32'h00100593; // x11 = 1
        mem[2158] = 32'h06B52C23; // L1 weight tap = 1
        mem[2159] = 32'h01F00593; // x11 = 31
        mem[2160] = 32'h06B52E23; // L1 weight data = 31
        mem[2161] = 32'h00100593; // x11 = 1
        mem[2162] = 32'h08B52023; // COMMIT L1 F4 C3 T1 = 31
        mem[2163] = 32'h00400593; // x11 = 4
        mem[2164] = 32'h06B52823; // L1 weight filter = 4
        mem[2165] = 32'h00300593; // x11 = 3
        mem[2166] = 32'h06B52A23; // L1 weight channel = 3
        mem[2167] = 32'h00200593; // x11 = 2
        mem[2168] = 32'h06B52C23; // L1 weight tap = 2
        mem[2169] = 32'h03600593; // x11 = 54
        mem[2170] = 32'h06B52E23; // L1 weight data = 54
        mem[2171] = 32'h00100593; // x11 = 1
        mem[2172] = 32'h08B52023; // COMMIT L1 F4 C3 T2 = 54
        mem[2173] = 32'h00400593; // x11 = 4
        mem[2174] = 32'h06B52823; // L1 weight filter = 4
        mem[2175] = 32'h00300593; // x11 = 3
        mem[2176] = 32'h06B52A23; // L1 weight channel = 3
        mem[2177] = 32'h00300593; // x11 = 3
        mem[2178] = 32'h06B52C23; // L1 weight tap = 3
        mem[2179] = 32'hFFA00593; // x11 = -6
        mem[2180] = 32'h06B52E23; // L1 weight data = -6
        mem[2181] = 32'h00100593; // x11 = 1
        mem[2182] = 32'h08B52023; // COMMIT L1 F4 C3 T3 = -6
        mem[2183] = 32'h00400593; // x11 = 4
        mem[2184] = 32'h06B52823; // L1 weight filter = 4
        mem[2185] = 32'h00300593; // x11 = 3
        mem[2186] = 32'h06B52A23; // L1 weight channel = 3
        mem[2187] = 32'h00400593; // x11 = 4
        mem[2188] = 32'h06B52C23; // L1 weight tap = 4
        mem[2189] = 32'h02000593; // x11 = 32
        mem[2190] = 32'h06B52E23; // L1 weight data = 32
        mem[2191] = 32'h00100593; // x11 = 1
        mem[2192] = 32'h08B52023; // COMMIT L1 F4 C3 T4 = 32
        mem[2193] = 32'h00400593; // x11 = 4
        mem[2194] = 32'h06B52823; // L1 weight filter = 4
        mem[2195] = 32'h00300593; // x11 = 3
        mem[2196] = 32'h06B52A23; // L1 weight channel = 3
        mem[2197] = 32'h00500593; // x11 = 5
        mem[2198] = 32'h06B52C23; // L1 weight tap = 5
        mem[2199] = 32'hFFE00593; // x11 = -2
        mem[2200] = 32'h06B52E23; // L1 weight data = -2
        mem[2201] = 32'h00100593; // x11 = 1
        mem[2202] = 32'h08B52023; // COMMIT L1 F4 C3 T5 = -2
        mem[2203] = 32'h00400593; // x11 = 4
        mem[2204] = 32'h06B52823; // L1 weight filter = 4
        mem[2205] = 32'h00300593; // x11 = 3
        mem[2206] = 32'h06B52A23; // L1 weight channel = 3
        mem[2207] = 32'h00600593; // x11 = 6
        mem[2208] = 32'h06B52C23; // L1 weight tap = 6
        mem[2209] = 32'hFF000593; // x11 = -16
        mem[2210] = 32'h06B52E23; // L1 weight data = -16
        mem[2211] = 32'h00100593; // x11 = 1
        mem[2212] = 32'h08B52023; // COMMIT L1 F4 C3 T6 = -16
        mem[2213] = 32'h00400593; // x11 = 4
        mem[2214] = 32'h06B52823; // L1 weight filter = 4
        mem[2215] = 32'h00300593; // x11 = 3
        mem[2216] = 32'h06B52A23; // L1 weight channel = 3
        mem[2217] = 32'h00700593; // x11 = 7
        mem[2218] = 32'h06B52C23; // L1 weight tap = 7
        mem[2219] = 32'h02A00593; // x11 = 42
        mem[2220] = 32'h06B52E23; // L1 weight data = 42
        mem[2221] = 32'h00100593; // x11 = 1
        mem[2222] = 32'h08B52023; // COMMIT L1 F4 C3 T7 = 42
        mem[2223] = 32'h00400593; // x11 = 4
        mem[2224] = 32'h06B52823; // L1 weight filter = 4
        mem[2225] = 32'h00300593; // x11 = 3
        mem[2226] = 32'h06B52A23; // L1 weight channel = 3
        mem[2227] = 32'h00800593; // x11 = 8
        mem[2228] = 32'h06B52C23; // L1 weight tap = 8
        mem[2229] = 32'hFFF00593; // x11 = -1
        mem[2230] = 32'h06B52E23; // L1 weight data = -1
        mem[2231] = 32'h00100593; // x11 = 1
        mem[2232] = 32'h08B52023; // COMMIT L1 F4 C3 T8 = -1
        mem[2233] = 32'h00500593; // x11 = 5
        mem[2234] = 32'h06B52823; // L1 weight filter = 5
        mem[2235] = 32'h00000593; // x11 = 0
        mem[2236] = 32'h06B52A23; // L1 weight channel = 0
        mem[2237] = 32'h00000593; // x11 = 0
        mem[2238] = 32'h06B52C23; // L1 weight tap = 0
        mem[2239] = 32'h02900593; // x11 = 41
        mem[2240] = 32'h06B52E23; // L1 weight data = 41
        mem[2241] = 32'h00100593; // x11 = 1
        mem[2242] = 32'h08B52023; // COMMIT L1 F5 C0 T0 = 41
        mem[2243] = 32'h00500593; // x11 = 5
        mem[2244] = 32'h06B52823; // L1 weight filter = 5
        mem[2245] = 32'h00000593; // x11 = 0
        mem[2246] = 32'h06B52A23; // L1 weight channel = 0
        mem[2247] = 32'h00100593; // x11 = 1
        mem[2248] = 32'h06B52C23; // L1 weight tap = 1
        mem[2249] = 32'hFF500593; // x11 = -11
        mem[2250] = 32'h06B52E23; // L1 weight data = -11
        mem[2251] = 32'h00100593; // x11 = 1
        mem[2252] = 32'h08B52023; // COMMIT L1 F5 C0 T1 = -11
        mem[2253] = 32'h00500593; // x11 = 5
        mem[2254] = 32'h06B52823; // L1 weight filter = 5
        mem[2255] = 32'h00000593; // x11 = 0
        mem[2256] = 32'h06B52A23; // L1 weight channel = 0
        mem[2257] = 32'h00200593; // x11 = 2
        mem[2258] = 32'h06B52C23; // L1 weight tap = 2
        mem[2259] = 32'hFDF00593; // x11 = -33
        mem[2260] = 32'h06B52E23; // L1 weight data = -33
        mem[2261] = 32'h00100593; // x11 = 1
        mem[2262] = 32'h08B52023; // COMMIT L1 F5 C0 T2 = -33
        mem[2263] = 32'h00500593; // x11 = 5
        mem[2264] = 32'h06B52823; // L1 weight filter = 5
        mem[2265] = 32'h00000593; // x11 = 0
        mem[2266] = 32'h06B52A23; // L1 weight channel = 0
        mem[2267] = 32'h00300593; // x11 = 3
        mem[2268] = 32'h06B52C23; // L1 weight tap = 3
        mem[2269] = 32'hFCA00593; // x11 = -54
        mem[2270] = 32'h06B52E23; // L1 weight data = -54
        mem[2271] = 32'h00100593; // x11 = 1
        mem[2272] = 32'h08B52023; // COMMIT L1 F5 C0 T3 = -54
        mem[2273] = 32'h00500593; // x11 = 5
        mem[2274] = 32'h06B52823; // L1 weight filter = 5
        mem[2275] = 32'h00000593; // x11 = 0
        mem[2276] = 32'h06B52A23; // L1 weight channel = 0
        mem[2277] = 32'h00400593; // x11 = 4
        mem[2278] = 32'h06B52C23; // L1 weight tap = 4
        mem[2279] = 32'h02000593; // x11 = 32
        mem[2280] = 32'h06B52E23; // L1 weight data = 32
        mem[2281] = 32'h00100593; // x11 = 1
        mem[2282] = 32'h08B52023; // COMMIT L1 F5 C0 T4 = 32
        mem[2283] = 32'h00500593; // x11 = 5
        mem[2284] = 32'h06B52823; // L1 weight filter = 5
        mem[2285] = 32'h00000593; // x11 = 0
        mem[2286] = 32'h06B52A23; // L1 weight channel = 0
        mem[2287] = 32'h00500593; // x11 = 5
        mem[2288] = 32'h06B52C23; // L1 weight tap = 5
        mem[2289] = 32'h01A00593; // x11 = 26
        mem[2290] = 32'h06B52E23; // L1 weight data = 26
        mem[2291] = 32'h00100593; // x11 = 1
        mem[2292] = 32'h08B52023; // COMMIT L1 F5 C0 T5 = 26
        mem[2293] = 32'h00500593; // x11 = 5
        mem[2294] = 32'h06B52823; // L1 weight filter = 5
        mem[2295] = 32'h00000593; // x11 = 0
        mem[2296] = 32'h06B52A23; // L1 weight channel = 0
        mem[2297] = 32'h00600593; // x11 = 6
        mem[2298] = 32'h06B52C23; // L1 weight tap = 6
        mem[2299] = 32'h04500593; // x11 = 69
        mem[2300] = 32'h06B52E23; // L1 weight data = 69
        mem[2301] = 32'h00100593; // x11 = 1
        mem[2302] = 32'h08B52023; // COMMIT L1 F5 C0 T6 = 69
        mem[2303] = 32'h00500593; // x11 = 5
        mem[2304] = 32'h06B52823; // L1 weight filter = 5
        mem[2305] = 32'h00000593; // x11 = 0
        mem[2306] = 32'h06B52A23; // L1 weight channel = 0
        mem[2307] = 32'h00700593; // x11 = 7
        mem[2308] = 32'h06B52C23; // L1 weight tap = 7
        mem[2309] = 32'hFF000593; // x11 = -16
        mem[2310] = 32'h06B52E23; // L1 weight data = -16
        mem[2311] = 32'h00100593; // x11 = 1
        mem[2312] = 32'h08B52023; // COMMIT L1 F5 C0 T7 = -16
        mem[2313] = 32'h00500593; // x11 = 5
        mem[2314] = 32'h06B52823; // L1 weight filter = 5
        mem[2315] = 32'h00000593; // x11 = 0
        mem[2316] = 32'h06B52A23; // L1 weight channel = 0
        mem[2317] = 32'h00800593; // x11 = 8
        mem[2318] = 32'h06B52C23; // L1 weight tap = 8
        mem[2319] = 32'hFFB00593; // x11 = -5
        mem[2320] = 32'h06B52E23; // L1 weight data = -5
        mem[2321] = 32'h00100593; // x11 = 1
        mem[2322] = 32'h08B52023; // COMMIT L1 F5 C0 T8 = -5
        mem[2323] = 32'h00500593; // x11 = 5
        mem[2324] = 32'h06B52823; // L1 weight filter = 5
        mem[2325] = 32'h00100593; // x11 = 1
        mem[2326] = 32'h06B52A23; // L1 weight channel = 1
        mem[2327] = 32'h00000593; // x11 = 0
        mem[2328] = 32'h06B52C23; // L1 weight tap = 0
        mem[2329] = 32'h01700593; // x11 = 23
        mem[2330] = 32'h06B52E23; // L1 weight data = 23
        mem[2331] = 32'h00100593; // x11 = 1
        mem[2332] = 32'h08B52023; // COMMIT L1 F5 C1 T0 = 23
        mem[2333] = 32'h00500593; // x11 = 5
        mem[2334] = 32'h06B52823; // L1 weight filter = 5
        mem[2335] = 32'h00100593; // x11 = 1
        mem[2336] = 32'h06B52A23; // L1 weight channel = 1
        mem[2337] = 32'h00100593; // x11 = 1
        mem[2338] = 32'h06B52C23; // L1 weight tap = 1
        mem[2339] = 32'h00100593; // x11 = 1
        mem[2340] = 32'h06B52E23; // L1 weight data = 1
        mem[2341] = 32'h00100593; // x11 = 1
        mem[2342] = 32'h08B52023; // COMMIT L1 F5 C1 T1 = 1
        mem[2343] = 32'h00500593; // x11 = 5
        mem[2344] = 32'h06B52823; // L1 weight filter = 5
        mem[2345] = 32'h00100593; // x11 = 1
        mem[2346] = 32'h06B52A23; // L1 weight channel = 1
        mem[2347] = 32'h00200593; // x11 = 2
        mem[2348] = 32'h06B52C23; // L1 weight tap = 2
        mem[2349] = 32'hFEA00593; // x11 = -22
        mem[2350] = 32'h06B52E23; // L1 weight data = -22
        mem[2351] = 32'h00100593; // x11 = 1
        mem[2352] = 32'h08B52023; // COMMIT L1 F5 C1 T2 = -22
        mem[2353] = 32'h00500593; // x11 = 5
        mem[2354] = 32'h06B52823; // L1 weight filter = 5
        mem[2355] = 32'h00100593; // x11 = 1
        mem[2356] = 32'h06B52A23; // L1 weight channel = 1
        mem[2357] = 32'h00300593; // x11 = 3
        mem[2358] = 32'h06B52C23; // L1 weight tap = 3
        mem[2359] = 32'hFF100593; // x11 = -15
        mem[2360] = 32'h06B52E23; // L1 weight data = -15
        mem[2361] = 32'h00100593; // x11 = 1
        mem[2362] = 32'h08B52023; // COMMIT L1 F5 C1 T3 = -15
        mem[2363] = 32'h00500593; // x11 = 5
        mem[2364] = 32'h06B52823; // L1 weight filter = 5
        mem[2365] = 32'h00100593; // x11 = 1
        mem[2366] = 32'h06B52A23; // L1 weight channel = 1
        mem[2367] = 32'h00400593; // x11 = 4
        mem[2368] = 32'h06B52C23; // L1 weight tap = 4
        mem[2369] = 32'h00E00593; // x11 = 14
        mem[2370] = 32'h06B52E23; // L1 weight data = 14
        mem[2371] = 32'h00100593; // x11 = 1
        mem[2372] = 32'h08B52023; // COMMIT L1 F5 C1 T4 = 14
        mem[2373] = 32'h00500593; // x11 = 5
        mem[2374] = 32'h06B52823; // L1 weight filter = 5
        mem[2375] = 32'h00100593; // x11 = 1
        mem[2376] = 32'h06B52A23; // L1 weight channel = 1
        mem[2377] = 32'h00500593; // x11 = 5
        mem[2378] = 32'h06B52C23; // L1 weight tap = 5
        mem[2379] = 32'hFF100593; // x11 = -15
        mem[2380] = 32'h06B52E23; // L1 weight data = -15
        mem[2381] = 32'h00100593; // x11 = 1
        mem[2382] = 32'h08B52023; // COMMIT L1 F5 C1 T5 = -15
        mem[2383] = 32'h00500593; // x11 = 5
        mem[2384] = 32'h06B52823; // L1 weight filter = 5
        mem[2385] = 32'h00100593; // x11 = 1
        mem[2386] = 32'h06B52A23; // L1 weight channel = 1
        mem[2387] = 32'h00600593; // x11 = 6
        mem[2388] = 32'h06B52C23; // L1 weight tap = 6
        mem[2389] = 32'h00500593; // x11 = 5
        mem[2390] = 32'h06B52E23; // L1 weight data = 5
        mem[2391] = 32'h00100593; // x11 = 1
        mem[2392] = 32'h08B52023; // COMMIT L1 F5 C1 T6 = 5
        mem[2393] = 32'h00500593; // x11 = 5
        mem[2394] = 32'h06B52823; // L1 weight filter = 5
        mem[2395] = 32'h00100593; // x11 = 1
        mem[2396] = 32'h06B52A23; // L1 weight channel = 1
        mem[2397] = 32'h00700593; // x11 = 7
        mem[2398] = 32'h06B52C23; // L1 weight tap = 7
        mem[2399] = 32'h00100593; // x11 = 1
        mem[2400] = 32'h06B52E23; // L1 weight data = 1
        mem[2401] = 32'h00100593; // x11 = 1
        mem[2402] = 32'h08B52023; // COMMIT L1 F5 C1 T7 = 1
        mem[2403] = 32'h00500593; // x11 = 5
        mem[2404] = 32'h06B52823; // L1 weight filter = 5
        mem[2405] = 32'h00100593; // x11 = 1
        mem[2406] = 32'h06B52A23; // L1 weight channel = 1
        mem[2407] = 32'h00800593; // x11 = 8
        mem[2408] = 32'h06B52C23; // L1 weight tap = 8
        mem[2409] = 32'hFF200593; // x11 = -14
        mem[2410] = 32'h06B52E23; // L1 weight data = -14
        mem[2411] = 32'h00100593; // x11 = 1
        mem[2412] = 32'h08B52023; // COMMIT L1 F5 C1 T8 = -14
        mem[2413] = 32'h00500593; // x11 = 5
        mem[2414] = 32'h06B52823; // L1 weight filter = 5
        mem[2415] = 32'h00200593; // x11 = 2
        mem[2416] = 32'h06B52A23; // L1 weight channel = 2
        mem[2417] = 32'h00000593; // x11 = 0
        mem[2418] = 32'h06B52C23; // L1 weight tap = 0
        mem[2419] = 32'h04100593; // x11 = 65
        mem[2420] = 32'h06B52E23; // L1 weight data = 65
        mem[2421] = 32'h00100593; // x11 = 1
        mem[2422] = 32'h08B52023; // COMMIT L1 F5 C2 T0 = 65
        mem[2423] = 32'h00500593; // x11 = 5
        mem[2424] = 32'h06B52823; // L1 weight filter = 5
        mem[2425] = 32'h00200593; // x11 = 2
        mem[2426] = 32'h06B52A23; // L1 weight channel = 2
        mem[2427] = 32'h00100593; // x11 = 1
        mem[2428] = 32'h06B52C23; // L1 weight tap = 1
        mem[2429] = 32'h00D00593; // x11 = 13
        mem[2430] = 32'h06B52E23; // L1 weight data = 13
        mem[2431] = 32'h00100593; // x11 = 1
        mem[2432] = 32'h08B52023; // COMMIT L1 F5 C2 T1 = 13
        mem[2433] = 32'h00500593; // x11 = 5
        mem[2434] = 32'h06B52823; // L1 weight filter = 5
        mem[2435] = 32'h00200593; // x11 = 2
        mem[2436] = 32'h06B52A23; // L1 weight channel = 2
        mem[2437] = 32'h00200593; // x11 = 2
        mem[2438] = 32'h06B52C23; // L1 weight tap = 2
        mem[2439] = 32'hFF100593; // x11 = -15
        mem[2440] = 32'h06B52E23; // L1 weight data = -15
        mem[2441] = 32'h00100593; // x11 = 1
        mem[2442] = 32'h08B52023; // COMMIT L1 F5 C2 T2 = -15
        mem[2443] = 32'h00500593; // x11 = 5
        mem[2444] = 32'h06B52823; // L1 weight filter = 5
        mem[2445] = 32'h00200593; // x11 = 2
        mem[2446] = 32'h06B52A23; // L1 weight channel = 2
        mem[2447] = 32'h00300593; // x11 = 3
        mem[2448] = 32'h06B52C23; // L1 weight tap = 3
        mem[2449] = 32'h01C00593; // x11 = 28
        mem[2450] = 32'h06B52E23; // L1 weight data = 28
        mem[2451] = 32'h00100593; // x11 = 1
        mem[2452] = 32'h08B52023; // COMMIT L1 F5 C2 T3 = 28
        mem[2453] = 32'h00500593; // x11 = 5
        mem[2454] = 32'h06B52823; // L1 weight filter = 5
        mem[2455] = 32'h00200593; // x11 = 2
        mem[2456] = 32'h06B52A23; // L1 weight channel = 2
        mem[2457] = 32'h00400593; // x11 = 4
        mem[2458] = 32'h06B52C23; // L1 weight tap = 4
        mem[2459] = 32'hFF500593; // x11 = -11
        mem[2460] = 32'h06B52E23; // L1 weight data = -11
        mem[2461] = 32'h00100593; // x11 = 1
        mem[2462] = 32'h08B52023; // COMMIT L1 F5 C2 T4 = -11
        mem[2463] = 32'h00500593; // x11 = 5
        mem[2464] = 32'h06B52823; // L1 weight filter = 5
        mem[2465] = 32'h00200593; // x11 = 2
        mem[2466] = 32'h06B52A23; // L1 weight channel = 2
        mem[2467] = 32'h00500593; // x11 = 5
        mem[2468] = 32'h06B52C23; // L1 weight tap = 5
        mem[2469] = 32'h03600593; // x11 = 54
        mem[2470] = 32'h06B52E23; // L1 weight data = 54
        mem[2471] = 32'h00100593; // x11 = 1
        mem[2472] = 32'h08B52023; // COMMIT L1 F5 C2 T5 = 54
        mem[2473] = 32'h00500593; // x11 = 5
        mem[2474] = 32'h06B52823; // L1 weight filter = 5
        mem[2475] = 32'h00200593; // x11 = 2
        mem[2476] = 32'h06B52A23; // L1 weight channel = 2
        mem[2477] = 32'h00600593; // x11 = 6
        mem[2478] = 32'h06B52C23; // L1 weight tap = 6
        mem[2479] = 32'h00100593; // x11 = 1
        mem[2480] = 32'h06B52E23; // L1 weight data = 1
        mem[2481] = 32'h00100593; // x11 = 1
        mem[2482] = 32'h08B52023; // COMMIT L1 F5 C2 T6 = 1
        mem[2483] = 32'h00500593; // x11 = 5
        mem[2484] = 32'h06B52823; // L1 weight filter = 5
        mem[2485] = 32'h00200593; // x11 = 2
        mem[2486] = 32'h06B52A23; // L1 weight channel = 2
        mem[2487] = 32'h00700593; // x11 = 7
        mem[2488] = 32'h06B52C23; // L1 weight tap = 7
        mem[2489] = 32'h01700593; // x11 = 23
        mem[2490] = 32'h06B52E23; // L1 weight data = 23
        mem[2491] = 32'h00100593; // x11 = 1
        mem[2492] = 32'h08B52023; // COMMIT L1 F5 C2 T7 = 23
        mem[2493] = 32'h00500593; // x11 = 5
        mem[2494] = 32'h06B52823; // L1 weight filter = 5
        mem[2495] = 32'h00200593; // x11 = 2
        mem[2496] = 32'h06B52A23; // L1 weight channel = 2
        mem[2497] = 32'h00800593; // x11 = 8
        mem[2498] = 32'h06B52C23; // L1 weight tap = 8
        mem[2499] = 32'h02000593; // x11 = 32
        mem[2500] = 32'h06B52E23; // L1 weight data = 32
        mem[2501] = 32'h00100593; // x11 = 1
        mem[2502] = 32'h08B52023; // COMMIT L1 F5 C2 T8 = 32
        mem[2503] = 32'h00500593; // x11 = 5
        mem[2504] = 32'h06B52823; // L1 weight filter = 5
        mem[2505] = 32'h00300593; // x11 = 3
        mem[2506] = 32'h06B52A23; // L1 weight channel = 3
        mem[2507] = 32'h00000593; // x11 = 0
        mem[2508] = 32'h06B52C23; // L1 weight tap = 0
        mem[2509] = 32'h02000593; // x11 = 32
        mem[2510] = 32'h06B52E23; // L1 weight data = 32
        mem[2511] = 32'h00100593; // x11 = 1
        mem[2512] = 32'h08B52023; // COMMIT L1 F5 C3 T0 = 32
        mem[2513] = 32'h00500593; // x11 = 5
        mem[2514] = 32'h06B52823; // L1 weight filter = 5
        mem[2515] = 32'h00300593; // x11 = 3
        mem[2516] = 32'h06B52A23; // L1 weight channel = 3
        mem[2517] = 32'h00100593; // x11 = 1
        mem[2518] = 32'h06B52C23; // L1 weight tap = 1
        mem[2519] = 32'hFE000593; // x11 = -32
        mem[2520] = 32'h06B52E23; // L1 weight data = -32
        mem[2521] = 32'h00100593; // x11 = 1
        mem[2522] = 32'h08B52023; // COMMIT L1 F5 C3 T1 = -32
        mem[2523] = 32'h00500593; // x11 = 5
        mem[2524] = 32'h06B52823; // L1 weight filter = 5
        mem[2525] = 32'h00300593; // x11 = 3
        mem[2526] = 32'h06B52A23; // L1 weight channel = 3
        mem[2527] = 32'h00200593; // x11 = 2
        mem[2528] = 32'h06B52C23; // L1 weight tap = 2
        mem[2529] = 32'h01100593; // x11 = 17
        mem[2530] = 32'h06B52E23; // L1 weight data = 17
        mem[2531] = 32'h00100593; // x11 = 1
        mem[2532] = 32'h08B52023; // COMMIT L1 F5 C3 T2 = 17
        mem[2533] = 32'h00500593; // x11 = 5
        mem[2534] = 32'h06B52823; // L1 weight filter = 5
        mem[2535] = 32'h00300593; // x11 = 3
        mem[2536] = 32'h06B52A23; // L1 weight channel = 3
        mem[2537] = 32'h00300593; // x11 = 3
        mem[2538] = 32'h06B52C23; // L1 weight tap = 3
        mem[2539] = 32'hFEC00593; // x11 = -20
        mem[2540] = 32'h06B52E23; // L1 weight data = -20
        mem[2541] = 32'h00100593; // x11 = 1
        mem[2542] = 32'h08B52023; // COMMIT L1 F5 C3 T3 = -20
        mem[2543] = 32'h00500593; // x11 = 5
        mem[2544] = 32'h06B52823; // L1 weight filter = 5
        mem[2545] = 32'h00300593; // x11 = 3
        mem[2546] = 32'h06B52A23; // L1 weight channel = 3
        mem[2547] = 32'h00400593; // x11 = 4
        mem[2548] = 32'h06B52C23; // L1 weight tap = 4
        mem[2549] = 32'hFF900593; // x11 = -7
        mem[2550] = 32'h06B52E23; // L1 weight data = -7
        mem[2551] = 32'h00100593; // x11 = 1
        mem[2552] = 32'h08B52023; // COMMIT L1 F5 C3 T4 = -7
        mem[2553] = 32'h00500593; // x11 = 5
        mem[2554] = 32'h06B52823; // L1 weight filter = 5
        mem[2555] = 32'h00300593; // x11 = 3
        mem[2556] = 32'h06B52A23; // L1 weight channel = 3
        mem[2557] = 32'h00500593; // x11 = 5
        mem[2558] = 32'h06B52C23; // L1 weight tap = 5
        mem[2559] = 32'h02300593; // x11 = 35
        mem[2560] = 32'h06B52E23; // L1 weight data = 35
        mem[2561] = 32'h00100593; // x11 = 1
        mem[2562] = 32'h08B52023; // COMMIT L1 F5 C3 T5 = 35
        mem[2563] = 32'h00500593; // x11 = 5
        mem[2564] = 32'h06B52823; // L1 weight filter = 5
        mem[2565] = 32'h00300593; // x11 = 3
        mem[2566] = 32'h06B52A23; // L1 weight channel = 3
        mem[2567] = 32'h00600593; // x11 = 6
        mem[2568] = 32'h06B52C23; // L1 weight tap = 6
        mem[2569] = 32'h02300593; // x11 = 35
        mem[2570] = 32'h06B52E23; // L1 weight data = 35
        mem[2571] = 32'h00100593; // x11 = 1
        mem[2572] = 32'h08B52023; // COMMIT L1 F5 C3 T6 = 35
        mem[2573] = 32'h00500593; // x11 = 5
        mem[2574] = 32'h06B52823; // L1 weight filter = 5
        mem[2575] = 32'h00300593; // x11 = 3
        mem[2576] = 32'h06B52A23; // L1 weight channel = 3
        mem[2577] = 32'h00700593; // x11 = 7
        mem[2578] = 32'h06B52C23; // L1 weight tap = 7
        mem[2579] = 32'hFE300593; // x11 = -29
        mem[2580] = 32'h06B52E23; // L1 weight data = -29
        mem[2581] = 32'h00100593; // x11 = 1
        mem[2582] = 32'h08B52023; // COMMIT L1 F5 C3 T7 = -29
        mem[2583] = 32'h00500593; // x11 = 5
        mem[2584] = 32'h06B52823; // L1 weight filter = 5
        mem[2585] = 32'h00300593; // x11 = 3
        mem[2586] = 32'h06B52A23; // L1 weight channel = 3
        mem[2587] = 32'h00800593; // x11 = 8
        mem[2588] = 32'h06B52C23; // L1 weight tap = 8
        mem[2589] = 32'h01D00593; // x11 = 29
        mem[2590] = 32'h06B52E23; // L1 weight data = 29
        mem[2591] = 32'h00100593; // x11 = 1
        mem[2592] = 32'h08B52023; // COMMIT L1 F5 C3 T8 = 29
        mem[2593] = 32'h00600593; // x11 = 6
        mem[2594] = 32'h06B52823; // L1 weight filter = 6
        mem[2595] = 32'h00000593; // x11 = 0
        mem[2596] = 32'h06B52A23; // L1 weight channel = 0
        mem[2597] = 32'h00000593; // x11 = 0
        mem[2598] = 32'h06B52C23; // L1 weight tap = 0
        mem[2599] = 32'h00600593; // x11 = 6
        mem[2600] = 32'h06B52E23; // L1 weight data = 6
        mem[2601] = 32'h00100593; // x11 = 1
        mem[2602] = 32'h08B52023; // COMMIT L1 F6 C0 T0 = 6
        mem[2603] = 32'h00600593; // x11 = 6
        mem[2604] = 32'h06B52823; // L1 weight filter = 6
        mem[2605] = 32'h00000593; // x11 = 0
        mem[2606] = 32'h06B52A23; // L1 weight channel = 0
        mem[2607] = 32'h00100593; // x11 = 1
        mem[2608] = 32'h06B52C23; // L1 weight tap = 1
        mem[2609] = 32'h01F00593; // x11 = 31
        mem[2610] = 32'h06B52E23; // L1 weight data = 31
        mem[2611] = 32'h00100593; // x11 = 1
        mem[2612] = 32'h08B52023; // COMMIT L1 F6 C0 T1 = 31
        mem[2613] = 32'h00600593; // x11 = 6
        mem[2614] = 32'h06B52823; // L1 weight filter = 6
        mem[2615] = 32'h00000593; // x11 = 0
        mem[2616] = 32'h06B52A23; // L1 weight channel = 0
        mem[2617] = 32'h00200593; // x11 = 2
        mem[2618] = 32'h06B52C23; // L1 weight tap = 2
        mem[2619] = 32'h00A00593; // x11 = 10
        mem[2620] = 32'h06B52E23; // L1 weight data = 10
        mem[2621] = 32'h00100593; // x11 = 1
        mem[2622] = 32'h08B52023; // COMMIT L1 F6 C0 T2 = 10
        mem[2623] = 32'h00600593; // x11 = 6
        mem[2624] = 32'h06B52823; // L1 weight filter = 6
        mem[2625] = 32'h00000593; // x11 = 0
        mem[2626] = 32'h06B52A23; // L1 weight channel = 0
        mem[2627] = 32'h00300593; // x11 = 3
        mem[2628] = 32'h06B52C23; // L1 weight tap = 3
        mem[2629] = 32'h01A00593; // x11 = 26
        mem[2630] = 32'h06B52E23; // L1 weight data = 26
        mem[2631] = 32'h00100593; // x11 = 1
        mem[2632] = 32'h08B52023; // COMMIT L1 F6 C0 T3 = 26
        mem[2633] = 32'h00600593; // x11 = 6
        mem[2634] = 32'h06B52823; // L1 weight filter = 6
        mem[2635] = 32'h00000593; // x11 = 0
        mem[2636] = 32'h06B52A23; // L1 weight channel = 0
        mem[2637] = 32'h00400593; // x11 = 4
        mem[2638] = 32'h06B52C23; // L1 weight tap = 4
        mem[2639] = 32'hFBB00593; // x11 = -69
        mem[2640] = 32'h06B52E23; // L1 weight data = -69
        mem[2641] = 32'h00100593; // x11 = 1
        mem[2642] = 32'h08B52023; // COMMIT L1 F6 C0 T4 = -69
        mem[2643] = 32'h00600593; // x11 = 6
        mem[2644] = 32'h06B52823; // L1 weight filter = 6
        mem[2645] = 32'h00000593; // x11 = 0
        mem[2646] = 32'h06B52A23; // L1 weight channel = 0
        mem[2647] = 32'h00500593; // x11 = 5
        mem[2648] = 32'h06B52C23; // L1 weight tap = 5
        mem[2649] = 32'hFAE00593; // x11 = -82
        mem[2650] = 32'h06B52E23; // L1 weight data = -82
        mem[2651] = 32'h00100593; // x11 = 1
        mem[2652] = 32'h08B52023; // COMMIT L1 F6 C0 T5 = -82
        mem[2653] = 32'h00600593; // x11 = 6
        mem[2654] = 32'h06B52823; // L1 weight filter = 6
        mem[2655] = 32'h00000593; // x11 = 0
        mem[2656] = 32'h06B52A23; // L1 weight channel = 0
        mem[2657] = 32'h00600593; // x11 = 6
        mem[2658] = 32'h06B52C23; // L1 weight tap = 6
        mem[2659] = 32'h03C00593; // x11 = 60
        mem[2660] = 32'h06B52E23; // L1 weight data = 60
        mem[2661] = 32'h00100593; // x11 = 1
        mem[2662] = 32'h08B52023; // COMMIT L1 F6 C0 T6 = 60
        mem[2663] = 32'h00600593; // x11 = 6
        mem[2664] = 32'h06B52823; // L1 weight filter = 6
        mem[2665] = 32'h00000593; // x11 = 0
        mem[2666] = 32'h06B52A23; // L1 weight channel = 0
        mem[2667] = 32'h00700593; // x11 = 7
        mem[2668] = 32'h06B52C23; // L1 weight tap = 7
        mem[2669] = 32'h03700593; // x11 = 55
        mem[2670] = 32'h06B52E23; // L1 weight data = 55
        mem[2671] = 32'h00100593; // x11 = 1
        mem[2672] = 32'h08B52023; // COMMIT L1 F6 C0 T7 = 55
        mem[2673] = 32'h00600593; // x11 = 6
        mem[2674] = 32'h06B52823; // L1 weight filter = 6
        mem[2675] = 32'h00000593; // x11 = 0
        mem[2676] = 32'h06B52A23; // L1 weight channel = 0
        mem[2677] = 32'h00800593; // x11 = 8
        mem[2678] = 32'h06B52C23; // L1 weight tap = 8
        mem[2679] = 32'h02900593; // x11 = 41
        mem[2680] = 32'h06B52E23; // L1 weight data = 41
        mem[2681] = 32'h00100593; // x11 = 1
        mem[2682] = 32'h08B52023; // COMMIT L1 F6 C0 T8 = 41
        mem[2683] = 32'h00600593; // x11 = 6
        mem[2684] = 32'h06B52823; // L1 weight filter = 6
        mem[2685] = 32'h00100593; // x11 = 1
        mem[2686] = 32'h06B52A23; // L1 weight channel = 1
        mem[2687] = 32'h00000593; // x11 = 0
        mem[2688] = 32'h06B52C23; // L1 weight tap = 0
        mem[2689] = 32'hFFF00593; // x11 = -1
        mem[2690] = 32'h06B52E23; // L1 weight data = -1
        mem[2691] = 32'h00100593; // x11 = 1
        mem[2692] = 32'h08B52023; // COMMIT L1 F6 C1 T0 = -1
        mem[2693] = 32'h00600593; // x11 = 6
        mem[2694] = 32'h06B52823; // L1 weight filter = 6
        mem[2695] = 32'h00100593; // x11 = 1
        mem[2696] = 32'h06B52A23; // L1 weight channel = 1
        mem[2697] = 32'h00100593; // x11 = 1
        mem[2698] = 32'h06B52C23; // L1 weight tap = 1
        mem[2699] = 32'hFBC00593; // x11 = -68
        mem[2700] = 32'h06B52E23; // L1 weight data = -68
        mem[2701] = 32'h00100593; // x11 = 1
        mem[2702] = 32'h08B52023; // COMMIT L1 F6 C1 T1 = -68
        mem[2703] = 32'h00600593; // x11 = 6
        mem[2704] = 32'h06B52823; // L1 weight filter = 6
        mem[2705] = 32'h00100593; // x11 = 1
        mem[2706] = 32'h06B52A23; // L1 weight channel = 1
        mem[2707] = 32'h00200593; // x11 = 2
        mem[2708] = 32'h06B52C23; // L1 weight tap = 2
        mem[2709] = 32'hFEB00593; // x11 = -21
        mem[2710] = 32'h06B52E23; // L1 weight data = -21
        mem[2711] = 32'h00100593; // x11 = 1
        mem[2712] = 32'h08B52023; // COMMIT L1 F6 C1 T2 = -21
        mem[2713] = 32'h00600593; // x11 = 6
        mem[2714] = 32'h06B52823; // L1 weight filter = 6
        mem[2715] = 32'h00100593; // x11 = 1
        mem[2716] = 32'h06B52A23; // L1 weight channel = 1
        mem[2717] = 32'h00300593; // x11 = 3
        mem[2718] = 32'h06B52C23; // L1 weight tap = 3
        mem[2719] = 32'hFFB00593; // x11 = -5
        mem[2720] = 32'h06B52E23; // L1 weight data = -5
        mem[2721] = 32'h00100593; // x11 = 1
        mem[2722] = 32'h08B52023; // COMMIT L1 F6 C1 T3 = -5
        mem[2723] = 32'h00600593; // x11 = 6
        mem[2724] = 32'h06B52823; // L1 weight filter = 6
        mem[2725] = 32'h00100593; // x11 = 1
        mem[2726] = 32'h06B52A23; // L1 weight channel = 1
        mem[2727] = 32'h00400593; // x11 = 4
        mem[2728] = 32'h06B52C23; // L1 weight tap = 4
        mem[2729] = 32'hFE600593; // x11 = -26
        mem[2730] = 32'h06B52E23; // L1 weight data = -26
        mem[2731] = 32'h00100593; // x11 = 1
        mem[2732] = 32'h08B52023; // COMMIT L1 F6 C1 T4 = -26
        mem[2733] = 32'h00600593; // x11 = 6
        mem[2734] = 32'h06B52823; // L1 weight filter = 6
        mem[2735] = 32'h00100593; // x11 = 1
        mem[2736] = 32'h06B52A23; // L1 weight channel = 1
        mem[2737] = 32'h00500593; // x11 = 5
        mem[2738] = 32'h06B52C23; // L1 weight tap = 5
        mem[2739] = 32'h02200593; // x11 = 34
        mem[2740] = 32'h06B52E23; // L1 weight data = 34
        mem[2741] = 32'h00100593; // x11 = 1
        mem[2742] = 32'h08B52023; // COMMIT L1 F6 C1 T5 = 34
        mem[2743] = 32'h00600593; // x11 = 6
        mem[2744] = 32'h06B52823; // L1 weight filter = 6
        mem[2745] = 32'h00100593; // x11 = 1
        mem[2746] = 32'h06B52A23; // L1 weight channel = 1
        mem[2747] = 32'h00600593; // x11 = 6
        mem[2748] = 32'h06B52C23; // L1 weight tap = 6
        mem[2749] = 32'hFE200593; // x11 = -30
        mem[2750] = 32'h06B52E23; // L1 weight data = -30
        mem[2751] = 32'h00100593; // x11 = 1
        mem[2752] = 32'h08B52023; // COMMIT L1 F6 C1 T6 = -30
        mem[2753] = 32'h00600593; // x11 = 6
        mem[2754] = 32'h06B52823; // L1 weight filter = 6
        mem[2755] = 32'h00100593; // x11 = 1
        mem[2756] = 32'h06B52A23; // L1 weight channel = 1
        mem[2757] = 32'h00700593; // x11 = 7
        mem[2758] = 32'h06B52C23; // L1 weight tap = 7
        mem[2759] = 32'hFF600593; // x11 = -10
        mem[2760] = 32'h06B52E23; // L1 weight data = -10
        mem[2761] = 32'h00100593; // x11 = 1
        mem[2762] = 32'h08B52023; // COMMIT L1 F6 C1 T7 = -10
        mem[2763] = 32'h00600593; // x11 = 6
        mem[2764] = 32'h06B52823; // L1 weight filter = 6
        mem[2765] = 32'h00100593; // x11 = 1
        mem[2766] = 32'h06B52A23; // L1 weight channel = 1
        mem[2767] = 32'h00800593; // x11 = 8
        mem[2768] = 32'h06B52C23; // L1 weight tap = 8
        mem[2769] = 32'h00200593; // x11 = 2
        mem[2770] = 32'h06B52E23; // L1 weight data = 2
        mem[2771] = 32'h00100593; // x11 = 1
        mem[2772] = 32'h08B52023; // COMMIT L1 F6 C1 T8 = 2
        mem[2773] = 32'h00600593; // x11 = 6
        mem[2774] = 32'h06B52823; // L1 weight filter = 6
        mem[2775] = 32'h00200593; // x11 = 2
        mem[2776] = 32'h06B52A23; // L1 weight channel = 2
        mem[2777] = 32'h00000593; // x11 = 0
        mem[2778] = 32'h06B52C23; // L1 weight tap = 0
        mem[2779] = 32'h01B00593; // x11 = 27
        mem[2780] = 32'h06B52E23; // L1 weight data = 27
        mem[2781] = 32'h00100593; // x11 = 1
        mem[2782] = 32'h08B52023; // COMMIT L1 F6 C2 T0 = 27
        mem[2783] = 32'h00600593; // x11 = 6
        mem[2784] = 32'h06B52823; // L1 weight filter = 6
        mem[2785] = 32'h00200593; // x11 = 2
        mem[2786] = 32'h06B52A23; // L1 weight channel = 2
        mem[2787] = 32'h00100593; // x11 = 1
        mem[2788] = 32'h06B52C23; // L1 weight tap = 1
        mem[2789] = 32'hFE100593; // x11 = -31
        mem[2790] = 32'h06B52E23; // L1 weight data = -31
        mem[2791] = 32'h00100593; // x11 = 1
        mem[2792] = 32'h08B52023; // COMMIT L1 F6 C2 T1 = -31
        mem[2793] = 32'h00600593; // x11 = 6
        mem[2794] = 32'h06B52823; // L1 weight filter = 6
        mem[2795] = 32'h00200593; // x11 = 2
        mem[2796] = 32'h06B52A23; // L1 weight channel = 2
        mem[2797] = 32'h00200593; // x11 = 2
        mem[2798] = 32'h06B52C23; // L1 weight tap = 2
        mem[2799] = 32'h01300593; // x11 = 19
        mem[2800] = 32'h06B52E23; // L1 weight data = 19
        mem[2801] = 32'h00100593; // x11 = 1
        mem[2802] = 32'h08B52023; // COMMIT L1 F6 C2 T2 = 19
        mem[2803] = 32'h00600593; // x11 = 6
        mem[2804] = 32'h06B52823; // L1 weight filter = 6
        mem[2805] = 32'h00200593; // x11 = 2
        mem[2806] = 32'h06B52A23; // L1 weight channel = 2
        mem[2807] = 32'h00300593; // x11 = 3
        mem[2808] = 32'h06B52C23; // L1 weight tap = 3
        mem[2809] = 32'hFF800593; // x11 = -8
        mem[2810] = 32'h06B52E23; // L1 weight data = -8
        mem[2811] = 32'h00100593; // x11 = 1
        mem[2812] = 32'h08B52023; // COMMIT L1 F6 C2 T3 = -8
        mem[2813] = 32'h00600593; // x11 = 6
        mem[2814] = 32'h06B52823; // L1 weight filter = 6
        mem[2815] = 32'h00200593; // x11 = 2
        mem[2816] = 32'h06B52A23; // L1 weight channel = 2
        mem[2817] = 32'h00400593; // x11 = 4
        mem[2818] = 32'h06B52C23; // L1 weight tap = 4
        mem[2819] = 32'hFE500593; // x11 = -27
        mem[2820] = 32'h06B52E23; // L1 weight data = -27
        mem[2821] = 32'h00100593; // x11 = 1
        mem[2822] = 32'h08B52023; // COMMIT L1 F6 C2 T4 = -27
        mem[2823] = 32'h00600593; // x11 = 6
        mem[2824] = 32'h06B52823; // L1 weight filter = 6
        mem[2825] = 32'h00200593; // x11 = 2
        mem[2826] = 32'h06B52A23; // L1 weight channel = 2
        mem[2827] = 32'h00500593; // x11 = 5
        mem[2828] = 32'h06B52C23; // L1 weight tap = 5
        mem[2829] = 32'h00500593; // x11 = 5
        mem[2830] = 32'h06B52E23; // L1 weight data = 5
        mem[2831] = 32'h00100593; // x11 = 1
        mem[2832] = 32'h08B52023; // COMMIT L1 F6 C2 T5 = 5
        mem[2833] = 32'h00600593; // x11 = 6
        mem[2834] = 32'h06B52823; // L1 weight filter = 6
        mem[2835] = 32'h00200593; // x11 = 2
        mem[2836] = 32'h06B52A23; // L1 weight channel = 2
        mem[2837] = 32'h00600593; // x11 = 6
        mem[2838] = 32'h06B52C23; // L1 weight tap = 6
        mem[2839] = 32'hFF100593; // x11 = -15
        mem[2840] = 32'h06B52E23; // L1 weight data = -15
        mem[2841] = 32'h00100593; // x11 = 1
        mem[2842] = 32'h08B52023; // COMMIT L1 F6 C2 T6 = -15
        mem[2843] = 32'h00600593; // x11 = 6
        mem[2844] = 32'h06B52823; // L1 weight filter = 6
        mem[2845] = 32'h00200593; // x11 = 2
        mem[2846] = 32'h06B52A23; // L1 weight channel = 2
        mem[2847] = 32'h00700593; // x11 = 7
        mem[2848] = 32'h06B52C23; // L1 weight tap = 7
        mem[2849] = 32'hFE900593; // x11 = -23
        mem[2850] = 32'h06B52E23; // L1 weight data = -23
        mem[2851] = 32'h00100593; // x11 = 1
        mem[2852] = 32'h08B52023; // COMMIT L1 F6 C2 T7 = -23
        mem[2853] = 32'h00600593; // x11 = 6
        mem[2854] = 32'h06B52823; // L1 weight filter = 6
        mem[2855] = 32'h00200593; // x11 = 2
        mem[2856] = 32'h06B52A23; // L1 weight channel = 2
        mem[2857] = 32'h00800593; // x11 = 8
        mem[2858] = 32'h06B52C23; // L1 weight tap = 8
        mem[2859] = 32'hFFC00593; // x11 = -4
        mem[2860] = 32'h06B52E23; // L1 weight data = -4
        mem[2861] = 32'h00100593; // x11 = 1
        mem[2862] = 32'h08B52023; // COMMIT L1 F6 C2 T8 = -4
        mem[2863] = 32'h00600593; // x11 = 6
        mem[2864] = 32'h06B52823; // L1 weight filter = 6
        mem[2865] = 32'h00300593; // x11 = 3
        mem[2866] = 32'h06B52A23; // L1 weight channel = 3
        mem[2867] = 32'h00000593; // x11 = 0
        mem[2868] = 32'h06B52C23; // L1 weight tap = 0
        mem[2869] = 32'h00700593; // x11 = 7
        mem[2870] = 32'h06B52E23; // L1 weight data = 7
        mem[2871] = 32'h00100593; // x11 = 1
        mem[2872] = 32'h08B52023; // COMMIT L1 F6 C3 T0 = 7
        mem[2873] = 32'h00600593; // x11 = 6
        mem[2874] = 32'h06B52823; // L1 weight filter = 6
        mem[2875] = 32'h00300593; // x11 = 3
        mem[2876] = 32'h06B52A23; // L1 weight channel = 3
        mem[2877] = 32'h00100593; // x11 = 1
        mem[2878] = 32'h06B52C23; // L1 weight tap = 1
        mem[2879] = 32'hFF800593; // x11 = -8
        mem[2880] = 32'h06B52E23; // L1 weight data = -8
        mem[2881] = 32'h00100593; // x11 = 1
        mem[2882] = 32'h08B52023; // COMMIT L1 F6 C3 T1 = -8
        mem[2883] = 32'h00600593; // x11 = 6
        mem[2884] = 32'h06B52823; // L1 weight filter = 6
        mem[2885] = 32'h00300593; // x11 = 3
        mem[2886] = 32'h06B52A23; // L1 weight channel = 3
        mem[2887] = 32'h00200593; // x11 = 2
        mem[2888] = 32'h06B52C23; // L1 weight tap = 2
        mem[2889] = 32'h01200593; // x11 = 18
        mem[2890] = 32'h06B52E23; // L1 weight data = 18
        mem[2891] = 32'h00100593; // x11 = 1
        mem[2892] = 32'h08B52023; // COMMIT L1 F6 C3 T2 = 18
        mem[2893] = 32'h00600593; // x11 = 6
        mem[2894] = 32'h06B52823; // L1 weight filter = 6
        mem[2895] = 32'h00300593; // x11 = 3
        mem[2896] = 32'h06B52A23; // L1 weight channel = 3
        mem[2897] = 32'h00300593; // x11 = 3
        mem[2898] = 32'h06B52C23; // L1 weight tap = 3
        mem[2899] = 32'h04700593; // x11 = 71
        mem[2900] = 32'h06B52E23; // L1 weight data = 71
        mem[2901] = 32'h00100593; // x11 = 1
        mem[2902] = 32'h08B52023; // COMMIT L1 F6 C3 T3 = 71
        mem[2903] = 32'h00600593; // x11 = 6
        mem[2904] = 32'h06B52823; // L1 weight filter = 6
        mem[2905] = 32'h00300593; // x11 = 3
        mem[2906] = 32'h06B52A23; // L1 weight channel = 3
        mem[2907] = 32'h00400593; // x11 = 4
        mem[2908] = 32'h06B52C23; // L1 weight tap = 4
        mem[2909] = 32'hFD400593; // x11 = -44
        mem[2910] = 32'h06B52E23; // L1 weight data = -44
        mem[2911] = 32'h00100593; // x11 = 1
        mem[2912] = 32'h08B52023; // COMMIT L1 F6 C3 T4 = -44
        mem[2913] = 32'h00600593; // x11 = 6
        mem[2914] = 32'h06B52823; // L1 weight filter = 6
        mem[2915] = 32'h00300593; // x11 = 3
        mem[2916] = 32'h06B52A23; // L1 weight channel = 3
        mem[2917] = 32'h00500593; // x11 = 5
        mem[2918] = 32'h06B52C23; // L1 weight tap = 5
        mem[2919] = 32'h04600593; // x11 = 70
        mem[2920] = 32'h06B52E23; // L1 weight data = 70
        mem[2921] = 32'h00100593; // x11 = 1
        mem[2922] = 32'h08B52023; // COMMIT L1 F6 C3 T5 = 70
        mem[2923] = 32'h00600593; // x11 = 6
        mem[2924] = 32'h06B52823; // L1 weight filter = 6
        mem[2925] = 32'h00300593; // x11 = 3
        mem[2926] = 32'h06B52A23; // L1 weight channel = 3
        mem[2927] = 32'h00600593; // x11 = 6
        mem[2928] = 32'h06B52C23; // L1 weight tap = 6
        mem[2929] = 32'hFF600593; // x11 = -10
        mem[2930] = 32'h06B52E23; // L1 weight data = -10
        mem[2931] = 32'h00100593; // x11 = 1
        mem[2932] = 32'h08B52023; // COMMIT L1 F6 C3 T6 = -10
        mem[2933] = 32'h00600593; // x11 = 6
        mem[2934] = 32'h06B52823; // L1 weight filter = 6
        mem[2935] = 32'h00300593; // x11 = 3
        mem[2936] = 32'h06B52A23; // L1 weight channel = 3
        mem[2937] = 32'h00700593; // x11 = 7
        mem[2938] = 32'h06B52C23; // L1 weight tap = 7
        mem[2939] = 32'hFF500593; // x11 = -11
        mem[2940] = 32'h06B52E23; // L1 weight data = -11
        mem[2941] = 32'h00100593; // x11 = 1
        mem[2942] = 32'h08B52023; // COMMIT L1 F6 C3 T7 = -11
        mem[2943] = 32'h00600593; // x11 = 6
        mem[2944] = 32'h06B52823; // L1 weight filter = 6
        mem[2945] = 32'h00300593; // x11 = 3
        mem[2946] = 32'h06B52A23; // L1 weight channel = 3
        mem[2947] = 32'h00800593; // x11 = 8
        mem[2948] = 32'h06B52C23; // L1 weight tap = 8
        mem[2949] = 32'h01E00593; // x11 = 30
        mem[2950] = 32'h06B52E23; // L1 weight data = 30
        mem[2951] = 32'h00100593; // x11 = 1
        mem[2952] = 32'h08B52023; // COMMIT L1 F6 C3 T8 = 30
        mem[2953] = 32'h00700593; // x11 = 7
        mem[2954] = 32'h06B52823; // L1 weight filter = 7
        mem[2955] = 32'h00000593; // x11 = 0
        mem[2956] = 32'h06B52A23; // L1 weight channel = 0
        mem[2957] = 32'h00000593; // x11 = 0
        mem[2958] = 32'h06B52C23; // L1 weight tap = 0
        mem[2959] = 32'hFEF00593; // x11 = -17
        mem[2960] = 32'h06B52E23; // L1 weight data = -17
        mem[2961] = 32'h00100593; // x11 = 1
        mem[2962] = 32'h08B52023; // COMMIT L1 F7 C0 T0 = -17
        mem[2963] = 32'h00700593; // x11 = 7
        mem[2964] = 32'h06B52823; // L1 weight filter = 7
        mem[2965] = 32'h00000593; // x11 = 0
        mem[2966] = 32'h06B52A23; // L1 weight channel = 0
        mem[2967] = 32'h00100593; // x11 = 1
        mem[2968] = 32'h06B52C23; // L1 weight tap = 1
        mem[2969] = 32'h00C00593; // x11 = 12
        mem[2970] = 32'h06B52E23; // L1 weight data = 12
        mem[2971] = 32'h00100593; // x11 = 1
        mem[2972] = 32'h08B52023; // COMMIT L1 F7 C0 T1 = 12
        mem[2973] = 32'h00700593; // x11 = 7
        mem[2974] = 32'h06B52823; // L1 weight filter = 7
        mem[2975] = 32'h00000593; // x11 = 0
        mem[2976] = 32'h06B52A23; // L1 weight channel = 0
        mem[2977] = 32'h00200593; // x11 = 2
        mem[2978] = 32'h06B52C23; // L1 weight tap = 2
        mem[2979] = 32'hFE500593; // x11 = -27
        mem[2980] = 32'h06B52E23; // L1 weight data = -27
        mem[2981] = 32'h00100593; // x11 = 1
        mem[2982] = 32'h08B52023; // COMMIT L1 F7 C0 T2 = -27
        mem[2983] = 32'h00700593; // x11 = 7
        mem[2984] = 32'h06B52823; // L1 weight filter = 7
        mem[2985] = 32'h00000593; // x11 = 0
        mem[2986] = 32'h06B52A23; // L1 weight channel = 0
        mem[2987] = 32'h00300593; // x11 = 3
        mem[2988] = 32'h06B52C23; // L1 weight tap = 3
        mem[2989] = 32'hFF600593; // x11 = -10
        mem[2990] = 32'h06B52E23; // L1 weight data = -10
        mem[2991] = 32'h00100593; // x11 = 1
        mem[2992] = 32'h08B52023; // COMMIT L1 F7 C0 T3 = -10
        mem[2993] = 32'h00700593; // x11 = 7
        mem[2994] = 32'h06B52823; // L1 weight filter = 7
        mem[2995] = 32'h00000593; // x11 = 0
        mem[2996] = 32'h06B52A23; // L1 weight channel = 0
        mem[2997] = 32'h00400593; // x11 = 4
        mem[2998] = 32'h06B52C23; // L1 weight tap = 4
        mem[2999] = 32'h04B00593; // x11 = 75
        mem[3000] = 32'h06B52E23; // L1 weight data = 75
        mem[3001] = 32'h00100593; // x11 = 1
        mem[3002] = 32'h08B52023; // COMMIT L1 F7 C0 T4 = 75
        mem[3003] = 32'h00700593; // x11 = 7
        mem[3004] = 32'h06B52823; // L1 weight filter = 7
        mem[3005] = 32'h00000593; // x11 = 0
        mem[3006] = 32'h06B52A23; // L1 weight channel = 0
        mem[3007] = 32'h00500593; // x11 = 5
        mem[3008] = 32'h06B52C23; // L1 weight tap = 5
        mem[3009] = 32'h01E00593; // x11 = 30
        mem[3010] = 32'h06B52E23; // L1 weight data = 30
        mem[3011] = 32'h00100593; // x11 = 1
        mem[3012] = 32'h08B52023; // COMMIT L1 F7 C0 T5 = 30
        mem[3013] = 32'h00700593; // x11 = 7
        mem[3014] = 32'h06B52823; // L1 weight filter = 7
        mem[3015] = 32'h00000593; // x11 = 0
        mem[3016] = 32'h06B52A23; // L1 weight channel = 0
        mem[3017] = 32'h00600593; // x11 = 6
        mem[3018] = 32'h06B52C23; // L1 weight tap = 6
        mem[3019] = 32'hFEC00593; // x11 = -20
        mem[3020] = 32'h06B52E23; // L1 weight data = -20
        mem[3021] = 32'h00100593; // x11 = 1
        mem[3022] = 32'h08B52023; // COMMIT L1 F7 C0 T6 = -20
        mem[3023] = 32'h00700593; // x11 = 7
        mem[3024] = 32'h06B52823; // L1 weight filter = 7
        mem[3025] = 32'h00000593; // x11 = 0
        mem[3026] = 32'h06B52A23; // L1 weight channel = 0
        mem[3027] = 32'h00700593; // x11 = 7
        mem[3028] = 32'h06B52C23; // L1 weight tap = 7
        mem[3029] = 32'h00100593; // x11 = 1
        mem[3030] = 32'h06B52E23; // L1 weight data = 1
        mem[3031] = 32'h00100593; // x11 = 1
        mem[3032] = 32'h08B52023; // COMMIT L1 F7 C0 T7 = 1
        mem[3033] = 32'h00700593; // x11 = 7
        mem[3034] = 32'h06B52823; // L1 weight filter = 7
        mem[3035] = 32'h00000593; // x11 = 0
        mem[3036] = 32'h06B52A23; // L1 weight channel = 0
        mem[3037] = 32'h00800593; // x11 = 8
        mem[3038] = 32'h06B52C23; // L1 weight tap = 8
        mem[3039] = 32'hFF800593; // x11 = -8
        mem[3040] = 32'h06B52E23; // L1 weight data = -8
        mem[3041] = 32'h00100593; // x11 = 1
        mem[3042] = 32'h08B52023; // COMMIT L1 F7 C0 T8 = -8
        mem[3043] = 32'h00700593; // x11 = 7
        mem[3044] = 32'h06B52823; // L1 weight filter = 7
        mem[3045] = 32'h00100593; // x11 = 1
        mem[3046] = 32'h06B52A23; // L1 weight channel = 1
        mem[3047] = 32'h00000593; // x11 = 0
        mem[3048] = 32'h06B52C23; // L1 weight tap = 0
        mem[3049] = 32'h00600593; // x11 = 6
        mem[3050] = 32'h06B52E23; // L1 weight data = 6
        mem[3051] = 32'h00100593; // x11 = 1
        mem[3052] = 32'h08B52023; // COMMIT L1 F7 C1 T0 = 6
        mem[3053] = 32'h00700593; // x11 = 7
        mem[3054] = 32'h06B52823; // L1 weight filter = 7
        mem[3055] = 32'h00100593; // x11 = 1
        mem[3056] = 32'h06B52A23; // L1 weight channel = 1
        mem[3057] = 32'h00100593; // x11 = 1
        mem[3058] = 32'h06B52C23; // L1 weight tap = 1
        mem[3059] = 32'h01100593; // x11 = 17
        mem[3060] = 32'h06B52E23; // L1 weight data = 17
        mem[3061] = 32'h00100593; // x11 = 1
        mem[3062] = 32'h08B52023; // COMMIT L1 F7 C1 T1 = 17
        mem[3063] = 32'h00700593; // x11 = 7
        mem[3064] = 32'h06B52823; // L1 weight filter = 7
        mem[3065] = 32'h00100593; // x11 = 1
        mem[3066] = 32'h06B52A23; // L1 weight channel = 1
        mem[3067] = 32'h00200593; // x11 = 2
        mem[3068] = 32'h06B52C23; // L1 weight tap = 2
        mem[3069] = 32'h00D00593; // x11 = 13
        mem[3070] = 32'h06B52E23; // L1 weight data = 13
        mem[3071] = 32'h00100593; // x11 = 1
        mem[3072] = 32'h08B52023; // COMMIT L1 F7 C1 T2 = 13
        mem[3073] = 32'h00700593; // x11 = 7
        mem[3074] = 32'h06B52823; // L1 weight filter = 7
        mem[3075] = 32'h00100593; // x11 = 1
        mem[3076] = 32'h06B52A23; // L1 weight channel = 1
        mem[3077] = 32'h00300593; // x11 = 3
        mem[3078] = 32'h06B52C23; // L1 weight tap = 3
        mem[3079] = 32'hFEF00593; // x11 = -17
        mem[3080] = 32'h06B52E23; // L1 weight data = -17
        mem[3081] = 32'h00100593; // x11 = 1
        mem[3082] = 32'h08B52023; // COMMIT L1 F7 C1 T3 = -17
        mem[3083] = 32'h00700593; // x11 = 7
        mem[3084] = 32'h06B52823; // L1 weight filter = 7
        mem[3085] = 32'h00100593; // x11 = 1
        mem[3086] = 32'h06B52A23; // L1 weight channel = 1
        mem[3087] = 32'h00400593; // x11 = 4
        mem[3088] = 32'h06B52C23; // L1 weight tap = 4
        mem[3089] = 32'hFF400593; // x11 = -12
        mem[3090] = 32'h06B52E23; // L1 weight data = -12
        mem[3091] = 32'h00100593; // x11 = 1
        mem[3092] = 32'h08B52023; // COMMIT L1 F7 C1 T4 = -12
        mem[3093] = 32'h00700593; // x11 = 7
        mem[3094] = 32'h06B52823; // L1 weight filter = 7
        mem[3095] = 32'h00100593; // x11 = 1
        mem[3096] = 32'h06B52A23; // L1 weight channel = 1
        mem[3097] = 32'h00500593; // x11 = 5
        mem[3098] = 32'h06B52C23; // L1 weight tap = 5
        mem[3099] = 32'h00F00593; // x11 = 15
        mem[3100] = 32'h06B52E23; // L1 weight data = 15
        mem[3101] = 32'h00100593; // x11 = 1
        mem[3102] = 32'h08B52023; // COMMIT L1 F7 C1 T5 = 15
        mem[3103] = 32'h00700593; // x11 = 7
        mem[3104] = 32'h06B52823; // L1 weight filter = 7
        mem[3105] = 32'h00100593; // x11 = 1
        mem[3106] = 32'h06B52A23; // L1 weight channel = 1
        mem[3107] = 32'h00600593; // x11 = 6
        mem[3108] = 32'h06B52C23; // L1 weight tap = 6
        mem[3109] = 32'h00C00593; // x11 = 12
        mem[3110] = 32'h06B52E23; // L1 weight data = 12
        mem[3111] = 32'h00100593; // x11 = 1
        mem[3112] = 32'h08B52023; // COMMIT L1 F7 C1 T6 = 12
        mem[3113] = 32'h00700593; // x11 = 7
        mem[3114] = 32'h06B52823; // L1 weight filter = 7
        mem[3115] = 32'h00100593; // x11 = 1
        mem[3116] = 32'h06B52A23; // L1 weight channel = 1
        mem[3117] = 32'h00700593; // x11 = 7
        mem[3118] = 32'h06B52C23; // L1 weight tap = 7
        mem[3119] = 32'hFFF00593; // x11 = -1
        mem[3120] = 32'h06B52E23; // L1 weight data = -1
        mem[3121] = 32'h00100593; // x11 = 1
        mem[3122] = 32'h08B52023; // COMMIT L1 F7 C1 T7 = -1
        mem[3123] = 32'h00700593; // x11 = 7
        mem[3124] = 32'h06B52823; // L1 weight filter = 7
        mem[3125] = 32'h00100593; // x11 = 1
        mem[3126] = 32'h06B52A23; // L1 weight channel = 1
        mem[3127] = 32'h00800593; // x11 = 8
        mem[3128] = 32'h06B52C23; // L1 weight tap = 8
        mem[3129] = 32'h00200593; // x11 = 2
        mem[3130] = 32'h06B52E23; // L1 weight data = 2
        mem[3131] = 32'h00100593; // x11 = 1
        mem[3132] = 32'h08B52023; // COMMIT L1 F7 C1 T8 = 2
        mem[3133] = 32'h00700593; // x11 = 7
        mem[3134] = 32'h06B52823; // L1 weight filter = 7
        mem[3135] = 32'h00200593; // x11 = 2
        mem[3136] = 32'h06B52A23; // L1 weight channel = 2
        mem[3137] = 32'h00000593; // x11 = 0
        mem[3138] = 32'h06B52C23; // L1 weight tap = 0
        mem[3139] = 32'h00C00593; // x11 = 12
        mem[3140] = 32'h06B52E23; // L1 weight data = 12
        mem[3141] = 32'h00100593; // x11 = 1
        mem[3142] = 32'h08B52023; // COMMIT L1 F7 C2 T0 = 12
        mem[3143] = 32'h00700593; // x11 = 7
        mem[3144] = 32'h06B52823; // L1 weight filter = 7
        mem[3145] = 32'h00200593; // x11 = 2
        mem[3146] = 32'h06B52A23; // L1 weight channel = 2
        mem[3147] = 32'h00100593; // x11 = 1
        mem[3148] = 32'h06B52C23; // L1 weight tap = 1
        mem[3149] = 32'hFF000593; // x11 = -16
        mem[3150] = 32'h06B52E23; // L1 weight data = -16
        mem[3151] = 32'h00100593; // x11 = 1
        mem[3152] = 32'h08B52023; // COMMIT L1 F7 C2 T1 = -16
        mem[3153] = 32'h00700593; // x11 = 7
        mem[3154] = 32'h06B52823; // L1 weight filter = 7
        mem[3155] = 32'h00200593; // x11 = 2
        mem[3156] = 32'h06B52A23; // L1 weight channel = 2
        mem[3157] = 32'h00200593; // x11 = 2
        mem[3158] = 32'h06B52C23; // L1 weight tap = 2
        mem[3159] = 32'hFFA00593; // x11 = -6
        mem[3160] = 32'h06B52E23; // L1 weight data = -6
        mem[3161] = 32'h00100593; // x11 = 1
        mem[3162] = 32'h08B52023; // COMMIT L1 F7 C2 T2 = -6
        mem[3163] = 32'h00700593; // x11 = 7
        mem[3164] = 32'h06B52823; // L1 weight filter = 7
        mem[3165] = 32'h00200593; // x11 = 2
        mem[3166] = 32'h06B52A23; // L1 weight channel = 2
        mem[3167] = 32'h00300593; // x11 = 3
        mem[3168] = 32'h06B52C23; // L1 weight tap = 3
        mem[3169] = 32'hFDA00593; // x11 = -38
        mem[3170] = 32'h06B52E23; // L1 weight data = -38
        mem[3171] = 32'h00100593; // x11 = 1
        mem[3172] = 32'h08B52023; // COMMIT L1 F7 C2 T3 = -38
        mem[3173] = 32'h00700593; // x11 = 7
        mem[3174] = 32'h06B52823; // L1 weight filter = 7
        mem[3175] = 32'h00200593; // x11 = 2
        mem[3176] = 32'h06B52A23; // L1 weight channel = 2
        mem[3177] = 32'h00400593; // x11 = 4
        mem[3178] = 32'h06B52C23; // L1 weight tap = 4
        mem[3179] = 32'hFEB00593; // x11 = -21
        mem[3180] = 32'h06B52E23; // L1 weight data = -21
        mem[3181] = 32'h00100593; // x11 = 1
        mem[3182] = 32'h08B52023; // COMMIT L1 F7 C2 T4 = -21
        mem[3183] = 32'h00700593; // x11 = 7
        mem[3184] = 32'h06B52823; // L1 weight filter = 7
        mem[3185] = 32'h00200593; // x11 = 2
        mem[3186] = 32'h06B52A23; // L1 weight channel = 2
        mem[3187] = 32'h00500593; // x11 = 5
        mem[3188] = 32'h06B52C23; // L1 weight tap = 5
        mem[3189] = 32'hFFF00593; // x11 = -1
        mem[3190] = 32'h06B52E23; // L1 weight data = -1
        mem[3191] = 32'h00100593; // x11 = 1
        mem[3192] = 32'h08B52023; // COMMIT L1 F7 C2 T5 = -1
        mem[3193] = 32'h00700593; // x11 = 7
        mem[3194] = 32'h06B52823; // L1 weight filter = 7
        mem[3195] = 32'h00200593; // x11 = 2
        mem[3196] = 32'h06B52A23; // L1 weight channel = 2
        mem[3197] = 32'h00600593; // x11 = 6
        mem[3198] = 32'h06B52C23; // L1 weight tap = 6
        mem[3199] = 32'hFEC00593; // x11 = -20
        mem[3200] = 32'h06B52E23; // L1 weight data = -20
        mem[3201] = 32'h00100593; // x11 = 1
        mem[3202] = 32'h08B52023; // COMMIT L1 F7 C2 T6 = -20
        mem[3203] = 32'h00700593; // x11 = 7
        mem[3204] = 32'h06B52823; // L1 weight filter = 7
        mem[3205] = 32'h00200593; // x11 = 2
        mem[3206] = 32'h06B52A23; // L1 weight channel = 2
        mem[3207] = 32'h00700593; // x11 = 7
        mem[3208] = 32'h06B52C23; // L1 weight tap = 7
        mem[3209] = 32'hFF700593; // x11 = -9
        mem[3210] = 32'h06B52E23; // L1 weight data = -9
        mem[3211] = 32'h00100593; // x11 = 1
        mem[3212] = 32'h08B52023; // COMMIT L1 F7 C2 T7 = -9
        mem[3213] = 32'h00700593; // x11 = 7
        mem[3214] = 32'h06B52823; // L1 weight filter = 7
        mem[3215] = 32'h00200593; // x11 = 2
        mem[3216] = 32'h06B52A23; // L1 weight channel = 2
        mem[3217] = 32'h00800593; // x11 = 8
        mem[3218] = 32'h06B52C23; // L1 weight tap = 8
        mem[3219] = 32'h00B00593; // x11 = 11
        mem[3220] = 32'h06B52E23; // L1 weight data = 11
        mem[3221] = 32'h00100593; // x11 = 1
        mem[3222] = 32'h08B52023; // COMMIT L1 F7 C2 T8 = 11
        mem[3223] = 32'h00700593; // x11 = 7
        mem[3224] = 32'h06B52823; // L1 weight filter = 7
        mem[3225] = 32'h00300593; // x11 = 3
        mem[3226] = 32'h06B52A23; // L1 weight channel = 3
        mem[3227] = 32'h00000593; // x11 = 0
        mem[3228] = 32'h06B52C23; // L1 weight tap = 0
        mem[3229] = 32'h00200593; // x11 = 2
        mem[3230] = 32'h06B52E23; // L1 weight data = 2
        mem[3231] = 32'h00100593; // x11 = 1
        mem[3232] = 32'h08B52023; // COMMIT L1 F7 C3 T0 = 2
        mem[3233] = 32'h00700593; // x11 = 7
        mem[3234] = 32'h06B52823; // L1 weight filter = 7
        mem[3235] = 32'h00300593; // x11 = 3
        mem[3236] = 32'h06B52A23; // L1 weight channel = 3
        mem[3237] = 32'h00100593; // x11 = 1
        mem[3238] = 32'h06B52C23; // L1 weight tap = 1
        mem[3239] = 32'h00100593; // x11 = 1
        mem[3240] = 32'h06B52E23; // L1 weight data = 1
        mem[3241] = 32'h00100593; // x11 = 1
        mem[3242] = 32'h08B52023; // COMMIT L1 F7 C3 T1 = 1
        mem[3243] = 32'h00700593; // x11 = 7
        mem[3244] = 32'h06B52823; // L1 weight filter = 7
        mem[3245] = 32'h00300593; // x11 = 3
        mem[3246] = 32'h06B52A23; // L1 weight channel = 3
        mem[3247] = 32'h00200593; // x11 = 2
        mem[3248] = 32'h06B52C23; // L1 weight tap = 2
        mem[3249] = 32'hFF600593; // x11 = -10
        mem[3250] = 32'h06B52E23; // L1 weight data = -10
        mem[3251] = 32'h00100593; // x11 = 1
        mem[3252] = 32'h08B52023; // COMMIT L1 F7 C3 T2 = -10
        mem[3253] = 32'h00700593; // x11 = 7
        mem[3254] = 32'h06B52823; // L1 weight filter = 7
        mem[3255] = 32'h00300593; // x11 = 3
        mem[3256] = 32'h06B52A23; // L1 weight channel = 3
        mem[3257] = 32'h00300593; // x11 = 3
        mem[3258] = 32'h06B52C23; // L1 weight tap = 3
        mem[3259] = 32'h01E00593; // x11 = 30
        mem[3260] = 32'h06B52E23; // L1 weight data = 30
        mem[3261] = 32'h00100593; // x11 = 1
        mem[3262] = 32'h08B52023; // COMMIT L1 F7 C3 T3 = 30
        mem[3263] = 32'h00700593; // x11 = 7
        mem[3264] = 32'h06B52823; // L1 weight filter = 7
        mem[3265] = 32'h00300593; // x11 = 3
        mem[3266] = 32'h06B52A23; // L1 weight channel = 3
        mem[3267] = 32'h00400593; // x11 = 4
        mem[3268] = 32'h06B52C23; // L1 weight tap = 4
        mem[3269] = 32'hFF200593; // x11 = -14
        mem[3270] = 32'h06B52E23; // L1 weight data = -14
        mem[3271] = 32'h00100593; // x11 = 1
        mem[3272] = 32'h08B52023; // COMMIT L1 F7 C3 T4 = -14
        mem[3273] = 32'h00700593; // x11 = 7
        mem[3274] = 32'h06B52823; // L1 weight filter = 7
        mem[3275] = 32'h00300593; // x11 = 3
        mem[3276] = 32'h06B52A23; // L1 weight channel = 3
        mem[3277] = 32'h00500593; // x11 = 5
        mem[3278] = 32'h06B52C23; // L1 weight tap = 5
        mem[3279] = 32'h00900593; // x11 = 9
        mem[3280] = 32'h06B52E23; // L1 weight data = 9
        mem[3281] = 32'h00100593; // x11 = 1
        mem[3282] = 32'h08B52023; // COMMIT L1 F7 C3 T5 = 9
        mem[3283] = 32'h00700593; // x11 = 7
        mem[3284] = 32'h06B52823; // L1 weight filter = 7
        mem[3285] = 32'h00300593; // x11 = 3
        mem[3286] = 32'h06B52A23; // L1 weight channel = 3
        mem[3287] = 32'h00600593; // x11 = 6
        mem[3288] = 32'h06B52C23; // L1 weight tap = 6
        mem[3289] = 32'h00900593; // x11 = 9
        mem[3290] = 32'h06B52E23; // L1 weight data = 9
        mem[3291] = 32'h00100593; // x11 = 1
        mem[3292] = 32'h08B52023; // COMMIT L1 F7 C3 T6 = 9
        mem[3293] = 32'h00700593; // x11 = 7
        mem[3294] = 32'h06B52823; // L1 weight filter = 7
        mem[3295] = 32'h00300593; // x11 = 3
        mem[3296] = 32'h06B52A23; // L1 weight channel = 3
        mem[3297] = 32'h00700593; // x11 = 7
        mem[3298] = 32'h06B52C23; // L1 weight tap = 7
        mem[3299] = 32'hFDF00593; // x11 = -33
        mem[3300] = 32'h06B52E23; // L1 weight data = -33
        mem[3301] = 32'h00100593; // x11 = 1
        mem[3302] = 32'h08B52023; // COMMIT L1 F7 C3 T7 = -33
        mem[3303] = 32'h00700593; // x11 = 7
        mem[3304] = 32'h06B52823; // L1 weight filter = 7
        mem[3305] = 32'h00300593; // x11 = 3
        mem[3306] = 32'h06B52A23; // L1 weight channel = 3
        mem[3307] = 32'h00800593; // x11 = 8
        mem[3308] = 32'h06B52C23; // L1 weight tap = 8
        mem[3309] = 32'h02E00593; // x11 = 46
        mem[3310] = 32'h06B52E23; // L1 weight data = 46
        mem[3311] = 32'h00100593; // x11 = 1
        mem[3312] = 32'h08B52023; // COMMIT L1 F7 C3 T8 = 46
        mem[3313] = 32'h00000593; // x11 = 0
        mem[3314] = 32'h08B52223; // L1 bias filter = 0
        mem[3315] = 32'h15900593; // x11 = 345
        mem[3316] = 32'h08B52423; // L1 bias data = 345
        mem[3317] = 32'h00100593; // x11 = 1
        mem[3318] = 32'h08B52623; // COMMIT L1 bias F0 = 345
        mem[3319] = 32'h00100593; // x11 = 1
        mem[3320] = 32'h08B52223; // L1 bias filter = 1
        mem[3321] = 32'h24B00593; // x11 = 587
        mem[3322] = 32'h08B52423; // L1 bias data = 587
        mem[3323] = 32'h00100593; // x11 = 1
        mem[3324] = 32'h08B52623; // COMMIT L1 bias F1 = 587
        mem[3325] = 32'h00200593; // x11 = 2
        mem[3326] = 32'h08B52223; // L1 bias filter = 2
        mem[3327] = 32'h25500593; // x11 = 597
        mem[3328] = 32'h08B52423; // L1 bias data = 597
        mem[3329] = 32'h00100593; // x11 = 1
        mem[3330] = 32'h08B52623; // COMMIT L1 bias F2 = 597
        mem[3331] = 32'h00300593; // x11 = 3
        mem[3332] = 32'h08B52223; // L1 bias filter = 3
        mem[3333] = 32'h27100593; // x11 = 625
        mem[3334] = 32'h08B52423; // L1 bias data = 625
        mem[3335] = 32'h00100593; // x11 = 1
        mem[3336] = 32'h08B52623; // COMMIT L1 bias F3 = 625
        mem[3337] = 32'h00400593; // x11 = 4
        mem[3338] = 32'h08B52223; // L1 bias filter = 4
        mem[3339] = 32'hE4F00593; // x11 = -433
        mem[3340] = 32'h08B52423; // L1 bias data = -433
        mem[3341] = 32'h00100593; // x11 = 1
        mem[3342] = 32'h08B52623; // COMMIT L1 bias F4 = -433
        mem[3343] = 32'h00500593; // x11 = 5
        mem[3344] = 32'h08B52223; // L1 bias filter = 5
        mem[3345] = 32'hF5C00593; // x11 = -164
        mem[3346] = 32'h08B52423; // L1 bias data = -164
        mem[3347] = 32'h00100593; // x11 = 1
        mem[3348] = 32'h08B52623; // COMMIT L1 bias F5 = -164
        mem[3349] = 32'h00600593; // x11 = 6
        mem[3350] = 32'h08B52223; // L1 bias filter = 6
        mem[3351] = 32'hE6D00593; // x11 = -403
        mem[3352] = 32'h08B52423; // L1 bias data = -403
        mem[3353] = 32'h00100593; // x11 = 1
        mem[3354] = 32'h08B52623; // COMMIT L1 bias F6 = -403
        mem[3355] = 32'h00700593; // x11 = 7
        mem[3356] = 32'h08B52223; // L1 bias filter = 7
        mem[3357] = 32'hB7E00593; // x11 = -1154
        mem[3358] = 32'h08B52423; // L1 bias data = -1154
        mem[3359] = 32'h00100593; // x11 = 1
        mem[3360] = 32'h08B52623; // COMMIT L1 bias F7 = -1154
        mem[3361] = 32'h00000593; // x11 = 0
        mem[3362] = 32'h08B52823; // L1 quant filter = 0
        mem[3363] = 32'h00600593; // x11 = 6
        mem[3364] = 32'h08B52A23; // L1 quant shift = 6
        mem[3365] = 32'h00100593; // x11 = 1
        mem[3366] = 32'h08B52C23; // COMMIT L1 quant F0 shift=6
        mem[3367] = 32'h00100593; // x11 = 1
        mem[3368] = 32'h08B52823; // L1 quant filter = 1
        mem[3369] = 32'h00600593; // x11 = 6
        mem[3370] = 32'h08B52A23; // L1 quant shift = 6
        mem[3371] = 32'h00100593; // x11 = 1
        mem[3372] = 32'h08B52C23; // COMMIT L1 quant F1 shift=6
        mem[3373] = 32'h00200593; // x11 = 2
        mem[3374] = 32'h08B52823; // L1 quant filter = 2
        mem[3375] = 32'h00600593; // x11 = 6
        mem[3376] = 32'h08B52A23; // L1 quant shift = 6
        mem[3377] = 32'h00100593; // x11 = 1
        mem[3378] = 32'h08B52C23; // COMMIT L1 quant F2 shift=6
        mem[3379] = 32'h00300593; // x11 = 3
        mem[3380] = 32'h08B52823; // L1 quant filter = 3
        mem[3381] = 32'h00600593; // x11 = 6
        mem[3382] = 32'h08B52A23; // L1 quant shift = 6
        mem[3383] = 32'h00100593; // x11 = 1
        mem[3384] = 32'h08B52C23; // COMMIT L1 quant F3 shift=6
        mem[3385] = 32'h00400593; // x11 = 4
        mem[3386] = 32'h08B52823; // L1 quant filter = 4
        mem[3387] = 32'h00600593; // x11 = 6
        mem[3388] = 32'h08B52A23; // L1 quant shift = 6
        mem[3389] = 32'h00100593; // x11 = 1
        mem[3390] = 32'h08B52C23; // COMMIT L1 quant F4 shift=6
        mem[3391] = 32'h00500593; // x11 = 5
        mem[3392] = 32'h08B52823; // L1 quant filter = 5
        mem[3393] = 32'h00600593; // x11 = 6
        mem[3394] = 32'h08B52A23; // L1 quant shift = 6
        mem[3395] = 32'h00100593; // x11 = 1
        mem[3396] = 32'h08B52C23; // COMMIT L1 quant F5 shift=6
        mem[3397] = 32'h00600593; // x11 = 6
        mem[3398] = 32'h08B52823; // L1 quant filter = 6
        mem[3399] = 32'h00600593; // x11 = 6
        mem[3400] = 32'h08B52A23; // L1 quant shift = 6
        mem[3401] = 32'h00100593; // x11 = 1
        mem[3402] = 32'h08B52C23; // COMMIT L1 quant F6 shift=6
        mem[3403] = 32'h00700593; // x11 = 7
        mem[3404] = 32'h08B52823; // L1 quant filter = 7
        mem[3405] = 32'h00600593; // x11 = 6
        mem[3406] = 32'h08B52A23; // L1 quant shift = 6
        mem[3407] = 32'h00100593; // x11 = 1
        mem[3408] = 32'h08B52C23; // COMMIT L1 quant F7 shift=6
        mem[3409] = 32'h00100593; // x11 = 1
        mem[3410] = 32'h06B52023; // START TRAINED CNN
        mem[3411] = 32'h00200693; // x13 = DONE status
        mem[3412] = 32'h06452583; // Read NET_STATUS
        mem[3413] = 32'hFED59EE3; // Poll until NET_STATUS == 2
        mem[3414] = 32'h0000006F; // HALT

    end

    always_comb begin
        instruction = mem[address[13:2]];
    end

endmodule
