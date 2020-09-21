
module RegFile(input[4:0] ReadReg1, ReadReg2, WriteReg, input[31:0] WriteData, input clk, RegWrite, output [31:0] ReadData1, ReadData2);
  reg[31:0] R[0:31];
  reg flag;
  initial flag = 1'b0;
  initial R[0] <= 32'b0;
  always@(negedge clk)begin
    if(WriteReg != 0 && RegWrite == 1) R[WriteReg] <= WriteData;
  end
  assign ReadData1 = R[ReadReg1];
  assign ReadData2 = R[ReadReg2];
endmodule

module PCReg(input[31:0] In, input PCWrite, clk, rst, output[31:0] Out);
  reg[31:0] pc;
  always@(posedge clk, posedge rst)begin
    if(rst) pc <= 32'b0;
    else begin
      if(PCWrite) pc <= In;
    end
  end
  assign Out = pc;
endmodule

module MUX3_32(input[31:0] first, second, third, input[1:0] select, output[31:0] out);
  assign out = (select == 2'b00) ? first : (select == 2'b01) ? second :
                (select == 2'b10) ? third : 32'b0;
endmodule

module InstMem(input[31:0] Address, output[31:0] Inst);
  reg [7:0] Mem [0:64000];
  initial $readmemh("inst.data", Mem);
  assign Inst = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule

module Comprator(input[31:0] first, second, output isEqual);
  assign isEqual = (first == second) ? 1 : 0;
endmodule

module SignExt(input[15:0] in, output[31:0]out);
  assign out = { {16{in[15]}}, in};
endmodule

module Adder_32(input[31:0] A, B, output[31:0] Result);
  assign Result = A + B;
endmodule

module SHL2_32_to_32(input[31:0] in, output[31:0] out);
  assign out = {in[29:0] , 2'b00};
endmodule

module SHL2_26_to_28(input[25:0] in, output[27:0] out);
  assign out = {in,2'b00};
endmodule

module Concat4_26(input [3:0] first, input [27:0] second, output[31:0] out);
  assign out = {first,second};
endmodule

module MUX2_32(input[31:0] first, second, input select, output[31:0] out);
  assign out = (select == 1'b0) ? first : second;
endmodule

module MUX2_5(input[4:0] first, second, input select, output[4:0] out);
  assign out = (select == 1'b0) ? first : second;
endmodule

module MUX2_9(input[8:0] first, second, input select, output[8:0] out);
  assign out = (select == 1'b0) ? first : second;
endmodule

module ALU(input [31:0] A, B, input[2:0] ALUOpration, output reg[31:0] Result);
  always@(A,B,ALUOpration)begin
    if(ALUOpration == 3'b000) Result =  A & B;
    else if(ALUOpration == 3'b001) Result =  A | B;
    else if(ALUOpration == 3'b010) Result =  A + B;
    else if(ALUOpration == 3'b011) Result =  A + (~B) + 1;
    else if(ALUOpration == 3'b100)begin
      if(A[31] != B[31])begin
        if(A[31] > B[31]) Result = 1;
        else Result = 0;
      end
      else begin
        if(A < B) Result = 1;
        else Result = 0;
      end
    end
  end
endmodule

module DataMem(input [31:0] Address, WriteData, input MemRead, MemWrite, clk, output [31:0] ReadData);
    reg [31:0] Mem [0:16000];
    initial $readmemh("data.data", Mem);
    assign ReadData = MemRead ? Mem[Address] : 32'b0;
    always@(posedge clk)begin
        if(MemWrite == 1)begin
            Mem[Address] = WriteData;
        end
    end
endmodule

module IF_IDReg(input[31:0] inInst, inPC, input IF_IDWrite, clk, rst, instClear, output[31:0] outInst, outPC);
  reg[31:0] inst;
  reg[31:0] pc;
  always@(posedge clk, posedge rst)begin
    if(rst) begin
      inst <= 32'b0;
      pc <= 32'b0;
    end
    else begin
      if(IF_IDWrite) begin
        if(instClear) begin
          inst <= 32'b0;
          pc <= 32'b0;
        end
        else begin
          inst <= inInst;
          pc <= inPC;
        end
      end
    end
  end
  
  assign outInst = inst;
  assign outPC = pc;
endmodule

module ID_EXReg(input[1:0] inWE, inM, input[4:0] inEX, input clk,
                input[31:0] inReadData1, inReadData2, inSEXT,
                input[4:0] inRt, inRd, inRs,
                output[1:0] outWE, outM, output[2:0] ALUOP, output ALUSrc, RegDst,
                output[31:0] outReadData1, outReadData2, outSEXT,
                output[4:0] outRt, outRd, outRs);
  reg[1:0] WE,M;
  reg[4:0] EX;
  reg[31:0] ReadData1, ReadData2, SEXT;
  reg[4:0] Rt,Rd,Rs;

  always@(posedge clk)begin
    WE <= inWE;
    M <= inM;
    EX <= inEX;
    ReadData1 <= inReadData1;
    ReadData2 <= inReadData2;
    SEXT <= inSEXT;
    Rt <= inRt;
    Rd <= inRd;
    Rs <= inRs;
  end

  assign ALUSrc = EX[4];
  assign ALUOP = EX[3:1];
  assign RegDst = EX[0];
  assign outWE = WE;
  assign outM = M;
  assign outReadData1 = ReadData1;
  assign outReadData2 = ReadData2;
  assign outSEXT = SEXT;
  assign outRt = Rt;
  assign outRd = Rd;
  assign outRs = Rs;
endmodule

module EX_MEMReg(input[1:0] inWE, inM, input clk,
                input[31:0] inALURes, inWriteData,
                input [4:0] inRd,
                output[1:0] outWE, output MemRead, MemWrite,
                output[31:0] outALURes, outWriteData,
                output [4:0] outRd);
  reg[1:0] WE,M;
  reg[31:0] ALURes, WriteData;
  reg[4:0] Rd;

  always@(posedge clk)begin
    WE <= inWE;
    M <= inM;
    ALURes <= inALURes;
    WriteData <= inWriteData;
    Rd <= inRd;
  end

  assign MemRead = M[1];
  assign MemWrite = M[0];
  assign outWE = WE;
  assign outM = M;
  assign outALURes = ALURes;
  assign outWriteData = WriteData;
  assign outRd = Rd;
endmodule

module MEM_WBReg(input[1:0] inWE, input clk,
                input[31:0] inReadData, inAddress,
                input [4:0] inRd,
                output MemToReg, RegWrite,
                output[31:0] outReadData, outAddress,
                output [4:0] outRd);
  reg[1:0] WE;
  reg[31:0] ReadData, Address;
  reg[4:0] Rd;

  always@(posedge clk)begin
    WE <= inWE;
    ReadData <= inReadData;
    Address <= inAddress;
    Rd <= inRd;
  end

  assign MemToReg = WE[1];
  assign RegWrite = WE[0];
  assign outAddress = Address;
  assign outReadData = ReadData;
  assign outRd = Rd;
endmodule

module PipeLineMIPSDP(input IF_IDWrite, PCWrite, NOPS, instClear,
                      input[1:0] EqCS1, EqCS2, ALUAS, ALUBS, PCSrc,
                      input[8:0] controllerSignals, input rst, clk,
                      output[4:0] Rs, Rt, id_exRtOut, id_exRdMuxOut, ex_memRdOut, id_exRsOut, mem_wbRdOut,
                      output id_exMemReadOut, ex_memMemReadOut, id_exRegWriteOut, id_exALUSrcOut,
                      ex_memRegWriteOut, mem_wbRegWriteOut, areEqual, output[31:0] InstOutController);

wire[31:0] inPC, pc, instOut, adder1Out, adder2Out;
wire[27:0] shl1Out;
wire[31:0] shl2Out, concatOut;

wire[31:0] if_idInst, if_idPC;

wire[8:0] controlSignnals;
wire[31:0] RD1, RD2, sextOut;

wire[1:0] id_exWE, id_exM;
wire id_exALUSrc, id_exRegDst;
wire[31:0] id_exRD1, id_exRD2, id_exSEXT;
wire[4:0] id_exRt, id_exRd, id_exRs;
wire[2:0] id_exALUOP;

wire[31:0] ALUResOut;

wire[31:0] ex_memALURes, ex_memWriteData;
wire[4:0] ex_memRd;
wire[1:0] ex_memWE;
wire ex_memMemWrite, ex_memMemRead;

wire[31:0] MemRD;

wire[31:0] mem_wbReadData, mem_wbAddress;
wire[4:0] mem_wbRd;
wire mem_wbRegWrite, mem_wbMemToReg;

wire[31:0] mux9Out;
wire[31:0] mux3Out, mux4Out, mux5Out, mux6Out, mux7Out;
wire[4:0] mux8Out;

wire[31:0] constValue4;
wire[8:0] constValue0;

assign constValue4 = 32'b00000000000000000000000000000100;
assign constValue0 = 9'b0;

PCReg pcreg(inPC, PCWrite, clk, rst, pc);

InstMem instmem(pc, instOut);

Adder_32 adder1(pc, constValue4, adder1Out);
Adder_32 adder2(pc, shl2Out, adder2Out);

SHL2_26_to_28 shl1(if_idInst[25:0], shl1Out);
SHL2_32_to_32 shl2(sextOut, shl2Out);

MUX3_32 mux1(adder1Out, adder2Out, concatOut, PCSrc, inPC);
MUX2_9 mux2(controllerSignals, constValue0, NOPS, controlSignnals);
MUX3_32 mux3(RD1, ex_memALURes, mux9Out, EqCS1, mux3Out);
MUX3_32 mux4(RD2, ex_memALURes, mux9Out, EqCS2, mux4Out);
MUX3_32 mux5(id_exRD1, ex_memALURes, mux9Out, ALUAS, mux5Out);
MUX3_32 mux6(id_exRD2, ex_memALURes, mux9Out, ALUBS, mux6Out);
MUX2_32 mux7(mux6Out, id_exSEXT, id_exALUSrc, mux7Out);
MUX2_5 mux8(id_exRt, id_exRd, id_exRegDst, mux8Out);
MUX2_32 mux9(mem_wbAddress, mem_wbReadData, mem_wbMemToReg, mux9Out);

Concat4_26 concat(if_idPC[31:28], shl1Out, concatOut);

RegFile regfile(if_idInst[25:21], if_idInst[20:16], mem_wbRd, mux9Out, clk, mem_wbRegWrite, RD1, RD2);

SignExt SEXT(if_idInst[15:0], sextOut);

ALU alu(mux5Out, mux7Out, id_exALUOP, ALUResOut);

DataMem datamem(ex_memALURes, ex_memWriteData, ex_memMemRead, ex_memMemWrite, clk, MemRD);

Comprator comprator(mux3Out, mux4Out, areEqual);

IF_IDReg if_id(instOut, pc, IF_IDWrite, clk, rst, instClear, if_idInst, if_idPC);
ID_EXReg id_ex(controlSignnals[8:7], controlSignnals[6:5], controlSignnals[4:0], clk,
                RD1, RD2, sextOut, if_idInst[20:16], if_idInst[15:11], if_idInst[25:21],
                id_exWE, id_exM, id_exALUOP, id_exALUSrc, id_exRegDst,
                id_exRD1, id_exRD2, id_exSEXT, id_exRt, id_exRd, id_exRs);
EX_MEMReg ex_mem(id_exWE, id_exM, clk, ALUResOut, mux6Out, mux8Out, ex_memWE, ex_memMemRead, ex_memMemWrite, ex_memALURes,
                   ex_memWriteData, ex_memRd);
MEM_WBReg mem_wb(ex_memWE, clk, MemRD, ex_memALURes, ex_memRd, mem_wbMemToReg, mem_wbRegWrite, mem_wbReadData, mem_wbAddress, mem_wbRd);

assign Rs = if_idInst[25:21];
assign Rt = if_idInst[20:16];
assign id_exRtOut = id_exRt;
assign id_exRdMuxOut = mux8Out;
assign id_exRsOut = id_exRs;
assign ex_memRdOut = ex_memRd;
assign id_exMemReadOut = id_exM[1];
assign ex_memMemReadOut = ex_memMemRead;
assign id_exRegWriteOut = id_exWE[0];
assign id_exALUSrcOut = id_exALUSrc;
assign mem_wbRdOut = mem_wbRd;
assign ex_memRegWriteOut = ex_memWE[0];
assign mem_wbRegWriteOut = mem_wbRegWrite;
assign InstOutController = if_idInst;

endmodule