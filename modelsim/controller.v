module SignalController(input [31:0] InstInController, 
                        output reg ALUSrc, RegWrite, beq, bne, jmp, MemRead, MemWrite, MemToReg, RegDst, 
                        output reg [1:0] aluop);
    wire[5:0] Opcode;
    assign Opcode = InstInController[31:26];                    
    always@(InstInController)begin
      {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp,aluop} = 11'b00000000000;
      if(InstInController == 32'b00000000000000000000000000000000)
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp,aluop} = 11'b00000000000;
      else if(Opcode == 6'b000000)begin // r_type
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b010000010;
        aluop = 2'b10;
      end
      else if(Opcode == 6'b001100 || Opcode == 6'b001000)begin //addi andi
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b110000000;
        aluop = (Opcode == 6'b001100) ? 2'b11 : 2'b00;
      end
      else if(Opcode == 6'b100011)begin //lw
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b110010100;
        aluop = 2'b00;
      end
      else if(Opcode == 6'b101011)begin //sw
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b100001000;
        aluop = 2'b00;
      end
      else if(Opcode == 6'b000100)begin //beq
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b001000000;
        aluop = 2'b01;
      end
      else if(Opcode == 6'b000101)begin //bne
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b000100000;
        aluop = 2'b01;
      end
      else if(Opcode == 6'b000010)begin //j
        {ALUSrc,RegWrite,beq,bne,MemRead,MemWrite,MemToReg,RegDst,jmp} = 9'b000000001;
        aluop = 2'b00;
      end
    end
endmodule

module ALUControllerC(input [1:0] aluop,
                      input [5:0] Funccode, 
                      output reg [2:0] AluOperation);

    always@(aluop, Funccode)begin
      if(aluop == 2'b10)begin
        if(Funccode == 6'b100000) AluOperation = 3'b010; //add
        else if(Funccode == 6'b100100) AluOperation = 3'b000; //and
        else if(Funccode == 6'b100101) AluOperation = 3'b001; //or
        else if(Funccode == 6'b100010) AluOperation = 3'b011; //sub
        else if(Funccode == 6'b101010) AluOperation = 3'b100; //compare
        else AluOperation = 3'b010;
      end
      else if(aluop == 2'b00) AluOperation = 3'b010; //add
      else if(aluop == 2'b01) AluOperation = 3'b011; //sub
      else if(aluop == 2'b11) AluOperation = 3'b000; //and
    end
endmodule

module MIPS_Controller(input [31:0] InstInController,
                       input areEqual, 
                       output [1:0] PCSrc, 
                       output [8:0] controllerSignals, 
                       output Branch, instClear);

    wire MemToReg, RegWrite, MemRead, MemWrite, ALUSrc, RegDst;
    wire [2:0] ALUOP;
    wire be,bn,jmp;
    wire [1:0] op;
    wire [5:0] Funccode;
    assign Funccode = InstInController[5:0];
    SignalController sc(InstInController, ALUSrc, RegWrite, be, bn, jmp, MemRead, MemWrite, MemToReg, RegDst, op);
    ALUControllerC aluc(op, Funccode, ALUOP);
    assign Branch = be || bn;
    assign PCSrc = (jmp) ? 2'b10 : ((be && areEqual) || (bn && ~areEqual)) ? 2'b01 : 2'b00;
    assign instClear = ((jmp) || (be && areEqual) || (bn && ~areEqual)) ? 1'b1 : 1'b0;
    assign controllerSignals = {MemToReg, RegWrite, MemRead, MemWrite, ALUSrc, ALUOP, RegDst};
endmodule