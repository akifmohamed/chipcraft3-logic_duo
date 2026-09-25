/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : W-2024.09-SP5-3
// Date      : Fri Sep 25 22:10:10 2026
/////////////////////////////////////////////////////////////


module water_sched ( clk, rst_n, zone_req, zone_prio, zone_demand, 
        supply_avail, supply_valid, valve_open, grant_ack, cycles_done, 
        zone_cycles, insufficient, busy, status );
  input [3:0] zone_req;
  input [7:0] zone_prio;
  input [31:0] zone_demand;
  input [7:0] supply_avail;
  output [3:0] valve_open;
  output [3:0] grant_ack;
  output [31:0] cycles_done;
  output [63:0] zone_cycles;
  output [2:0] status;
  input clk, rst_n, supply_valid;
  output insufficient, busy;
  wire   unserved_exists, n138, n139, n140, n141, n142, n143, n144, n145, n146,
         n147, n148, n149, n150, n151, n152, n153, n154, n155, n156, n157,
         n158, n159, n160, n161, n162, n163, n164, n165, n166, n167, n168,
         n169, n170, n171, n172, n173, n174, n175, n176, n177, n178, n179,
         n180, n181, n182, n183, n184, n185, n186, n187, n188, n189, n190,
         n191, n192, n193, n194, n195, n196, n197, n198, n199, n200, n201,
         n202, n203, n204, n205, n206, n207, n208, n209, n210, n211, n212,
         n213, n214, n215, n216, n217, n218, n219, n220, n221, n222, n223,
         n224, n225, n226, n227, n228, n229, n230, n231, n232, n233, n234,
         n235, n236, n237, n238, n239, n240, n241, n242, n243, n244, n245,
         n246, n247, n248, n249, n250, n251, n252, n253, n254, n255, n256,
         n257, n259, n261, n262, n263, n264, n265, n266, n267, n268, n269,
         n270, n271, n272, n273, n274, n275, n276, n277, n278, n279, n280,
         n281, n282, n283, n284, n285, n286, n287, n288, n289, n290, n291,
         n292, n293, n294, n295, n296, n297, n298, n299, n300, n301, n302,
         n303, n304, n305, n306, n307, n308, n309, n310, n311, n312, n313,
         n314, n315, n316, n317, n318, n319, n320, n321, n322, n323, n324,
         n325, n326, n327, n328, n329, n330, n331, n332, n333, n334, n335,
         n336, n337, n338, n339, n340, n341, n342, n343, n344, n345, n346,
         n347, n348, n349, n350, n351, n352, n353, n354, n355, n356, n357,
         n358, n359, n360, n361, n362, n363, n364, n365, n366, n367, n368,
         n369, n370, n371, n372, n373, n374, n375, n376, n377, n378, n379,
         n380, n381, n382, n383, n384, n385, n386, n387, n388, n389, n390,
         n391, n392, n393, n394, n395, n396, n397, n398, n399, n400, n401,
         n402, n403, n404, n405, n406, n407, n408, n409, n410, n411, n412,
         n413, n414, n415, n416, n417, n418, n419, n420, n421, n422, n423,
         n424, n425, n426, n427, n428, n429, n430, n431, n432, n433, n434,
         n435, n436, n437, n438, n439, n440, n441, n442, n443, n444, n445,
         n446, n447, n448, n449, n450, n451, n452, n453, n454, n455, n456,
         n457, n458, n459, n460, n461, n462, n463, n464, n465, n466, n467,
         n468, n469, n470, n471, n472, n473, n474, n475, n476, n477, n478,
         n479, n480, n481, n482, n483, n484, n485, n486, n487, n488, n489,
         n490, n491, n492, n493, n494, n495, n496, n497, n498, n499, n500,
         n501, n502, n503, n504, n505, n506, n507, n508, n509, n510, n511,
         n512, n513, n514, n515, n516, n517, n518, n519, n520, n521, n522,
         n523, n524, n525, n526, n527, n528, n529, n530, n531, n532, n533,
         n534, n535, n536, n537, n538, n539, n540, n541, n542, n543, n544,
         n545, n546, n547, n548, n549, n550, n551, n552, n553, n554, n555,
         n556, n557, n558, n559, n560, n561, n562, n563, n564, n565, n566,
         n567, n568, n569, n570, n572, n573;
  wire   [15:0] timer;
  wire   [3:0] win_r;
  assign status[2] = 1'b0;

  DFFARX1_RVT \state_reg[0]  ( .D(n207), .CLK(clk), .RSTB(rst_n), .Q(status[0]), .QN(n563) );
  DFFARX1_RVT \state_reg[1]  ( .D(n206), .CLK(clk), .RSTB(rst_n), .Q(status[1]) );
  DFFARX1_RVT \win_r_reg[0]  ( .D(n211), .CLK(clk), .RSTB(rst_n), .Q(win_r[0])
         );
  DFFARX1_RVT \zone_cycles_reg[15]  ( .D(n205), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[15]) );
  DFFARX1_RVT \zone_cycles_reg[0]  ( .D(n204), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[0]) );
  DFFARX1_RVT \zone_cycles_reg[1]  ( .D(n203), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[1]) );
  DFFARX1_RVT \zone_cycles_reg[2]  ( .D(n202), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[2]) );
  DFFARX1_RVT \zone_cycles_reg[3]  ( .D(n201), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[3]) );
  DFFARX1_RVT \zone_cycles_reg[4]  ( .D(n200), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[4]) );
  DFFARX1_RVT \zone_cycles_reg[5]  ( .D(n199), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[5]) );
  DFFARX1_RVT \zone_cycles_reg[6]  ( .D(n198), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[6]) );
  DFFARX1_RVT \zone_cycles_reg[7]  ( .D(n197), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[7]) );
  DFFARX1_RVT \zone_cycles_reg[8]  ( .D(n196), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[8]) );
  DFFARX1_RVT \zone_cycles_reg[9]  ( .D(n195), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[9]) );
  DFFARX1_RVT \zone_cycles_reg[10]  ( .D(n194), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[10]) );
  DFFARX1_RVT \zone_cycles_reg[11]  ( .D(n193), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[11]) );
  DFFARX1_RVT \zone_cycles_reg[12]  ( .D(n192), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[12]) );
  DFFARX1_RVT \zone_cycles_reg[13]  ( .D(n191), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[13]) );
  DFFARX1_RVT \zone_cycles_reg[14]  ( .D(n190), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[14]) );
  DFFARX1_RVT \win_r_reg[3]  ( .D(n210), .CLK(clk), .RSTB(rst_n), .Q(win_r[3])
         );
  DFFARX1_RVT \zone_cycles_reg[63]  ( .D(n157), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[63]) );
  DFFARX1_RVT \zone_cycles_reg[48]  ( .D(n156), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[48]) );
  DFFARX1_RVT \zone_cycles_reg[49]  ( .D(n155), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[49]) );
  DFFARX1_RVT \zone_cycles_reg[50]  ( .D(n154), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[50]) );
  DFFARX1_RVT \zone_cycles_reg[51]  ( .D(n153), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[51]) );
  DFFARX1_RVT \zone_cycles_reg[52]  ( .D(n152), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[52]) );
  DFFARX1_RVT \zone_cycles_reg[53]  ( .D(n151), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[53]) );
  DFFARX1_RVT \zone_cycles_reg[54]  ( .D(n150), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[54]) );
  DFFARX1_RVT \zone_cycles_reg[55]  ( .D(n149), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[55]) );
  DFFARX1_RVT \zone_cycles_reg[56]  ( .D(n148), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[56]) );
  DFFARX1_RVT \zone_cycles_reg[57]  ( .D(n147), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[57]) );
  DFFARX1_RVT \zone_cycles_reg[58]  ( .D(n146), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[58]) );
  DFFARX1_RVT \zone_cycles_reg[59]  ( .D(n145), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[59]) );
  DFFARX1_RVT \zone_cycles_reg[60]  ( .D(n144), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[60]) );
  DFFARX1_RVT \zone_cycles_reg[61]  ( .D(n143), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[61]) );
  DFFARX1_RVT \zone_cycles_reg[62]  ( .D(n142), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[62]) );
  DFFARX1_RVT \win_r_reg[2]  ( .D(n209), .CLK(clk), .RSTB(rst_n), .Q(win_r[2])
         );
  DFFARX1_RVT \zone_cycles_reg[47]  ( .D(n173), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[47]) );
  DFFARX1_RVT \zone_cycles_reg[32]  ( .D(n172), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[32]) );
  DFFARX1_RVT \zone_cycles_reg[33]  ( .D(n171), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[33]) );
  DFFARX1_RVT \zone_cycles_reg[34]  ( .D(n170), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[34]) );
  DFFARX1_RVT \zone_cycles_reg[35]  ( .D(n169), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[35]) );
  DFFARX1_RVT \zone_cycles_reg[36]  ( .D(n168), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[36]) );
  DFFARX1_RVT \zone_cycles_reg[37]  ( .D(n167), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[37]) );
  DFFARX1_RVT \zone_cycles_reg[38]  ( .D(n166), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[38]) );
  DFFARX1_RVT \zone_cycles_reg[39]  ( .D(n165), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[39]) );
  DFFARX1_RVT \zone_cycles_reg[40]  ( .D(n164), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[40]) );
  DFFARX1_RVT \zone_cycles_reg[41]  ( .D(n163), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[41]) );
  DFFARX1_RVT \zone_cycles_reg[42]  ( .D(n162), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[42]) );
  DFFARX1_RVT \zone_cycles_reg[43]  ( .D(n161), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[43]) );
  DFFARX1_RVT \zone_cycles_reg[44]  ( .D(n160), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[44]) );
  DFFARX1_RVT \zone_cycles_reg[45]  ( .D(n159), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[45]) );
  DFFARX1_RVT \zone_cycles_reg[46]  ( .D(n158), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[46]) );
  DFFARX1_RVT \win_r_reg[1]  ( .D(n208), .CLK(clk), .RSTB(rst_n), .Q(win_r[1])
         );
  DFFARX1_RVT \zone_cycles_reg[31]  ( .D(n189), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[31]) );
  DFFARX1_RVT \zone_cycles_reg[16]  ( .D(n188), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[16]) );
  DFFARX1_RVT \zone_cycles_reg[17]  ( .D(n187), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[17]) );
  DFFARX1_RVT \zone_cycles_reg[18]  ( .D(n186), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[18]) );
  DFFARX1_RVT \zone_cycles_reg[19]  ( .D(n185), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[19]) );
  DFFARX1_RVT \zone_cycles_reg[20]  ( .D(n184), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[20]) );
  DFFARX1_RVT \zone_cycles_reg[21]  ( .D(n183), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[21]) );
  DFFARX1_RVT \zone_cycles_reg[22]  ( .D(n182), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[22]) );
  DFFARX1_RVT \zone_cycles_reg[23]  ( .D(n181), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[23]) );
  DFFARX1_RVT \zone_cycles_reg[24]  ( .D(n180), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[24]) );
  DFFARX1_RVT \zone_cycles_reg[25]  ( .D(n179), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[25]) );
  DFFARX1_RVT \zone_cycles_reg[26]  ( .D(n178), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[26]) );
  DFFARX1_RVT \zone_cycles_reg[27]  ( .D(n177), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[27]) );
  DFFARX1_RVT \zone_cycles_reg[28]  ( .D(n176), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[28]) );
  DFFARX1_RVT \zone_cycles_reg[29]  ( .D(n175), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[29]) );
  DFFARX1_RVT \zone_cycles_reg[30]  ( .D(n174), .CLK(clk), .RSTB(rst_n), .Q(
        zone_cycles[30]) );
  DFFARX1_RVT \valve_r_reg[3]  ( .D(n138), .CLK(clk), .RSTB(rst_n), .Q(
        valve_open[3]) );
  DFFARX1_RVT \valve_r_reg[2]  ( .D(n139), .CLK(clk), .RSTB(rst_n), .Q(
        valve_open[2]) );
  DFFARX1_RVT \valve_r_reg[1]  ( .D(n140), .CLK(clk), .RSTB(rst_n), .Q(
        valve_open[1]) );
  DFFARX1_RVT \valve_r_reg[0]  ( .D(n141), .CLK(clk), .RSTB(rst_n), .Q(
        valve_open[0]) );
  DFFARX1_RVT \cycles_done_reg[31]  ( .D(n257), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[31]) );
  DFFARX1_RVT \cycles_done_reg[30]  ( .D(n226), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[30]) );
  DFFARX1_RVT \cycles_done_reg[29]  ( .D(n227), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[29]) );
  DFFARX1_RVT \cycles_done_reg[28]  ( .D(n228), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[28]) );
  DFFARX1_RVT \cycles_done_reg[27]  ( .D(n229), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[27]) );
  DFFARX1_RVT \cycles_done_reg[26]  ( .D(n230), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[26]) );
  DFFARX1_RVT \cycles_done_reg[25]  ( .D(n231), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[25]) );
  DFFARX1_RVT \cycles_done_reg[24]  ( .D(n232), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[24]) );
  DFFARX1_RVT \cycles_done_reg[23]  ( .D(n233), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[23]) );
  DFFARX1_RVT \cycles_done_reg[22]  ( .D(n234), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[22]) );
  DFFARX1_RVT \cycles_done_reg[21]  ( .D(n235), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[21]) );
  DFFARX1_RVT \cycles_done_reg[20]  ( .D(n236), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[20]) );
  DFFARX1_RVT \cycles_done_reg[19]  ( .D(n237), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[19]) );
  DFFARX1_RVT \cycles_done_reg[18]  ( .D(n238), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[18]) );
  DFFARX1_RVT \cycles_done_reg[17]  ( .D(n239), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[17]) );
  DFFARX1_RVT \cycles_done_reg[16]  ( .D(n240), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[16]) );
  DFFARX1_RVT \cycles_done_reg[15]  ( .D(n241), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[15]) );
  DFFARX1_RVT \cycles_done_reg[14]  ( .D(n242), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[14]) );
  DFFARX1_RVT \cycles_done_reg[13]  ( .D(n243), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[13]) );
  DFFARX1_RVT \cycles_done_reg[12]  ( .D(n244), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[12]) );
  DFFARX1_RVT \cycles_done_reg[11]  ( .D(n245), .CLK(clk), .RSTB(rst_n), .Q(
        cycles_done[11]) );
  DFFARX1_RVT \cycles_done_reg[10]  ( .D(n246), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[10]) );
  DFFARX1_RVT \cycles_done_reg[9]  ( .D(n247), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[9]) );
  DFFARX1_RVT \cycles_done_reg[8]  ( .D(n248), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[8]) );
  DFFARX1_RVT \cycles_done_reg[7]  ( .D(n249), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[7]) );
  DFFARX1_RVT \cycles_done_reg[6]  ( .D(n250), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[6]) );
  DFFARX1_RVT \cycles_done_reg[5]  ( .D(n251), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[5]) );
  DFFARX1_RVT \cycles_done_reg[4]  ( .D(n252), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[4]) );
  DFFARX1_RVT \cycles_done_reg[3]  ( .D(n253), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[3]) );
  DFFARX1_RVT \cycles_done_reg[2]  ( .D(n254), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[2]) );
  DFFARX1_RVT \cycles_done_reg[1]  ( .D(n255), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[1]) );
  DFFARX1_RVT \cycles_done_reg[0]  ( .D(n256), .CLK(clk), .RSTB(n572), .Q(
        cycles_done[0]), .QN(n566) );
  DFFARX1_RVT \timer_reg[14]  ( .D(n225), .CLK(clk), .RSTB(n572), .Q(timer[14]), .QN(n569) );
  DFFARX1_RVT \timer_reg[13]  ( .D(n224), .CLK(clk), .RSTB(n573), .Q(timer[13]), .QN(n562) );
  DFFARX1_RVT \timer_reg[12]  ( .D(n223), .CLK(clk), .RSTB(n573), .Q(timer[12]), .QN(n561) );
  DFFARX1_RVT \timer_reg[11]  ( .D(n222), .CLK(clk), .RSTB(n573), .Q(timer[11]) );
  DFFARX1_RVT \timer_reg[10]  ( .D(n221), .CLK(clk), .RSTB(n573), .Q(timer[10]), .QN(n567) );
  DFFARX1_RVT \timer_reg[9]  ( .D(n220), .CLK(clk), .RSTB(n573), .Q(timer[9])
         );
  DFFARX1_RVT \timer_reg[8]  ( .D(n219), .CLK(clk), .RSTB(n573), .Q(timer[8]), 
        .QN(n568) );
  DFFARX1_RVT \timer_reg[7]  ( .D(n218), .CLK(clk), .RSTB(n573), .Q(timer[7])
         );
  DFFARX1_RVT \timer_reg[6]  ( .D(n217), .CLK(clk), .RSTB(n573), .Q(timer[6]), 
        .QN(n565) );
  DFFARX1_RVT \timer_reg[5]  ( .D(n216), .CLK(clk), .RSTB(n573), .QN(n564) );
  DFFARX1_RVT \timer_reg[4]  ( .D(n215), .CLK(clk), .RSTB(n573), .Q(timer[4]), 
        .QN(n559) );
  DFFARX1_RVT \timer_reg[3]  ( .D(n214), .CLK(clk), .RSTB(n573), .Q(timer[3])
         );
  DFFARX1_RVT \timer_reg[2]  ( .D(n213), .CLK(clk), .RSTB(n573), .Q(timer[2]), 
        .QN(n558) );
  DFFARX1_RVT \timer_reg[1]  ( .D(n212), .CLK(clk), .RSTB(rst_n), .Q(timer[1]), 
        .QN(n560) );
  DFFARX1_RVT \timer_reg[0]  ( .D(n259), .CLK(clk), .RSTB(rst_n), .Q(timer[0]), 
        .QN(n570) );
  DFFARX1_RVT insufficient_reg ( .D(unserved_exists), .CLK(clk), .RSTB(rst_n), 
        .Q(insufficient) );
  INVX0_RVT U265 ( .A(n207), .Y(n408) );
  NAND2X0_RVT U266 ( .A1(n563), .A2(n431), .Y(n549) );
  INVX2_RVT U267 ( .A(n412), .Y(n410) );
  NAND2X0_RVT U268 ( .A1(busy), .A2(n550), .Y(n412) );
  INVX0_RVT U269 ( .A(n429), .Y(busy) );
  INVX0_RVT U270 ( .A(supply_avail[5]), .Y(n295) );
  INVX0_RVT U271 ( .A(supply_avail[6]), .Y(n296) );
  OR2X1_RVT U272 ( .A1(n563), .A2(status[1]), .Y(n429) );
  INVX0_RVT U273 ( .A(supply_avail[7]), .Y(n301) );
  INVX0_RVT U274 ( .A(supply_avail[3]), .Y(n291) );
  INVX0_RVT U275 ( .A(supply_avail[2]), .Y(n289) );
  INVX0_RVT U276 ( .A(supply_avail[1]), .Y(n287) );
  INVX0_RVT U277 ( .A(supply_avail[0]), .Y(n286) );
  OA21X1_RVT U278 ( .A1(zone_demand[1]), .A2(n287), .A3(zone_demand[0]), .Y(
        n261) );
  AO22X1_RVT U279 ( .A1(zone_demand[1]), .A2(n287), .A3(n286), .A4(n261), .Y(
        n262) );
  AO222X1_RVT U280 ( .A1(zone_demand[2]), .A2(n289), .A3(zone_demand[2]), .A4(
        n262), .A5(n289), .A6(n262), .Y(n263) );
  AO222X1_RVT U281 ( .A1(zone_demand[3]), .A2(n291), .A3(zone_demand[3]), .A4(
        n263), .A5(n291), .A6(n263), .Y(n264) );
  INVX0_RVT U282 ( .A(supply_avail[4]), .Y(n292) );
  AO222X1_RVT U283 ( .A1(zone_demand[4]), .A2(n264), .A3(zone_demand[4]), .A4(
        n292), .A5(n264), .A6(n292), .Y(n265) );
  AO222X1_RVT U284 ( .A1(zone_demand[5]), .A2(n295), .A3(zone_demand[5]), .A4(
        n265), .A5(n295), .A6(n265), .Y(n266) );
  AO222X1_RVT U285 ( .A1(zone_demand[6]), .A2(n266), .A3(zone_demand[6]), .A4(
        n296), .A5(n266), .A6(n296), .Y(n267) );
  OR2X1_RVT U286 ( .A1(zone_demand[7]), .A2(n267), .Y(n268) );
  INVX0_RVT U287 ( .A(supply_valid), .Y(n298) );
  AOI221X1_RVT U288 ( .A1(n301), .A2(n268), .A3(zone_demand[7]), .A4(n267), 
        .A5(n298), .Y(n420) );
  NAND2X0_RVT U289 ( .A1(n420), .A2(zone_req[0]), .Y(n303) );
  OA21X1_RVT U290 ( .A1(zone_demand[9]), .A2(n287), .A3(zone_demand[8]), .Y(
        n269) );
  AO22X1_RVT U291 ( .A1(zone_demand[9]), .A2(n287), .A3(n286), .A4(n269), .Y(
        n270) );
  AO222X1_RVT U292 ( .A1(zone_demand[10]), .A2(n289), .A3(zone_demand[10]), 
        .A4(n270), .A5(n289), .A6(n270), .Y(n271) );
  AO222X1_RVT U293 ( .A1(zone_demand[11]), .A2(n291), .A3(zone_demand[11]), 
        .A4(n271), .A5(n291), .A6(n271), .Y(n272) );
  AO222X1_RVT U294 ( .A1(zone_demand[12]), .A2(n272), .A3(zone_demand[12]), 
        .A4(n292), .A5(n272), .A6(n292), .Y(n273) );
  AO222X1_RVT U295 ( .A1(zone_demand[13]), .A2(n295), .A3(zone_demand[13]), 
        .A4(n273), .A5(n295), .A6(n273), .Y(n274) );
  AO222X1_RVT U296 ( .A1(zone_demand[14]), .A2(n274), .A3(zone_demand[14]), 
        .A4(n296), .A5(n274), .A6(n296), .Y(n275) );
  OR2X1_RVT U297 ( .A1(zone_demand[15]), .A2(n275), .Y(n276) );
  AOI221X1_RVT U298 ( .A1(n301), .A2(n276), .A3(zone_demand[15]), .A4(n275), 
        .A5(n298), .Y(n422) );
  NAND2X0_RVT U299 ( .A1(n422), .A2(zone_req[1]), .Y(n307) );
  NAND2X0_RVT U300 ( .A1(n303), .A2(n307), .Y(n315) );
  OA21X1_RVT U301 ( .A1(zone_demand[17]), .A2(n287), .A3(zone_demand[16]), .Y(
        n277) );
  AO22X1_RVT U302 ( .A1(zone_demand[17]), .A2(n287), .A3(n286), .A4(n277), .Y(
        n278) );
  AO222X1_RVT U303 ( .A1(zone_demand[18]), .A2(n289), .A3(zone_demand[18]), 
        .A4(n278), .A5(n289), .A6(n278), .Y(n279) );
  AO222X1_RVT U304 ( .A1(zone_demand[19]), .A2(n291), .A3(zone_demand[19]), 
        .A4(n279), .A5(n291), .A6(n279), .Y(n280) );
  AO222X1_RVT U305 ( .A1(zone_demand[20]), .A2(n280), .A3(zone_demand[20]), 
        .A4(n292), .A5(n280), .A6(n292), .Y(n281) );
  AO222X1_RVT U306 ( .A1(zone_demand[21]), .A2(n295), .A3(zone_demand[21]), 
        .A4(n281), .A5(n295), .A6(n281), .Y(n282) );
  AO222X1_RVT U307 ( .A1(zone_demand[22]), .A2(n282), .A3(zone_demand[22]), 
        .A4(n296), .A5(n282), .A6(n296), .Y(n283) );
  OR2X1_RVT U308 ( .A1(zone_demand[23]), .A2(n283), .Y(n284) );
  AOI221X1_RVT U309 ( .A1(n301), .A2(n284), .A3(zone_demand[23]), .A4(n283), 
        .A5(n298), .Y(n426) );
  NAND2X0_RVT U310 ( .A1(n426), .A2(zone_req[2]), .Y(n313) );
  INVX0_RVT U311 ( .A(n313), .Y(n317) );
  OR2X1_RVT U312 ( .A1(n315), .A2(n317), .Y(n326) );
  INVX0_RVT U313 ( .A(n326), .Y(n302) );
  OA21X1_RVT U314 ( .A1(zone_demand[25]), .A2(n287), .A3(zone_demand[24]), .Y(
        n285) );
  AO22X1_RVT U315 ( .A1(zone_demand[25]), .A2(n287), .A3(n286), .A4(n285), .Y(
        n288) );
  AO222X1_RVT U316 ( .A1(zone_demand[26]), .A2(n289), .A3(zone_demand[26]), 
        .A4(n288), .A5(n289), .A6(n288), .Y(n290) );
  AO222X1_RVT U317 ( .A1(zone_demand[27]), .A2(n291), .A3(zone_demand[27]), 
        .A4(n290), .A5(n291), .A6(n290), .Y(n293) );
  AO222X1_RVT U318 ( .A1(zone_demand[28]), .A2(n293), .A3(zone_demand[28]), 
        .A4(n292), .A5(n293), .A6(n292), .Y(n294) );
  AO222X1_RVT U319 ( .A1(zone_demand[29]), .A2(n295), .A3(zone_demand[29]), 
        .A4(n294), .A5(n295), .A6(n294), .Y(n297) );
  AO222X1_RVT U320 ( .A1(zone_demand[30]), .A2(n297), .A3(zone_demand[30]), 
        .A4(n296), .A5(n297), .A6(n296), .Y(n299) );
  OR2X1_RVT U321 ( .A1(zone_demand[31]), .A2(n299), .Y(n300) );
  AOI221X1_RVT U322 ( .A1(n301), .A2(n300), .A3(zone_demand[31]), .A4(n299), 
        .A5(n298), .Y(n424) );
  NAND2X0_RVT U323 ( .A1(n424), .A2(zone_req[3]), .Y(n324) );
  NAND2X0_RVT U324 ( .A1(n302), .A2(n324), .Y(n431) );
  NAND2X0_RVT U325 ( .A1(n549), .A2(n429), .Y(n207) );
  INVX0_RVT U326 ( .A(n303), .Y(n309) );
  INVX0_RVT U327 ( .A(zone_prio[3]), .Y(n306) );
  INVX0_RVT U328 ( .A(zone_prio[0]), .Y(n304) );
  NAND2X0_RVT U329 ( .A1(zone_prio[2]), .A2(n304), .Y(n305) );
  AO222X1_RVT U330 ( .A1(zone_prio[1]), .A2(n306), .A3(zone_prio[1]), .A4(n305), .A5(n306), .A6(n305), .Y(n308) );
  AO21X1_RVT U331 ( .A1(n309), .A2(n308), .A3(n307), .Y(n310) );
  AND2X1_RVT U332 ( .A1(n309), .A2(n310), .Y(n328) );
  INVX0_RVT U333 ( .A(zone_prio[5]), .Y(n312) );
  INVX0_RVT U334 ( .A(n310), .Y(n553) );
  AO22X1_RVT U335 ( .A1(zone_prio[1]), .A2(n328), .A3(zone_prio[3]), .A4(n553), 
        .Y(n316) );
  AOI22X1_RVT U336 ( .A1(zone_prio[0]), .A2(n328), .A3(zone_prio[2]), .A4(n553), .Y(n318) );
  NAND2X0_RVT U337 ( .A1(n318), .A2(zone_prio[4]), .Y(n311) );
  AO222X1_RVT U338 ( .A1(n312), .A2(n316), .A3(n312), .A4(n311), .A5(n316), 
        .A6(n311), .Y(n314) );
  AO21X1_RVT U339 ( .A1(n315), .A2(n314), .A3(n313), .Y(n327) );
  INVX0_RVT U340 ( .A(zone_prio[7]), .Y(n323) );
  AO21X1_RVT U341 ( .A1(n317), .A2(zone_prio[5]), .A3(n316), .Y(n322) );
  INVX0_RVT U342 ( .A(n327), .Y(n417) );
  NAND2X0_RVT U343 ( .A1(n417), .A2(zone_prio[4]), .Y(n320) );
  OR2X1_RVT U344 ( .A1(n417), .A2(n318), .Y(n319) );
  NAND3X0_RVT U345 ( .A1(zone_prio[6]), .A2(n320), .A3(n319), .Y(n321) );
  AO222X1_RVT U346 ( .A1(n323), .A2(n322), .A3(n323), .A4(n321), .A5(n322), 
        .A6(n321), .Y(n325) );
  AO21X1_RVT U347 ( .A1(n326), .A2(n325), .A3(n324), .Y(n416) );
  AND2X1_RVT U348 ( .A1(n327), .A2(n416), .Y(n552) );
  AND2X1_RVT U349 ( .A1(n328), .A2(n552), .Y(n551) );
  INVX0_RVT U350 ( .A(n549), .Y(n418) );
  MUX21X1_RVT U351 ( .A1(win_r[0]), .A2(n551), .S0(n418), .Y(n211) );
  NBUFFX2_RVT U353 ( .A(rst_n), .Y(n572) );
  NBUFFX2_RVT U354 ( .A(rst_n), .Y(n573) );
  NOR2X0_RVT U356 ( .A1(timer[8]), .A2(timer[9]), .Y(n385) );
  NOR2X0_RVT U357 ( .A1(timer[11]), .A2(timer[10]), .Y(n386) );
  AND3X1_RVT U358 ( .A1(n569), .A2(n562), .A3(n560), .Y(n331) );
  NAND4X0_RVT U359 ( .A1(n561), .A2(n559), .A3(n558), .A4(n564), .Y(n329) );
  NOR4X1_RVT U360 ( .A1(timer[6]), .A2(timer[7]), .A3(timer[3]), .A4(n329), 
        .Y(n330) );
  NAND4X0_RVT U361 ( .A1(n385), .A2(n386), .A3(n331), .A4(n330), .Y(n550) );
  AO22X1_RVT U362 ( .A1(timer[0]), .A2(n408), .A3(n570), .A4(n410), .Y(n259)
         );
  NAND2X0_RVT U363 ( .A1(status[0]), .A2(status[1]), .Y(n335) );
  INVX2_RVT U364 ( .A(n335), .Y(n519) );
  AND3X1_RVT U365 ( .A1(cycles_done[2]), .A2(cycles_done[1]), .A3(
        cycles_done[0]), .Y(n338) );
  AND3X1_RVT U366 ( .A1(n338), .A2(cycles_done[4]), .A3(cycles_done[3]), .Y(
        n341) );
  AND3X1_RVT U367 ( .A1(n341), .A2(cycles_done[6]), .A3(cycles_done[5]), .Y(
        n344) );
  AND3X1_RVT U368 ( .A1(n344), .A2(cycles_done[8]), .A3(cycles_done[7]), .Y(
        n347) );
  AND3X1_RVT U369 ( .A1(n347), .A2(cycles_done[10]), .A3(cycles_done[9]), .Y(
        n350) );
  AND3X1_RVT U370 ( .A1(n350), .A2(cycles_done[12]), .A3(cycles_done[11]), .Y(
        n353) );
  AND3X1_RVT U371 ( .A1(n353), .A2(cycles_done[14]), .A3(cycles_done[13]), .Y(
        n356) );
  AND3X1_RVT U372 ( .A1(n356), .A2(cycles_done[16]), .A3(cycles_done[15]), .Y(
        n332) );
  AND2X1_RVT U373 ( .A1(n519), .A2(n332), .Y(n359) );
  AND2X1_RVT U374 ( .A1(cycles_done[17]), .A2(n359), .Y(n333) );
  AND2X1_RVT U375 ( .A1(cycles_done[18]), .A2(n333), .Y(n362) );
  NAND2X0_RVT U376 ( .A1(n362), .A2(cycles_done[19]), .Y(n361) );
  INVX0_RVT U377 ( .A(n361), .Y(n364) );
  NAND2X0_RVT U378 ( .A1(cycles_done[20]), .A2(n364), .Y(n363) );
  INVX0_RVT U379 ( .A(n363), .Y(n366) );
  NAND2X0_RVT U380 ( .A1(n366), .A2(cycles_done[21]), .Y(n365) );
  INVX0_RVT U381 ( .A(n365), .Y(n368) );
  NAND2X0_RVT U382 ( .A1(n368), .A2(cycles_done[22]), .Y(n367) );
  INVX0_RVT U383 ( .A(n367), .Y(n370) );
  NAND2X0_RVT U384 ( .A1(n370), .A2(cycles_done[23]), .Y(n369) );
  INVX0_RVT U385 ( .A(n369), .Y(n372) );
  NAND2X0_RVT U386 ( .A1(n372), .A2(cycles_done[24]), .Y(n371) );
  INVX0_RVT U387 ( .A(n371), .Y(n374) );
  NAND2X0_RVT U388 ( .A1(n374), .A2(cycles_done[25]), .Y(n373) );
  INVX0_RVT U389 ( .A(n373), .Y(n376) );
  NAND2X0_RVT U390 ( .A1(n376), .A2(cycles_done[26]), .Y(n375) );
  INVX0_RVT U391 ( .A(n375), .Y(n378) );
  NAND2X0_RVT U392 ( .A1(n378), .A2(cycles_done[27]), .Y(n377) );
  INVX0_RVT U393 ( .A(n377), .Y(n380) );
  NAND2X0_RVT U394 ( .A1(n380), .A2(cycles_done[28]), .Y(n379) );
  INVX0_RVT U395 ( .A(n379), .Y(n382) );
  NAND2X0_RVT U396 ( .A1(n382), .A2(cycles_done[29]), .Y(n381) );
  INVX0_RVT U397 ( .A(n381), .Y(n384) );
  NAND2X0_RVT U398 ( .A1(n384), .A2(cycles_done[30]), .Y(n383) );
  INVX0_RVT U399 ( .A(n383), .Y(n334) );
  HADDX1_RVT U400 ( .A0(n334), .B0(cycles_done[31]), .SO(n257) );
  AO22X1_RVT U401 ( .A1(n519), .A2(n566), .A3(n335), .A4(cycles_done[0]), .Y(
        n256) );
  NAND3X0_RVT U402 ( .A1(n519), .A2(cycles_done[1]), .A3(cycles_done[0]), .Y(
        n336) );
  OA221X1_RVT U403 ( .A1(cycles_done[1]), .A2(n519), .A3(cycles_done[1]), .A4(
        cycles_done[0]), .A5(n336), .Y(n255) );
  INVX0_RVT U404 ( .A(n336), .Y(n337) );
  HADDX1_RVT U405 ( .A0(cycles_done[2]), .B0(n337), .SO(n254) );
  NAND3X0_RVT U406 ( .A1(n519), .A2(n338), .A3(cycles_done[3]), .Y(n339) );
  OA221X1_RVT U407 ( .A1(cycles_done[3]), .A2(n338), .A3(cycles_done[3]), .A4(
        n519), .A5(n339), .Y(n253) );
  INVX0_RVT U408 ( .A(n339), .Y(n340) );
  HADDX1_RVT U409 ( .A0(cycles_done[4]), .B0(n340), .SO(n252) );
  NAND3X0_RVT U410 ( .A1(n519), .A2(n341), .A3(cycles_done[5]), .Y(n342) );
  OA221X1_RVT U411 ( .A1(cycles_done[5]), .A2(n341), .A3(cycles_done[5]), .A4(
        n519), .A5(n342), .Y(n251) );
  INVX0_RVT U412 ( .A(n342), .Y(n343) );
  HADDX1_RVT U413 ( .A0(cycles_done[6]), .B0(n343), .SO(n250) );
  NAND3X0_RVT U414 ( .A1(n519), .A2(n344), .A3(cycles_done[7]), .Y(n345) );
  OA221X1_RVT U415 ( .A1(cycles_done[7]), .A2(n344), .A3(cycles_done[7]), .A4(
        n519), .A5(n345), .Y(n249) );
  INVX0_RVT U416 ( .A(n345), .Y(n346) );
  HADDX1_RVT U417 ( .A0(cycles_done[8]), .B0(n346), .SO(n248) );
  NAND3X0_RVT U418 ( .A1(n519), .A2(n347), .A3(cycles_done[9]), .Y(n348) );
  OA221X1_RVT U419 ( .A1(cycles_done[9]), .A2(n347), .A3(cycles_done[9]), .A4(
        n519), .A5(n348), .Y(n247) );
  INVX0_RVT U420 ( .A(n348), .Y(n349) );
  HADDX1_RVT U421 ( .A0(cycles_done[10]), .B0(n349), .SO(n246) );
  NAND3X0_RVT U422 ( .A1(n519), .A2(n350), .A3(cycles_done[11]), .Y(n351) );
  OA221X1_RVT U423 ( .A1(cycles_done[11]), .A2(n350), .A3(cycles_done[11]), 
        .A4(n519), .A5(n351), .Y(n245) );
  INVX0_RVT U424 ( .A(n351), .Y(n352) );
  HADDX1_RVT U425 ( .A0(cycles_done[12]), .B0(n352), .SO(n244) );
  NAND3X0_RVT U426 ( .A1(n519), .A2(n353), .A3(cycles_done[13]), .Y(n354) );
  OA221X1_RVT U427 ( .A1(cycles_done[13]), .A2(n353), .A3(cycles_done[13]), 
        .A4(n519), .A5(n354), .Y(n243) );
  INVX0_RVT U428 ( .A(n354), .Y(n355) );
  HADDX1_RVT U429 ( .A0(cycles_done[14]), .B0(n355), .SO(n242) );
  NAND3X0_RVT U430 ( .A1(n519), .A2(n356), .A3(cycles_done[15]), .Y(n357) );
  OA221X1_RVT U431 ( .A1(cycles_done[15]), .A2(n356), .A3(cycles_done[15]), 
        .A4(n519), .A5(n357), .Y(n241) );
  INVX0_RVT U432 ( .A(n357), .Y(n358) );
  HADDX1_RVT U433 ( .A0(cycles_done[16]), .B0(n358), .SO(n240) );
  NAND2X0_RVT U434 ( .A1(cycles_done[17]), .A2(n359), .Y(n360) );
  OA21X1_RVT U435 ( .A1(cycles_done[17]), .A2(n359), .A3(n360), .Y(n239) );
  HADDX1_RVT U436 ( .A0(cycles_done[18]), .B0(n333), .SO(n238) );
  OA21X1_RVT U437 ( .A1(n362), .A2(cycles_done[19]), .A3(n361), .Y(n237) );
  OA21X1_RVT U438 ( .A1(cycles_done[20]), .A2(n364), .A3(n363), .Y(n236) );
  OA21X1_RVT U439 ( .A1(n366), .A2(cycles_done[21]), .A3(n365), .Y(n235) );
  OA21X1_RVT U440 ( .A1(n368), .A2(cycles_done[22]), .A3(n367), .Y(n234) );
  OA21X1_RVT U441 ( .A1(n370), .A2(cycles_done[23]), .A3(n369), .Y(n233) );
  OA21X1_RVT U442 ( .A1(n372), .A2(cycles_done[24]), .A3(n371), .Y(n232) );
  OA21X1_RVT U443 ( .A1(n374), .A2(cycles_done[25]), .A3(n373), .Y(n231) );
  OA21X1_RVT U444 ( .A1(n376), .A2(cycles_done[26]), .A3(n375), .Y(n230) );
  OA21X1_RVT U445 ( .A1(n378), .A2(cycles_done[27]), .A3(n377), .Y(n229) );
  OA21X1_RVT U446 ( .A1(n380), .A2(cycles_done[28]), .A3(n379), .Y(n228) );
  OA21X1_RVT U447 ( .A1(n382), .A2(cycles_done[29]), .A3(n381), .Y(n227) );
  OA21X1_RVT U448 ( .A1(n384), .A2(cycles_done[30]), .A3(n383), .Y(n226) );
  NOR4X1_RVT U449 ( .A1(timer[3]), .A2(timer[1]), .A3(timer[2]), .A4(timer[0]), 
        .Y(n409) );
  NAND3X0_RVT U450 ( .A1(n409), .A2(n559), .A3(n564), .Y(n404) );
  OR3X1_RVT U451 ( .A1(timer[6]), .A2(timer[7]), .A3(n404), .Y(n398) );
  INVX0_RVT U452 ( .A(n398), .Y(n400) );
  NAND2X0_RVT U453 ( .A1(n385), .A2(n400), .Y(n394) );
  INVX0_RVT U454 ( .A(n394), .Y(n396) );
  NAND2X0_RVT U455 ( .A1(n386), .A2(n396), .Y(n390) );
  NOR3X0_RVT U456 ( .A1(timer[13]), .A2(timer[12]), .A3(n390), .Y(n388) );
  OAI21X1_RVT U457 ( .A1(n388), .A2(n412), .A3(n207), .Y(n387) );
  OA222X1_RVT U458 ( .A1(timer[14]), .A2(n410), .A3(timer[14]), .A4(n388), 
        .A5(n569), .A6(n387), .Y(n225) );
  AO221X1_RVT U459 ( .A1(n410), .A2(timer[12]), .A3(n410), .A4(n390), .A5(n408), .Y(n389) );
  AO22X1_RVT U460 ( .A1(timer[13]), .A2(n389), .A3(n410), .A4(n388), .Y(n224)
         );
  INVX0_RVT U461 ( .A(n390), .Y(n392) );
  AO21X1_RVT U462 ( .A1(n410), .A2(n390), .A3(n408), .Y(n391) );
  OA222X1_RVT U463 ( .A1(timer[12]), .A2(n410), .A3(timer[12]), .A4(n392), 
        .A5(n561), .A6(n391), .Y(n223) );
  AO221X1_RVT U464 ( .A1(n410), .A2(timer[10]), .A3(n410), .A4(n394), .A5(n408), .Y(n393) );
  AO22X1_RVT U465 ( .A1(timer[11]), .A2(n393), .A3(n410), .A4(n392), .Y(n222)
         );
  AO21X1_RVT U466 ( .A1(n410), .A2(n394), .A3(n408), .Y(n395) );
  OA222X1_RVT U467 ( .A1(timer[10]), .A2(n410), .A3(timer[10]), .A4(n396), 
        .A5(n567), .A6(n395), .Y(n221) );
  AO221X1_RVT U468 ( .A1(n410), .A2(timer[8]), .A3(n410), .A4(n398), .A5(n408), 
        .Y(n397) );
  AO22X1_RVT U469 ( .A1(timer[9]), .A2(n397), .A3(n410), .A4(n396), .Y(n220)
         );
  AO21X1_RVT U470 ( .A1(n410), .A2(n398), .A3(n408), .Y(n399) );
  OA222X1_RVT U471 ( .A1(timer[8]), .A2(n410), .A3(timer[8]), .A4(n400), .A5(
        n568), .A6(n399), .Y(n219) );
  AO221X1_RVT U472 ( .A1(n410), .A2(timer[6]), .A3(n410), .A4(n404), .A5(n408), 
        .Y(n401) );
  AO22X1_RVT U473 ( .A1(timer[7]), .A2(n401), .A3(n410), .A4(n400), .Y(n218)
         );
  INVX0_RVT U474 ( .A(n404), .Y(n403) );
  AO21X1_RVT U475 ( .A1(n410), .A2(n404), .A3(n408), .Y(n402) );
  OA222X1_RVT U476 ( .A1(timer[6]), .A2(n410), .A3(timer[6]), .A4(n403), .A5(
        n565), .A6(n402), .Y(n217) );
  OA221X1_RVT U477 ( .A1(n412), .A2(n409), .A3(n412), .A4(n559), .A5(n207), 
        .Y(n405) );
  OAI22X1_RVT U478 ( .A1(n405), .A2(n564), .A3(n412), .A4(n404), .Y(n216) );
  OAI21X1_RVT U479 ( .A1(n412), .A2(n409), .A3(n207), .Y(n407) );
  AND2X1_RVT U480 ( .A1(n410), .A2(n409), .Y(n406) );
  AO221X1_RVT U481 ( .A1(timer[4]), .A2(n407), .A3(n559), .A4(n406), .A5(n418), 
        .Y(n215) );
  AO221X1_RVT U482 ( .A1(n410), .A2(timer[1]), .A3(n410), .A4(timer[0]), .A5(
        n408), .Y(n413) );
  AO21X1_RVT U483 ( .A1(timer[2]), .A2(busy), .A3(n413), .Y(n411) );
  AO22X1_RVT U484 ( .A1(timer[3]), .A2(n411), .A3(n410), .A4(n409), .Y(n214)
         );
  NOR3X0_RVT U485 ( .A1(timer[1]), .A2(timer[0]), .A3(n412), .Y(n414) );
  AO22X1_RVT U486 ( .A1(timer[2]), .A2(n413), .A3(n558), .A4(n414), .Y(n213)
         );
  AO22X1_RVT U487 ( .A1(n410), .A2(timer[0]), .A3(n549), .A4(n429), .Y(n415)
         );
  AO21X1_RVT U488 ( .A1(timer[1]), .A2(n415), .A3(n414), .Y(n212) );
  INVX0_RVT U489 ( .A(n416), .Y(n556) );
  AO22X1_RVT U490 ( .A1(win_r[3]), .A2(n549), .A3(n556), .A4(n563), .Y(n210)
         );
  AND3X1_RVT U491 ( .A1(n417), .A2(n563), .A3(n416), .Y(n555) );
  AO21X1_RVT U492 ( .A1(win_r[2]), .A2(n549), .A3(n555), .Y(n209) );
  OA222X1_RVT U493 ( .A1(n549), .A2(n553), .A3(n549), .A4(n552), .A5(win_r[1]), 
        .A6(n418), .Y(n208) );
  INVX0_RVT U494 ( .A(zone_req[1]), .Y(n421) );
  INVX0_RVT U495 ( .A(zone_req[0]), .Y(n419) );
  OA22X1_RVT U496 ( .A1(n422), .A2(n421), .A3(n420), .A4(n419), .Y(n428) );
  INVX0_RVT U497 ( .A(zone_req[2]), .Y(n425) );
  INVX0_RVT U498 ( .A(zone_req[3]), .Y(n423) );
  OA22X1_RVT U499 ( .A1(n426), .A2(n425), .A3(n424), .A4(n423), .Y(n427) );
  NAND2X0_RVT U500 ( .A1(n428), .A2(n427), .Y(unserved_exists) );
  NAND2X0_RVT U501 ( .A1(n563), .A2(unserved_exists), .Y(n430) );
  OAI22X1_RVT U502 ( .A1(n431), .A2(n430), .A3(n550), .A4(n429), .Y(n206) );
  AND2X1_RVT U503 ( .A1(win_r[0]), .A2(n519), .Y(grant_ack[0]) );
  AND4X1_RVT U504 ( .A1(grant_ack[0]), .A2(zone_cycles[2]), .A3(zone_cycles[1]), .A4(zone_cycles[0]), .Y(n438) );
  NAND2X0_RVT U505 ( .A1(n438), .A2(zone_cycles[3]), .Y(n437) );
  INVX0_RVT U506 ( .A(n437), .Y(n440) );
  NAND2X0_RVT U507 ( .A1(zone_cycles[4]), .A2(n440), .Y(n439) );
  INVX0_RVT U508 ( .A(n439), .Y(n442) );
  NAND2X0_RVT U509 ( .A1(n442), .A2(zone_cycles[5]), .Y(n441) );
  INVX0_RVT U510 ( .A(n441), .Y(n444) );
  NAND2X0_RVT U511 ( .A1(n444), .A2(zone_cycles[6]), .Y(n443) );
  INVX0_RVT U512 ( .A(n443), .Y(n446) );
  NAND2X0_RVT U513 ( .A1(n446), .A2(zone_cycles[7]), .Y(n445) );
  INVX0_RVT U514 ( .A(n445), .Y(n448) );
  NAND2X0_RVT U515 ( .A1(n448), .A2(zone_cycles[8]), .Y(n447) );
  INVX0_RVT U516 ( .A(n447), .Y(n450) );
  NAND2X0_RVT U517 ( .A1(n450), .A2(zone_cycles[9]), .Y(n449) );
  INVX0_RVT U518 ( .A(n449), .Y(n452) );
  NAND2X0_RVT U519 ( .A1(n452), .A2(zone_cycles[10]), .Y(n451) );
  INVX0_RVT U520 ( .A(n451), .Y(n454) );
  NAND2X0_RVT U521 ( .A1(n454), .A2(zone_cycles[11]), .Y(n453) );
  INVX0_RVT U522 ( .A(n453), .Y(n456) );
  NAND2X0_RVT U523 ( .A1(n456), .A2(zone_cycles[12]), .Y(n455) );
  INVX0_RVT U524 ( .A(n455), .Y(n458) );
  NAND2X0_RVT U525 ( .A1(n458), .A2(zone_cycles[13]), .Y(n457) );
  INVX0_RVT U526 ( .A(n457), .Y(n460) );
  NAND2X0_RVT U527 ( .A1(n460), .A2(zone_cycles[14]), .Y(n459) );
  INVX0_RVT U528 ( .A(n459), .Y(n432) );
  HADDX1_RVT U529 ( .A0(n432), .B0(zone_cycles[15]), .SO(n205) );
  NAND2X0_RVT U530 ( .A1(grant_ack[0]), .A2(zone_cycles[0]), .Y(n433) );
  OA21X1_RVT U531 ( .A1(grant_ack[0]), .A2(zone_cycles[0]), .A3(n433), .Y(n204) );
  INVX0_RVT U532 ( .A(n433), .Y(n434) );
  NAND3X0_RVT U533 ( .A1(grant_ack[0]), .A2(zone_cycles[1]), .A3(
        zone_cycles[0]), .Y(n435) );
  OA21X1_RVT U534 ( .A1(zone_cycles[1]), .A2(n434), .A3(n435), .Y(n203) );
  INVX0_RVT U535 ( .A(n435), .Y(n436) );
  HADDX1_RVT U536 ( .A0(zone_cycles[2]), .B0(n436), .SO(n202) );
  OA21X1_RVT U537 ( .A1(n438), .A2(zone_cycles[3]), .A3(n437), .Y(n201) );
  OA21X1_RVT U538 ( .A1(zone_cycles[4]), .A2(n440), .A3(n439), .Y(n200) );
  OA21X1_RVT U539 ( .A1(n442), .A2(zone_cycles[5]), .A3(n441), .Y(n199) );
  OA21X1_RVT U540 ( .A1(n444), .A2(zone_cycles[6]), .A3(n443), .Y(n198) );
  OA21X1_RVT U541 ( .A1(n446), .A2(zone_cycles[7]), .A3(n445), .Y(n197) );
  OA21X1_RVT U542 ( .A1(n448), .A2(zone_cycles[8]), .A3(n447), .Y(n196) );
  OA21X1_RVT U543 ( .A1(n450), .A2(zone_cycles[9]), .A3(n449), .Y(n195) );
  OA21X1_RVT U544 ( .A1(n452), .A2(zone_cycles[10]), .A3(n451), .Y(n194) );
  OA21X1_RVT U545 ( .A1(n454), .A2(zone_cycles[11]), .A3(n453), .Y(n193) );
  OA21X1_RVT U546 ( .A1(n456), .A2(zone_cycles[12]), .A3(n455), .Y(n192) );
  OA21X1_RVT U547 ( .A1(n458), .A2(zone_cycles[13]), .A3(n457), .Y(n191) );
  OA21X1_RVT U548 ( .A1(n460), .A2(zone_cycles[14]), .A3(n459), .Y(n190) );
  AND2X1_RVT U549 ( .A1(win_r[1]), .A2(n519), .Y(grant_ack[1]) );
  AND4X1_RVT U550 ( .A1(grant_ack[1]), .A2(zone_cycles[18]), .A3(
        zone_cycles[17]), .A4(zone_cycles[16]), .Y(n467) );
  NAND2X0_RVT U551 ( .A1(n467), .A2(zone_cycles[19]), .Y(n466) );
  INVX0_RVT U552 ( .A(n466), .Y(n469) );
  NAND2X0_RVT U553 ( .A1(zone_cycles[20]), .A2(n469), .Y(n468) );
  INVX0_RVT U554 ( .A(n468), .Y(n471) );
  NAND2X0_RVT U555 ( .A1(n471), .A2(zone_cycles[21]), .Y(n470) );
  INVX0_RVT U556 ( .A(n470), .Y(n473) );
  NAND2X0_RVT U557 ( .A1(n473), .A2(zone_cycles[22]), .Y(n472) );
  INVX0_RVT U558 ( .A(n472), .Y(n475) );
  NAND2X0_RVT U559 ( .A1(n475), .A2(zone_cycles[23]), .Y(n474) );
  INVX0_RVT U560 ( .A(n474), .Y(n477) );
  NAND2X0_RVT U561 ( .A1(n477), .A2(zone_cycles[24]), .Y(n476) );
  INVX0_RVT U562 ( .A(n476), .Y(n479) );
  NAND2X0_RVT U563 ( .A1(n479), .A2(zone_cycles[25]), .Y(n478) );
  INVX0_RVT U564 ( .A(n478), .Y(n481) );
  NAND2X0_RVT U565 ( .A1(n481), .A2(zone_cycles[26]), .Y(n480) );
  INVX0_RVT U566 ( .A(n480), .Y(n483) );
  NAND2X0_RVT U567 ( .A1(n483), .A2(zone_cycles[27]), .Y(n482) );
  INVX0_RVT U568 ( .A(n482), .Y(n485) );
  NAND2X0_RVT U569 ( .A1(n485), .A2(zone_cycles[28]), .Y(n484) );
  INVX0_RVT U570 ( .A(n484), .Y(n487) );
  NAND2X0_RVT U571 ( .A1(n487), .A2(zone_cycles[29]), .Y(n486) );
  INVX0_RVT U572 ( .A(n486), .Y(n489) );
  NAND2X0_RVT U573 ( .A1(n489), .A2(zone_cycles[30]), .Y(n488) );
  INVX0_RVT U574 ( .A(n488), .Y(n461) );
  HADDX1_RVT U575 ( .A0(n461), .B0(zone_cycles[31]), .SO(n189) );
  NAND2X0_RVT U576 ( .A1(grant_ack[1]), .A2(zone_cycles[16]), .Y(n462) );
  OA21X1_RVT U577 ( .A1(grant_ack[1]), .A2(zone_cycles[16]), .A3(n462), .Y(
        n188) );
  INVX0_RVT U578 ( .A(n462), .Y(n463) );
  NAND3X0_RVT U579 ( .A1(grant_ack[1]), .A2(zone_cycles[17]), .A3(
        zone_cycles[16]), .Y(n464) );
  OA21X1_RVT U580 ( .A1(zone_cycles[17]), .A2(n463), .A3(n464), .Y(n187) );
  INVX0_RVT U581 ( .A(n464), .Y(n465) );
  HADDX1_RVT U582 ( .A0(zone_cycles[18]), .B0(n465), .SO(n186) );
  OA21X1_RVT U583 ( .A1(n467), .A2(zone_cycles[19]), .A3(n466), .Y(n185) );
  OA21X1_RVT U584 ( .A1(zone_cycles[20]), .A2(n469), .A3(n468), .Y(n184) );
  OA21X1_RVT U585 ( .A1(n471), .A2(zone_cycles[21]), .A3(n470), .Y(n183) );
  OA21X1_RVT U586 ( .A1(n473), .A2(zone_cycles[22]), .A3(n472), .Y(n182) );
  OA21X1_RVT U587 ( .A1(n475), .A2(zone_cycles[23]), .A3(n474), .Y(n181) );
  OA21X1_RVT U588 ( .A1(n477), .A2(zone_cycles[24]), .A3(n476), .Y(n180) );
  OA21X1_RVT U589 ( .A1(n479), .A2(zone_cycles[25]), .A3(n478), .Y(n179) );
  OA21X1_RVT U590 ( .A1(n481), .A2(zone_cycles[26]), .A3(n480), .Y(n178) );
  OA21X1_RVT U591 ( .A1(n483), .A2(zone_cycles[27]), .A3(n482), .Y(n177) );
  OA21X1_RVT U592 ( .A1(n485), .A2(zone_cycles[28]), .A3(n484), .Y(n176) );
  OA21X1_RVT U593 ( .A1(n487), .A2(zone_cycles[29]), .A3(n486), .Y(n175) );
  OA21X1_RVT U594 ( .A1(n489), .A2(zone_cycles[30]), .A3(n488), .Y(n174) );
  AND2X1_RVT U595 ( .A1(win_r[2]), .A2(n519), .Y(grant_ack[2]) );
  AND4X1_RVT U596 ( .A1(grant_ack[2]), .A2(zone_cycles[34]), .A3(
        zone_cycles[33]), .A4(zone_cycles[32]), .Y(n496) );
  NAND2X0_RVT U597 ( .A1(n496), .A2(zone_cycles[35]), .Y(n495) );
  INVX0_RVT U598 ( .A(n495), .Y(n498) );
  NAND2X0_RVT U599 ( .A1(zone_cycles[36]), .A2(n498), .Y(n497) );
  INVX0_RVT U600 ( .A(n497), .Y(n500) );
  NAND2X0_RVT U601 ( .A1(n500), .A2(zone_cycles[37]), .Y(n499) );
  INVX0_RVT U602 ( .A(n499), .Y(n502) );
  NAND2X0_RVT U603 ( .A1(n502), .A2(zone_cycles[38]), .Y(n501) );
  INVX0_RVT U604 ( .A(n501), .Y(n504) );
  NAND2X0_RVT U605 ( .A1(n504), .A2(zone_cycles[39]), .Y(n503) );
  INVX0_RVT U606 ( .A(n503), .Y(n506) );
  NAND2X0_RVT U607 ( .A1(n506), .A2(zone_cycles[40]), .Y(n505) );
  INVX0_RVT U608 ( .A(n505), .Y(n508) );
  NAND2X0_RVT U609 ( .A1(n508), .A2(zone_cycles[41]), .Y(n507) );
  INVX0_RVT U610 ( .A(n507), .Y(n510) );
  NAND2X0_RVT U611 ( .A1(n510), .A2(zone_cycles[42]), .Y(n509) );
  INVX0_RVT U612 ( .A(n509), .Y(n512) );
  NAND2X0_RVT U613 ( .A1(n512), .A2(zone_cycles[43]), .Y(n511) );
  INVX0_RVT U614 ( .A(n511), .Y(n514) );
  NAND2X0_RVT U615 ( .A1(n514), .A2(zone_cycles[44]), .Y(n513) );
  INVX0_RVT U616 ( .A(n513), .Y(n516) );
  NAND2X0_RVT U617 ( .A1(n516), .A2(zone_cycles[45]), .Y(n515) );
  INVX0_RVT U618 ( .A(n515), .Y(n518) );
  NAND2X0_RVT U619 ( .A1(n518), .A2(zone_cycles[46]), .Y(n517) );
  INVX0_RVT U620 ( .A(n517), .Y(n490) );
  HADDX1_RVT U621 ( .A0(n490), .B0(zone_cycles[47]), .SO(n173) );
  NAND2X0_RVT U622 ( .A1(grant_ack[2]), .A2(zone_cycles[32]), .Y(n491) );
  OA21X1_RVT U623 ( .A1(grant_ack[2]), .A2(zone_cycles[32]), .A3(n491), .Y(
        n172) );
  INVX0_RVT U624 ( .A(n491), .Y(n492) );
  NAND3X0_RVT U625 ( .A1(grant_ack[2]), .A2(zone_cycles[33]), .A3(
        zone_cycles[32]), .Y(n493) );
  OA21X1_RVT U626 ( .A1(zone_cycles[33]), .A2(n492), .A3(n493), .Y(n171) );
  INVX0_RVT U627 ( .A(n493), .Y(n494) );
  HADDX1_RVT U628 ( .A0(zone_cycles[34]), .B0(n494), .SO(n170) );
  OA21X1_RVT U629 ( .A1(n496), .A2(zone_cycles[35]), .A3(n495), .Y(n169) );
  OA21X1_RVT U630 ( .A1(zone_cycles[36]), .A2(n498), .A3(n497), .Y(n168) );
  OA21X1_RVT U631 ( .A1(n500), .A2(zone_cycles[37]), .A3(n499), .Y(n167) );
  OA21X1_RVT U632 ( .A1(n502), .A2(zone_cycles[38]), .A3(n501), .Y(n166) );
  OA21X1_RVT U633 ( .A1(n504), .A2(zone_cycles[39]), .A3(n503), .Y(n165) );
  OA21X1_RVT U634 ( .A1(n506), .A2(zone_cycles[40]), .A3(n505), .Y(n164) );
  OA21X1_RVT U635 ( .A1(n508), .A2(zone_cycles[41]), .A3(n507), .Y(n163) );
  OA21X1_RVT U636 ( .A1(n510), .A2(zone_cycles[42]), .A3(n509), .Y(n162) );
  OA21X1_RVT U637 ( .A1(n512), .A2(zone_cycles[43]), .A3(n511), .Y(n161) );
  OA21X1_RVT U638 ( .A1(n514), .A2(zone_cycles[44]), .A3(n513), .Y(n160) );
  OA21X1_RVT U639 ( .A1(n516), .A2(zone_cycles[45]), .A3(n515), .Y(n159) );
  OA21X1_RVT U640 ( .A1(n518), .A2(zone_cycles[46]), .A3(n517), .Y(n158) );
  AND2X1_RVT U641 ( .A1(win_r[3]), .A2(n519), .Y(grant_ack[3]) );
  AND4X1_RVT U642 ( .A1(grant_ack[3]), .A2(zone_cycles[50]), .A3(
        zone_cycles[49]), .A4(zone_cycles[48]), .Y(n526) );
  NAND2X0_RVT U643 ( .A1(n526), .A2(zone_cycles[51]), .Y(n525) );
  INVX0_RVT U644 ( .A(n525), .Y(n528) );
  NAND2X0_RVT U645 ( .A1(zone_cycles[52]), .A2(n528), .Y(n527) );
  INVX0_RVT U646 ( .A(n527), .Y(n530) );
  NAND2X0_RVT U647 ( .A1(n530), .A2(zone_cycles[53]), .Y(n529) );
  INVX0_RVT U648 ( .A(n529), .Y(n532) );
  NAND2X0_RVT U649 ( .A1(n532), .A2(zone_cycles[54]), .Y(n531) );
  INVX0_RVT U650 ( .A(n531), .Y(n534) );
  NAND2X0_RVT U651 ( .A1(n534), .A2(zone_cycles[55]), .Y(n533) );
  INVX0_RVT U652 ( .A(n533), .Y(n536) );
  NAND2X0_RVT U653 ( .A1(n536), .A2(zone_cycles[56]), .Y(n535) );
  INVX0_RVT U654 ( .A(n535), .Y(n538) );
  NAND2X0_RVT U655 ( .A1(n538), .A2(zone_cycles[57]), .Y(n537) );
  INVX0_RVT U656 ( .A(n537), .Y(n540) );
  NAND2X0_RVT U657 ( .A1(n540), .A2(zone_cycles[58]), .Y(n539) );
  INVX0_RVT U658 ( .A(n539), .Y(n542) );
  NAND2X0_RVT U659 ( .A1(n542), .A2(zone_cycles[59]), .Y(n541) );
  INVX0_RVT U660 ( .A(n541), .Y(n544) );
  NAND2X0_RVT U661 ( .A1(n544), .A2(zone_cycles[60]), .Y(n543) );
  INVX0_RVT U662 ( .A(n543), .Y(n546) );
  NAND2X0_RVT U663 ( .A1(n546), .A2(zone_cycles[61]), .Y(n545) );
  INVX0_RVT U664 ( .A(n545), .Y(n548) );
  NAND2X0_RVT U665 ( .A1(n548), .A2(zone_cycles[62]), .Y(n547) );
  INVX0_RVT U666 ( .A(n547), .Y(n520) );
  HADDX1_RVT U667 ( .A0(n520), .B0(zone_cycles[63]), .SO(n157) );
  NAND2X0_RVT U668 ( .A1(grant_ack[3]), .A2(zone_cycles[48]), .Y(n521) );
  OA21X1_RVT U669 ( .A1(grant_ack[3]), .A2(zone_cycles[48]), .A3(n521), .Y(
        n156) );
  INVX0_RVT U670 ( .A(n521), .Y(n522) );
  NAND3X0_RVT U671 ( .A1(grant_ack[3]), .A2(zone_cycles[49]), .A3(
        zone_cycles[48]), .Y(n523) );
  OA21X1_RVT U672 ( .A1(zone_cycles[49]), .A2(n522), .A3(n523), .Y(n155) );
  INVX0_RVT U673 ( .A(n523), .Y(n524) );
  HADDX1_RVT U674 ( .A0(zone_cycles[50]), .B0(n524), .SO(n154) );
  OA21X1_RVT U675 ( .A1(n526), .A2(zone_cycles[51]), .A3(n525), .Y(n153) );
  OA21X1_RVT U676 ( .A1(zone_cycles[52]), .A2(n528), .A3(n527), .Y(n152) );
  OA21X1_RVT U677 ( .A1(n530), .A2(zone_cycles[53]), .A3(n529), .Y(n151) );
  OA21X1_RVT U678 ( .A1(n532), .A2(zone_cycles[54]), .A3(n531), .Y(n150) );
  OA21X1_RVT U679 ( .A1(n534), .A2(zone_cycles[55]), .A3(n533), .Y(n149) );
  OA21X1_RVT U680 ( .A1(n536), .A2(zone_cycles[56]), .A3(n535), .Y(n148) );
  OA21X1_RVT U681 ( .A1(n538), .A2(zone_cycles[57]), .A3(n537), .Y(n147) );
  OA21X1_RVT U682 ( .A1(n540), .A2(zone_cycles[58]), .A3(n539), .Y(n146) );
  OA21X1_RVT U683 ( .A1(n542), .A2(zone_cycles[59]), .A3(n541), .Y(n145) );
  OA21X1_RVT U684 ( .A1(n544), .A2(zone_cycles[60]), .A3(n543), .Y(n144) );
  OA21X1_RVT U685 ( .A1(n546), .A2(zone_cycles[61]), .A3(n545), .Y(n143) );
  OA21X1_RVT U686 ( .A1(n548), .A2(zone_cycles[62]), .A3(n547), .Y(n142) );
  OA221X1_RVT U687 ( .A1(status[1]), .A2(status[0]), .A3(status[1]), .A4(n550), 
        .A5(n549), .Y(n557) );
  AO22X1_RVT U688 ( .A1(valve_open[0]), .A2(n557), .A3(n551), .A4(n563), .Y(
        n141) );
  AND2X1_RVT U689 ( .A1(n553), .A2(n552), .Y(n554) );
  AO22X1_RVT U690 ( .A1(valve_open[1]), .A2(n557), .A3(n554), .A4(n563), .Y(
        n140) );
  AO21X1_RVT U691 ( .A1(n557), .A2(valve_open[2]), .A3(n555), .Y(n139) );
  AO22X1_RVT U692 ( .A1(valve_open[3]), .A2(n557), .A3(n556), .A4(n563), .Y(
        n138) );
endmodule

