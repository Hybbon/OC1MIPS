/**
 * Testbench 0 - ALU
 * Esse testbench básico realiza testes aritméticos, realizando várias adições.
 * Sua função principal é garantir que o esqueleto dos testbenches esteja fun-
 * cionando corretamente, assim como testar instruções básicas da ALU, necessá-
 * rias para o bom funcionamento de qualquer outro programa. São monitorados os
 * sinais de entrada da ALU, do opcode e da saída desse módulo
 */
module Mips_TB;
    reg clock, reset;

    /////////
    // RAM //
    /////////
    
    wire [17:0] addr;
    wire [15:0] data;
    wire wre;
    wire oute;
    wire hb_mask;
    wire lb_mask;
    wire chip_en;

    Ram ram_i (
        .addr(addr),
        .data(data),
        .wre(wre),
        .oute(oute),
        .hb_mask(hb_mask),
        .lb_mask(lb_mask),
        .chip_en(chip_en)
    );

    //////////
    // MIPS //
    //////////

    Mips mips_i (
        .clock(clock),
        .reset(reset),
        //RAM
        .addr(addr),
        .data(data),
        .wre(wre),
        .oute(oute),
        .hb_mask(hb_mask),
        .lb_mask(lb_mask),
        .chip_en(chip_en)
    );

    initial begin
        $readmemh("tb0_arith_basic_split.hex", ram_i.memory);

        $dumpfile("mips_tb0.vcd");
        $dumpvars;

        $display("\t\tA\tB\tOut\tAluOP");
        $monitor("\t%d%d%d\t%d", mips_i.execute_i.id_ex_rega, mips_i.execute_i.mux_imregb, mips_i.execute_i.aluout, mips_i.execute_i.id_ex_aluop);

        #500 $finish;
    end

    initial begin
        clock <= 0;
        reset <= 1;
        #2 reset <= 0;
        #2 reset <= 1;
    end

    always begin
        #3 clock <= ~clock;
    end

endmodule