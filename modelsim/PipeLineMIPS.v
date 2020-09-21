`timescale 1ns/1ns
module PipeLineMIPS(input clk, rst);
    wire IF_IDWrite, PCWrite, NOPS, instClear, id_exMemReadOut, ex_memMemReadOut, id_exRegWriteOut,
         id_exALUSrcOut, ex_memRegWriteOut, mem_wbRegWriteOut, areEqual, Branch;
    wire [1:0] EqCS1, EqCS2, ALUAS, ALUBS, PCSrc;
    wire [4:0] Rs, Rt, id_exRtOut, id_exRdMuxOut, ex_memRdOut, id_exRsOut, mem_wbRdOut;
    wire [8:0] controllerSignals;
    wire [31:0] InstOutController, InstInController;

    PipeLineMIPSDP datapath(IF_IDWrite, PCWrite, NOPS, instClear, EqCS1, EqCS2, ALUAS, ALUBS, PCSrc,
                          controllerSignals, rst, clk, Rs, Rt, id_exRtOut, id_exRdMuxOut, ex_memRdOut,
                          id_exRsOut, mem_wbRdOut, id_exMemReadOut, ex_memMemReadOut, id_exRegWriteOut,
                          id_exALUSrcOut, ex_memRegWriteOut, mem_wbRegWriteOut, areEqual, InstOutController);
                          
    MIPS_Controller controller(InstInController, areEqual, PCSrc, controllerSignals, Branch, instClear);
    
    forwarding forwarding_unit(Rs, Rt, id_exRtOut, ex_memRdOut, id_exRsOut, mem_wbRdOut,
                      ex_memRegWriteOut, mem_wbRegWriteOut, EqCS1, EqCS2, ALUAS, ALUBS);
                      
    hazard hazard_unit(Rs, Rt, id_exRdMuxOut, ex_memRdOut, id_exMemReadOut, id_exRegWriteOut,
                  ex_memMemReadOut, ex_memRegWriteOut, Branch, NOPS, IF_IDWrite, PCWrite);
                  
    assign InstInController = InstOutController;
  endmodule
  
module PipeLineMIPS_tb();
  reg clk,rst;
  PipeLineMIPS test(clk,rst);
  initial begin
    clk = 0 ;
    rst = 1;
    #2
    rst = 0;
  end
  always begin
    #1 clk = ~clk;
  end
  always begin : loop_block
    if (1) begin
      #2
      $display ("pc is : %b",PipeLineMIPS_tb.test.datapath.pc);
      $display ("opc is : %b",PipeLineMIPS_tb.test.datapath.instOut[31:26]);
      $display ("func is : %b",PipeLineMIPS_tb.test.datapath.instOut[5:0]);
      $display ("Inst is : %b",PipeLineMIPS_tb.test.datapath.instOut);
      
      $display ("R1 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[1]);
      $display ("R2 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[2]);
      $display ("R3 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[3]);
      $display ("R4 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[4]);
      $display ("R5 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[5]);
      $display ("R6 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[6]);
      $display ("R7 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[7]);
      $display ("R8 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[8]);
      $display ("R9 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[9]);
      $display ("R10 is : %b",PipeLineMIPS_tb.test.datapath.regfile.R[10]);
      
      $display ("mem[2000] is : %b",{PipeLineMIPS_tb.test.datapath.datamem.Mem[2000]});
                                     //PipeLineMIPS_tb.test.datapath.datamem.Mem[2001],
                                     //PipeLineMIPS_tb.test.datapath.datamem.Mem[2002],
                                     //PipeLineMIPS_tb.test.datapath.datamem.Mem[2003]});
                                     
      $display ("mem[2004] is : %b",{PipeLineMIPS_tb.test.datapath.datamem.Mem[2004]});
                                     //PipeLineMIPS_tb.test.datapath.datamem.Mem[2005],
                                     //PipeLineMIPS_tb.test.datapath.datamem.Mem[2006],
                                     //PipeLineMIPS_tb.test.datapath.datamem.Mem[2007]});
    end
  end
endmodule