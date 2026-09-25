//======================================================================
// Smart Water Distribution Scheduler : water_sched
// ChipCraft 3.0 | Team LOGIC DUO | Govt. College of Engineering, Srirangam
//----------------------------------------------------------------------
// FUNCTION (simple words):
//   Several city zones press "NEED WATER". We have ONE water line, so
//   only ONE zone valve may open at a time. This controller:
//     1) remembers every zone's demand request        (demand tracking)
//     2) picks who is served first by priority        (priority arbiter)
//     3) opens only one valve at a time               (one-hot, conflict-free)
//     4) lets EMERGENCY zones (prio=3) jump the queue (emergency support)
//     5) counts every finished distribution cycle    (cycle counters)
//     6) flags "NOT ENOUGH WATER" and waits/skips     (insufficient supply)
//        NOTE: insufficient is a LIVE status = "some zone wants water but
//        cannot be served right now". It stays high until the shortage ends.
//
// POLICY NOTES (be ready to explain these in the review):
//   - Serve order: among zones that CAN be served now (enough supply),
//     highest priority wins. Tie -> lowest zone index wins.
//   - TWO OPERATING MODES (parameter STRICT_PRIO):
//     * STRICT_PRIO = 0 (default, "skip-to-fit" / work-conserving):
//       if the best zone has demand > available water, we do NOT starve
//       others: any lower zone that FITS is served first. If nobody fits,
//       we enter WAIT state and raise the insufficient flag.
//     * STRICT_PRIO = 1 (strict priority): a stuck higher-priority zone
//       BLOCKS all lower zones until supply suffices (jury option).
//   - In BOTH modes a zone's request is never dropped: the moment it fits,
//     the highest-priority stuck zone is served FIRST (next arbitration).
//   - A started serve always finishes (valve safety: no mid-flush abort).
//     Emergency zones are first in the NEXT arbitration.
//   - Zone keeps its request high until it sees grant_ack (done pulse).
//======================================================================
`timescale 1ns/1ps   // for simulation only; synthesis tools ignore this

module water_sched #(
    parameter integer NZONES       = 4,   // number of city zones
    parameter integer DATA_W       = 8,   // width of water-unit values
    parameter integer SERVE_CYCLES = 16,  // valve-open clocks per distribution
    parameter integer STRICT_PRIO  = 0    // POLICY MODE (answer to the jury question):
                                          //  0 = skip-to-fit (work-conserving):
                                          //      serve zones that FIT while a bigger
                                          //      request waits for supply (default)
                                          //  1 = strict priority:
                                          //      a stuck higher-priority zone BLOCKS
                                          //      all lower zones until it can be served
)(
    input  wire                     clk,
    input  wire                     rst_n,        // async reset, active low

    // -------- zones (demand side) --------
    input  wire [NZONES-1:0]        zone_req,     // zone needs water
    input  wire [2*NZONES-1:0]      zone_prio,    // 2 bit/zone: 0 low .. 3 EMERG
    input  wire [NZONES*DATA_W-1:0] zone_demand,  // water units wanted per zone

    // -------- plant (supply side) --------
    input  wire [DATA_W-1:0]        supply_avail, // water units ready now
    input  wire                     supply_valid, // pump running / supply on

    // -------- valves (one-hot => never conflicting) --------
    output wire [NZONES-1:0]        valve_open,   // one-hot valve commands
    output wire [NZONES-1:0]        grant_ack,    // 1-clk pulse: serve finished

    // -------- status / monitoring --------
    output reg  [31:0]              cycles_done,  // completed cycles (total)
    output reg  [NZONES*16-1:0]     zone_cycles,  // completed cycles per zone
    output reg                      insufficient, // 1 = want water but not enough
    output wire                     busy,         // distribution in progress
    output wire [2:0]               status        // 0 IDLE,1 SERVE,2 WAIT,3 DONE
);

    //------------------------------------------------------------------
    // state encoding
    //------------------------------------------------------------------
    localparam [2:0] ST_IDLE = 3'd0,   // nothing to do
                     ST_SERVE= 3'd1,   // valve open, water flowing
                     ST_WAIT = 3'd2,   // requests exist but supply insufficient
                     ST_DONE = 3'd3;   // one-clock bookkeeping (count + ack)

    reg  [2:0]        state;
    reg  [NZONES-1:0] valve_r;         // registered one-hot valve command
    reg  [NZONES-1:0] win_r;           // one-hot winner being served
    reg  [15:0]       timer;           // serve countdown

    localparam [15:0] SERVE_TIME = SERVE_CYCLES;  // sized copy of the parameter

    //------------------------------------------------------------------
    // NOTE: packed buses are sliced directly in the loops below with
    //   zone_demand[i*DATA_W +: DATA_W]   and   zone_prio[i*2 +: 2]
    //------------------------------------------------------------------

    //------------------------------------------------------------------
    // combinational arbitration
    //   pick   : one-hot winner among zones that CAN be served right now
    //   unserved_exists : some zone wants water but cannot be served
    //------------------------------------------------------------------
    reg  [NZONES-1:0]   pick;
    reg                 found;
    reg  [1:0]          best_rank;
    reg                 unserved_exists;
    reg  [1:0]          max_stuck_rank;  // worst priority among stuck zones
    reg                 blocked;         // STRICT_PRIO block decision (temp)

    integer i;   // loop var for COMBINATIONAL block only
    integer j;   // loop var for SEQUENTIAL block only (never share loop vars!)
    always @(*) begin
        pick            = {NZONES{1'b0}};
        found           = 1'b0;
        best_rank       = 2'd0;
        unserved_exists = 1'b0;
        max_stuck_rank  = 2'd0;

        // pass 1: who is stuck (wants water but cannot be served)? record
        //         the HIGHEST priority among them
        for (i = 0; i < NZONES; i = i + 1) begin
            if (zone_req[i] && !(supply_valid &&
                (zone_demand[i*DATA_W +: DATA_W] <= supply_avail))) begin
                unserved_exists = 1'b1;
                if (zone_prio[i*2 +: 2] > max_stuck_rank)
                    max_stuck_rank = zone_prio[i*2 +: 2];
            end
        end

        // pass 2: pick the winner among servable zones
        for (i = 0; i < NZONES; i = i + 1) begin
            // STRICT_PRIO=1: never let a lower-priority zone pass a stuck
            // higher-priority zone (the jury's requirement)
            blocked = STRICT_PRIO && unserved_exists &&
                      (max_stuck_rank > zone_prio[i*2 +: 2]);
            // can zone i be served this instant?
            if (zone_req[i] && supply_valid &&
                (zone_demand[i*DATA_W +: DATA_W] <= supply_avail) && !blocked) begin
                // strict '>' keeps lowest index on priority ties
                if (!found || (zone_prio[i*2 +: 2] > best_rank)) begin
                    found     = 1'b1;
                    best_rank = zone_prio[i*2 +: 2];
                    pick      = {{(NZONES-1){1'b0}}, 1'b1} << i;
                end
            end
        end
    end

    //------------------------------------------------------------------
    // sequential FSM + counters
    //------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= ST_IDLE;
            valve_r      <= {NZONES{1'b0}};
            win_r        <= {NZONES{1'b0}};
            timer        <= 16'd0;
            cycles_done  <= 32'd0;
            zone_cycles  <= {(NZONES*16){1'b0}};
            insufficient <= 1'b0;
        end else begin
            // LIVE shortage status: 1 whenever some zone cannot be served now
            insufficient <= unserved_exists;

            case (state)

                ST_IDLE: begin
                    valve_r <= {NZONES{1'b0}};
                    if (found) begin                 // someone fits -> serve
                        win_r        <= pick;
                        valve_r      <= pick;
                        timer        <= SERVE_TIME;
                        state        <= ST_SERVE;
                    end else if (unserved_exists) begin // wants water, can't
                        state        <= ST_WAIT;
                    end else begin                   // quiet city
                        state        <= ST_IDLE;
                    end
                end

                ST_SERVE: begin                      // valve open, count down
                    if (timer <= 16'd1) begin
                        timer   <= 16'd0;
                        valve_r <= {NZONES{1'b0}};   // close valve
                        state   <= ST_DONE;
                    end else begin
                        timer <= timer - 16'd1;
                    end
                end

                ST_DONE: begin                       // 1 clock: count + ack
                    cycles_done <= cycles_done + 32'd1;
                    for (j = 0; j < NZONES; j = j + 1) begin
                        if (win_r[j])
                            zone_cycles[j*16 +: 16] <= zone_cycles[j*16 +: 16] + 16'd1;
                    end
                    state <= ST_IDLE;
                end

                ST_WAIT: begin                       // supply insufficient
                    if (found) begin                 // water arrived
                        win_r        <= pick;
                        valve_r      <= pick;
                        timer        <= SERVE_TIME;
                        state        <= ST_SERVE;
                    end else if (!unserved_exists) begin // requests gone
                        state        <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;

            endcase
        end
    end

    //------------------------------------------------------------------
    // outputs
    //------------------------------------------------------------------
    assign valve_open = valve_r;                       // one-hot by construction
    assign grant_ack  = (state == ST_DONE) ? win_r : {NZONES{1'b0}}; // 1-clk pulse
    assign busy       = (state == ST_SERVE);
    assign status     = state;                         // 0/1/2/3 = IDLE/SERVE/WAIT/DONE

endmodule
