//======================================================================
// Self-checking Testbench : tb_water_sched
// ChipCraft 3.0 | Team LOGIC DUO
//----------------------------------------------------------------------
// What it checks:
//   T1  reset values
//   T2  single zone serve (valve one-hot, serve length, cycle count)
//   T3  priority order (high served before low)
//   T4  emergency zone jumps the queue
//   T5  insufficient supply -> flag + wait, then serve after refill
//   T6  skip-to-fit (big emergency waits, small zone goes first)
//   T7  randomized soak + one-hot monitor + counter cross-check
//   PLUS: continuous one-hot valve monitor (conflict detector)
//======================================================================
`timescale 1ns/1ps

module tb_water_sched;

    localparam NZ  = 4;   // zones
    localparam DW  = 8;
    localparam SC  = 4;   // short serve time for simulation

    // ---------------- clock / reset ----------------
    reg clk = 1'b0;
    reg rst_n;
    always #5 clk = ~clk;          // 100 MHz

    // ---------------- DUT buses (unpacked for easy tests) -------------
    reg  [1:0] p0, p1, p2, p3;     // priorities (3 = EMERGENCY)
    reg  [7:0] d0, d1, d2, d3;     // demands (water units)
    reg        r0, r1, r2, r3;     // requests
    reg  [7:0] supply_avail;
    reg        supply_valid;

    wire [NZ-1:0]    zone_req    = {r3, r2, r1, r0};
    wire [2*NZ-1:0]  zone_prio   = {p3, p2, p1, p0};
    wire [NZ*DW-1:0] zone_demand = {d3, d2, d1, d0};

    wire [NZ-1:0] valve_open, grant_ack;
    wire [31:0]   cycles_done;
    wire [NZ*16-1:0] zone_cycles;
    wire          insufficient, busy;
    wire [2:0]    status;

    water_sched #(.NZONES(NZ), .DATA_W(DW), .SERVE_CYCLES(SC)) dut (
        .clk(clk), .rst_n(rst_n),
        .zone_req(zone_req), .zone_prio(zone_prio), .zone_demand(zone_demand),
        .supply_avail(supply_avail), .supply_valid(supply_valid),
        .valve_open(valve_open), .grant_ack(grant_ack),
        .cycles_done(cycles_done), .zone_cycles(zone_cycles),
        .insufficient(insufficient), .busy(busy), .status(status)
    );

    // ---------------- bookkeeping ----------------
    integer errors = 0;
    integer k;

    task check(input ok, input [64*8-1:0] msg);
        begin
            if (ok)      $display("  [PASS] %0s", msg);
            else begin
                errors = errors + 1;
                $display("  [FAIL] %0s  (t=%0t)", msg, $time);
            end
        end
    endtask

    task step;  // one clock + settle
        begin @(posedge clk); #1; end
    endtask

    // wait for ack of zone idx (wrong winner = priority failure), drop its
    // request, then one extra clock so the DONE state updates the counters
    task serve_and_clear(input integer idx, input integer timeout);
        integer k2; reg got;
        begin
            k2 = 0; got = 1'b0;
            while (!got && k2 < timeout) begin
                step;
                if ((grant_ack !== {NZ{1'b0}}) && (grant_ack[idx] !== 1'b1))
                    check(1'b0, "UNEXPECTED zone served (priority order broken)");
                if (grant_ack[idx]) got = 1'b1;
                k2 = k2 + 1;
            end
            if (!got) check(1'b0, "ACK timeout");
            case (idx)
                0: r0 = 1'b0; 1: r1 = 1'b0; 2: r2 = 1'b0; default: r3 = 1'b0;
            endcase
            step;   // let ST_DONE finish -> counters are updated now
        end
    endtask

    // ---------------- continuous one-hot monitor ----------------
    integer onehot_bad = 0;
    integer bitcount;
    always @(posedge clk) begin
        #1;
        if (rst_n) begin
            bitcount = valve_open[0] + valve_open[1] + valve_open[2] + valve_open[3];
            if (bitcount > 1) begin
                onehot_bad = onehot_bad + 1;
                $display("  [FAIL] CONFLICT! multiple valves open: %b (t=%0t)", valve_open, $time);
            end
        end
    end

    // ---------------- optional waveform dump ----------------
    initial begin
        if ($test$plusargs("dump")) begin
            $dumpfile("water_sched.vcd");
            $dumpvars(0, tb_water_sched);
        end
    end

    // watchdog
    initial begin
        #500000;
        $display("TESTS FAILED: watchdog timeout!");
        $finish;
    end

    integer open_cnt, ack_count_start;
    integer i2;
    integer base;
    integer ks;
    reg     gotz;

    // -------- second DUT: STRICT_PRIO mode (T13) --------
    reg        rs0, rs1;
    reg  [1:0] ps0, ps1;
    reg  [7:0] ds0, ds1;
    reg  [7:0] ss;                 // strict instance: supply units
    reg        ssv;                // strict instance: pump
    wire [1:0] sv, sa;             // valve_open / grant_ack (2 zones)
    wire [31:0] scd;               // cycles_done
    wire [31:0] szc;               // zone_cycles (2 x 16)
    wire        si, sbusy;
    wire [2:0]  sstatus;

    water_sched #(.NZONES(2), .DATA_W(8), .SERVE_CYCLES(2), .STRICT_PRIO(1)) dut_strict (
        .clk(clk), .rst_n(rst_n),
        .zone_req({rs1, rs0}), .zone_prio({ps1, ps0}), .zone_demand({ds1, ds0}),
        .supply_avail(ss), .supply_valid(ssv),
        .valve_open(sv), .grant_ack(sa),
        .cycles_done(scd), .zone_cycles(szc),
        .insufficient(si), .busy(sbusy), .status(sstatus)
    );

    initial begin
        $display("=====================================================");
        $display(" water_sched self-checking TB  (Team LOGIC DUO)");
        $display("=====================================================");

        // init inputs
        rst_n = 1'b0;
        {r3, r2, r1, r0} = 4'b0;
        p0 = 2'd0; p1 = 2'd1; p2 = 2'd2; p3 = 2'd3;  // z3 = EMERGENCY
        d0 = 8'd50;  d1 = 8'd50;  d2 = 8'd50;  d3 = 8'd50;
        supply_avail = 8'd250;
        supply_valid = 1'b1;
        rs0 = 1'b0; rs1 = 1'b0; ps0 = 2'd0; ps1 = 2'd0;
        ds0 = 8'd0;  ds1 = 8'd0;  ss = 8'd0;   ssv = 1'b0;

        //---------------- T1 : reset ----------------
        $display("\nT1: reset values");
        repeat (3) step;
        rst_n = 1'b1;
        step;
        check(valve_open   === 4'b0000, "valves closed after reset");
        check(cycles_done  === 32'd0,   "cycle counter is 0 after reset");
        check(insufficient === 1'b0,    "insufficient flag clear");
        check(status       === 3'd0,    "status = IDLE");

        //---------------- T2 : single zone ----------------
        $display("\nT2: single zone (zone1) serve");
        r1 = 1'b1;
        open_cnt = 0;
        for (k = 0; k < 60; k = k + 1) begin
            step;
            if (valve_open[1]) open_cnt = open_cnt + 1;
            if (grant_ack[1])  r1 = 1'b0;          // zone model: drop request
            if (valve_open[0] | valve_open[2] | valve_open[3])
                check(1'b0, "wrong valve opened for zone1");
        end
        check(open_cnt    == SC,      "valve1 open exactly SERVE_CYCLES clocks");
        check(cycles_done == 32'd1,   "cycles_done = 1 after one serve");
        check(zone_cycles[1*16 +: 16] == 16'd1, "zone1 cycle counter = 1");

        //---------------- T3 : priority order ----------------
        $display("\nT3: priority order (z2 high > z1 med > z0 low)");
        r0 = 1'b1; r1 = 1'b1; r2 = 1'b1;          // all three want water
        serve_and_clear(2, 200);                   // expect z2 ack first
        serve_and_clear(1, 200);                   // then z1
        serve_and_clear(0, 200);                   // then z0
        check(cycles_done == 32'd4, "3 more cycles done -> total 4");

        //---------------- T4 : emergency jumps queue ----------------
        $display("\nT4: emergency (z3) beats high (z2)");
        r2 = 1'b1; r3 = 1'b1;
        serve_and_clear(3, 200);                   // emergency FIRST
        serve_and_clear(2, 200);
        check(cycles_done == 32'd6, "emergency first, then z2 -> total 6");

        //---------------- T5 : insufficient supply ----------------
        $display("\nT5: insufficient supply handling");
        d2 = 8'd200;                               // z2 needs 200
        supply_avail = 8'd50;                      // only 50 available
        r2 = 1'b1;
        repeat (6) step;
        check(insufficient === 1'b1, "insufficient flag raised");
        check(status       === 3'd2, "status = WAIT_SUPPLY");
        check(valve_open   === 4'b0, "no valve opened while insufficient");
        supply_avail = 8'd250;                     // refill
        serve_and_clear(2, 200);
        check(insufficient === 1'b0, "insufficient flag cleared after serve");

        //---------------- T6 : skip-to-fit ----------------
        $display("\nT6: skip-to-fit (huge emergency waits, small zone goes)");
        d3 = 8'd200;  d0 = 8'd50;
        supply_avail = 8'd100;
        r3 = 1'b1; r0 = 1'b1;                      // emerg z3 too big, z0 fits
        serve_and_clear(0, 200);                   // z0 (fits) served first
        check(insufficient === 1'b1, "insufficient still set for waiting z3");
        supply_avail = 8'd250;
        serve_and_clear(3, 200);                   // now emergency goes
        d3 = 8'd50;

        //---------------- T7 : randomized soak ----------------
        $display("\nT7: randomized soak (one-hot + counter cross-check)");
        ack_count_start = cycles_done;
        for (i2 = 0; i2 < 300; i2 = i2 + 1) begin
            step;
            // randomly wiggle demand-side
            if ($random % 5 == 0) r0 = $random;
            if ($random % 5 == 0) r1 = $random;
            if ($random % 5 == 0) r2 = $random;
            if ($random % 5 == 0) r3 = $random;
            if ($random % 7 == 0) supply_valid = ~supply_valid;
            if ($random % 9 == 0) supply_avail = $random;
            if ($random % 11 == 0) begin
                // {$random} forces unsigned — plain ($random % 200) can go
                // NEGATIVE and wrap into huge 8-bit demands (classic gotcha!)
                d0 = 1 + ({$random} % 200);
                d1 = 1 + ({$random} % 200);
                d2 = 1 + ({$random} % 200);
                d3 = 1 + ({$random} % 200);
            end
            // zone model: drop request on ack
            if (grant_ack[0]) r0 = 1'b0;
            if (grant_ack[1]) r1 = 1'b0;
            if (grant_ack[2]) r2 = 1'b0;
            if (grant_ack[3]) r3 = 1'b0;
        end
        // drain
        {r3, r2, r1, r0} = 4'b0;
        supply_valid = 1'b1; supply_avail = 8'd250;
        repeat (60) step;
        check(onehot_bad == 0, "valves NEVER conflicted during soak");
        check(cycles_done == zone_cycles[0*16 +: 16] + zone_cycles[1*16 +: 16]
                           + zone_cycles[2*16 +: 16] + zone_cycles[3*16 +: 16],
              "total cycles == sum of per-zone cycles");

        //---------------- T8 : async reset mid-serve ----------------
        $display("\nT8: async reset during active serve");
        // deterministic re-init after the random soak
        p0 = 2'd0; p1 = 2'd1; p2 = 2'd2; p3 = 2'd3;
        d0 = 8'd50; d1 = 8'd50; d2 = 8'd50; d3 = 8'd50;
        supply_avail = 8'd250; supply_valid = 1'b1;
        step;
        r1 = 1'b1;
        step; step;                                  // deep into SERVE
        check(valve_open === 4'b0010, "valve1 open before reset");
        rst_n = 1'b0; #1;
        check(valve_open   === 4'b0000, "valves forced closed by reset");
        check(cycles_done  === 32'd0,   "counters cleared by reset");
        check(insufficient === 1'b0,    "insufficient cleared by reset");
        r1 = 1'b0;
        rst_n = 1'b1;
        step;
        check(status === 3'd0, "back to IDLE after reset release");

        //---------------- T9 : priority tie -> lowest index ----------------
        $display("\nT9: equal priorities -> lowest zone index wins");
        p0 = 2'd1; p1 = 2'd1; p2 = 2'd1; p3 = 2'd1;  // all equal
        base = cycles_done;
        r0 = 1'b1; r1 = 1'b1; r2 = 1'b1; r3 = 1'b1;
        serve_and_clear(0, 200);                     // tie-break: z0 first
        serve_and_clear(1, 200);
        serve_and_clear(2, 200);
        serve_and_clear(3, 200);
        check(cycles_done == base + 4, "4 zones served in index order");
        p0 = 2'd0; p1 = 2'd1; p2 = 2'd2; p3 = 2'd3;  // restore

        //---------------- T10 : pump OFF ----------------
        $display("\nT10: pump off -> WAIT + insufficient, no valve");
        base = cycles_done;
        r1 = 1'b1;
        supply_valid = 1'b0;
        repeat (5) step;
        check(insufficient === 1'b1, "insufficient when pump off");
        check(status       === 3'd2, "status WAIT when pump off");
        check(valve_open   === 4'b0, "no valve while pump off");
        supply_valid = 1'b1;
        serve_and_clear(1, 200);
        check(cycles_done == base + 1, "served after pump restart");

        //---------------- T11 : pump OFF mid-serve ----------------
        $display("\nT11: started serve always completes (valve safety)");
        base = cycles_done;
        r2 = 1'b1;
        step; step; step;
        check(valve_open === 4'b0100, "valve2 open mid-serve");
        supply_valid = 1'b0;                         // pump dies mid-flush
        serve_and_clear(2, 200);                     // must still finish!
        check(cycles_done == base + 1, "mid-flush serve completed");
        supply_valid = 1'b1;

        //---------------- T12 : all EMERGENCY + back-to-back ----------------
        $display("\nT12: all zones emergency -> still index order, back-to-back");
        p0 = 2'd3; p1 = 2'd3; p2 = 2'd3; p3 = 2'd3;
        base = cycles_done;
        r0 = 1'b1; r3 = 1'b1;
        serve_and_clear(0, 200);                     // emergency tie -> z0
        r2 = 1'b1;                                   // back-to-back new request
        serve_and_clear(2, 200);
        serve_and_clear(3, 200);
        check(cycles_done == base + 3, "3 back-to-back serves done");
        p0 = 2'd0; p1 = 2'd1; p2 = 2'd2; p3 = 2'd3;

        //---------------- T13 : STRICT_PRIO mode (jury question!) ----------
        $display("\nT13: STRICT_PRIO=1 -- stuck HIGH zone blocks lower zone");
        // dut_strict: z1 = HIGH but stuck (demand 200 > supply 100)
        //             z = LOW  and fits (demand  50 < supply 100)
        ps0 = 2'd0; ps1 = 2'd2;
        ds0 = 8'd50; ds1 = 8'd200;
        ss  = 8'd100; ssv = 1'b1;
        rs0 = 1'b1; rs1 = 1'b1;
        repeat (6) step;
        check(si       === 1'b1,  "strict: insufficient flag set");
        check(sv       === 2'b00, "strict: lower zone BLOCKED (no valve!)");
        check(sstatus  === 3'd2,  "strict: status WAIT");
        ss = 8'd250;                          // refill -> HIGH zone must win
        ks = 0; gotz = 1'b0;
        while (!gotz && ks < 100) begin
            step;
            if (sa[0]) check(1'b0, "strict: LOW zone jumped the queue!");
            if (sa[1]) begin gotz = 1'b1; rs1 = 1'b0; end
            ks = ks + 1;
        end
        check(gotz, "strict: stuck HIGH zone served FIRST after refill");
        step;
        ks = 0; gotz = 1'b0;
        while (!gotz && ks < 100) begin
            step;
            if (sa[0]) begin gotz = 1'b1; rs0 = 1'b0; end
            ks = ks + 1;
        end
        check(gotz === 1'b1, "strict: LOW zone served afterwards");
        step;                                   // let ST_DONE update counters
        check(scd  === 32'd2, "strict: exactly 2 cycles counted");

        //---------------- summary ----------------
        $display("\n=====================================================");
        if (errors == 0) $display(" ALL TESTS PASSED  (cycles_done=%0d)", cycles_done);
        else             $display(" TESTS FAILED: %0d error(s)", errors);
        $display("=====================================================");
        $finish;
    end

endmodule
