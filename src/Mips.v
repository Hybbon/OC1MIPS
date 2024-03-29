module Mips (
    input clock,
    input reset,
    //RAM
    output [17:0] addr,
    inout [15:0] data,
    output wre,
    output oute,
    output hb_mask,
    output lb_mask,
    output chip_en
);

    assign oute = 1'b0;
    assign hb_mask = 1'b0;
    assign lb_mask = 1'b0;
    assign chip_en = 1'b0;

    /////////////////
    // Clock lento //
    /////////////////
    
    reg half_clock;
    always @(negedge reset) begin
        // É importante lidar com o reset do clock lento, visto que ele
        // pode causar dessincronia.
        half_clock <= 0;
    end

    always @(posedge clock) begin
        half_clock <= ~half_clock;
    end



    ////////////
    // WIRING //
    ////////////

    ///////////
    // Fetch //
    ///////////
    
    // Usado em Execute
    wire ex_if_stall;
    // Usado em Decode
    wire [31:0] if_id_nextpc;
    wire [31:0] if_id_instruc;
    wire id_if_selpcsource;
    wire [31:0] id_if_rega;
    wire [31:0] id_if_pcimd2ext;
    wire [31:0] id_if_pcindex;
    wire [1:0] id_if_selpctype;
    // Usado em Memory Controller
    wire if_mc_en;
    wire [17:0] if_mc_addr;
    wire [31:0] mc_if_data;

    ////////////
    // Decode //
    ////////////
    
    // Usado em Execute
    wire id_ex_selalushift;
    wire id_ex_selimregb;
    wire [2:0] id_ex_aluop;
    wire id_ex_unsig;
    wire [1:0] id_ex_shiftop;
    wire [4:0] id_ex_shiftamt;
    wire [31:0] id_ex_rega;
    wire id_ex_readmem;
    wire id_ex_writemem;
    wire [31:0] id_ex_regb;
    wire [31:0] id_ex_imedext;
    wire id_ex_selwsource;
    wire [4:0] id_ex_regdest;
    wire id_ex_writereg;
    wire id_ex_writeov;
    // Usado em Registers
    wire [4:0] id_reg_addra;
    wire [4:0] id_reg_addrb;
    wire [31:0] reg_id_dataa;
    wire [31:0] reg_id_datab;
    wire [31:0] reg_id_ass_dataa;
    wire [31:0] reg_id_ass_datab;

    /////////////
    // Execute //
    /////////////
    
    // Usado em Memory
    wire ex_mem_readmem;
    wire ex_mem_writemem;
    wire [31:0] ex_mem_regb;
    wire ex_mem_selwsource;
    wire [4:0] ex_mem_regdest;
    wire ex_mem_writereg;
    wire [31:0] ex_mem_wbvalue;

    ////////////
    // Memory //
    ////////////
    
    // Usado em Memory Controller
    wire mem_mc_rw;
    wire mem_mc_en;
    wire [17:0] mem_mc_addr;
    wire [31:0] mem_mc_data;
    // Usado em Writeback
    wire [4:0] mem_wb_regdest;
    wire mem_wb_writereg;
    wire [31:0] mem_wb_wbvalue;

    ///////////////
    // Writeback //
    ///////////////
    
    // Usado em Registers
    wire wb_reg_en;
    wire [4:0] wb_reg_addr;
    wire [31:0] wb_reg_data;

    ////////////////
    // INSTÂNCIAS //
    ////////////////

    ///////////////
    // Registers //
    ///////////////
    
    Registers registers_i (
        .clock(half_clock),
        .reset(reset),
        .addra(id_reg_addra),
        .dataa(reg_id_dataa),
        .ass_dataa(reg_id_ass_dataa),
        .addrb(id_reg_addrb),
        .datab(reg_id_datab),
        .ass_datab(reg_id_ass_datab),
        .enc(wb_reg_en),
        .addrc(wb_reg_addr),
        .datac(wb_reg_data)
    );

    ///////////////////
    // MemController //
    ///////////////////
    
    MemController memcontroller_i (
        .clock(clock),
        .reset(reset),
        //Fetch
        .if_mc_en(if_mc_en),
        .if_mc_addr(if_mc_addr),
        .mc_if_data(mc_if_data),
        //Memory
        .mem_mc_rw(mem_mc_rw),
        .mem_mc_en(mem_mc_en),
        .mem_mc_addr(mem_mc_addr),
        .mem_mc_data(mem_mc_data),
        //Ram
        .mc_ram_addr(addr),
        .mc_ram_wre(wre),
        .mc_ram_data(data)
    );

    /////////////////////
    // PIPELINE STAGES //
    /////////////////////

    ///////////
    // Fetch //
    ///////////

    Fetch fetch_i (
        .clock(half_clock),
        .reset(reset),
        //Execute
        .ex_if_stall(ex_if_stall),
        //Decode
        .if_id_nextpc(if_id_nextpc),
        .if_id_instruc(if_id_instruc),
        .id_if_selpcsource(id_if_selpcsource),
        .id_if_rega(id_if_rega),
        .id_if_pcimd2ext(id_if_pcimd2ext),
        .id_if_pcindex(id_if_pcindex),
        .id_if_selpctype(id_if_selpctype),
        //Memory Controller
        .if_mc_en(if_mc_en),
        .if_mc_addr(if_mc_addr),
        .mc_if_data(mc_if_data)
    );

    ////////////
    // Decode //
    ////////////

    Decode decode_i (
        .clock(half_clock),
        .reset(reset),
        //Fetch
        .if_id_instruc(if_id_instruc),
        .if_id_nextpc(if_id_nextpc),
        .id_if_selpcsource(id_if_selpcsource),
        .id_if_rega(id_if_rega),
        .id_if_pcimd2ext(id_if_pcimd2ext),
        .id_if_pcindex(id_if_pcindex),
        .id_if_selpctype(id_if_selpctype),
        //Execute
        .id_ex_selalushift(id_ex_selalushift),
        .id_ex_selimregb(id_ex_selimregb),
        .id_ex_aluop(id_ex_aluop),
        .id_ex_unsig(id_ex_unsig),
        .id_ex_shiftop(id_ex_shiftop),
        .id_ex_shiftamt(id_ex_shiftamt),
        .id_ex_rega(id_ex_rega),
        .id_ex_readmem(id_ex_readmem),
        .id_ex_writemem(id_ex_writemem),
        .id_ex_regb(id_ex_regb),
        .id_ex_imedext(id_ex_imedext),
        .id_ex_selwsource(id_ex_selwsource),
        .id_ex_regdest(id_ex_regdest),
        .id_ex_writereg(id_ex_writereg),
        .id_ex_writeov(id_ex_writeov),
        //Registers
        .id_reg_addra(id_reg_addra),
        .id_reg_addrb(id_reg_addrb),
        .reg_id_dataa(reg_id_dataa),
        .reg_id_datab(reg_id_datab),
        .reg_id_ass_dataa(reg_id_ass_dataa),
        .reg_id_ass_datab(reg_id_ass_datab)
    );


    /////////////
    // Execute //
    /////////////

    Execute execute_i(
        .clock(half_clock),
        .reset(reset),
        //Decode
        .id_ex_selalushift(id_ex_selalushift),
        .id_ex_selimregb(id_ex_selimregb),
        .id_ex_aluop(id_ex_aluop),
        .id_ex_unsig(id_ex_unsig),
        .id_ex_shiftop(id_ex_shiftop),
        .id_ex_shiftamt(id_ex_shiftamt),
        .id_ex_rega(id_ex_rega),
        .id_ex_readmem(id_ex_readmem),
        .id_ex_writemem(id_ex_writemem),
        .id_ex_regb(id_ex_regb),
        .id_ex_imedext(id_ex_imedext),
        .id_ex_selwsource(id_ex_selwsource),
        .id_ex_regdest(id_ex_regdest),
        .id_ex_writereg(id_ex_writereg),
        .id_ex_writeov(id_ex_writeov),
        //Fetch
        .ex_if_stall(ex_if_stall),
        //Memory
        .ex_mem_readmem(ex_mem_readmem),
        .ex_mem_writemem(ex_mem_writemem),
        .ex_mem_regb(ex_mem_regb),
        .ex_mem_selwsource(ex_mem_selwsource),
        .ex_mem_regdest(ex_mem_regdest),
        .ex_mem_writereg(ex_mem_writereg),
        .ex_mem_wbvalue(ex_mem_wbvalue)
    );


    ////////////
    // Memory //
    ////////////

    Memory memory_i (
        .clock(half_clock),
        .reset(reset),
        //Execute
        .ex_mem_readmem(ex_mem_readmem),
        .ex_mem_writemem(ex_mem_writemem),
        .ex_mem_regb(ex_mem_regb),
        .ex_mem_selwsource(ex_mem_selwsource),
        .ex_mem_regdest(ex_mem_regdest),
        .ex_mem_writereg(ex_mem_writereg),
        .ex_mem_wbvalue(ex_mem_wbvalue),
        //Memory Controller
        .mem_mc_rw(mem_mc_rw),
        .mem_mc_en(mem_mc_en),
        .mem_mc_addr(mem_mc_addr),
        .mem_mc_data(mem_mc_data),
        //Writeback
        .mem_wb_regdest(mem_wb_regdest),
        .mem_wb_writereg(mem_wb_writereg),
        .mem_wb_wbvalue(mem_wb_wbvalue)
    );

    ///////////////
    // Writeback //
    ///////////////
    Writeback writeback_i (
        //Memory
        .mem_wb_regdest(mem_wb_regdest),
        .mem_wb_writereg(mem_wb_writereg),
        .mem_wb_wbvalue(mem_wb_wbvalue),
        //Registers
        .wb_reg_en(wb_reg_en),
        .wb_reg_addr(wb_reg_addr),
        .wb_reg_data(wb_reg_data)
    );
endmodule