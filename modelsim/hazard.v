module hazard(input [4:0] Rs, Rt, id_exRdMuxOut, ex_memRdOut,
                   input id_exMemReadOut, id_exRegWriteOut, ex_memMemReadOut, ex_memRegWriteOut, Branch,
                   output reg NOPS, IF_IDWrite, PCWrite);
                   
    initial {NOPS, IF_IDWrite, PCWrite} <= 3'b011;
    always@(Rs, Rt, id_exRdMuxOut, ex_memRdOut, id_exMemReadOut, 
            id_exRegWriteOut, ex_memMemReadOut, ex_memRegWriteOut, Branch)begin
              
              if(Branch)begin
                if((id_exRdMuxOut != 0) && (id_exRegWriteOut == 1'b1) && (Rs == id_exRdMuxOut || Rt == id_exRdMuxOut))
                  {NOPS, IF_IDWrite, PCWrite} <= 3'b100;
                else if ((ex_memRdOut != 0) && (ex_memMemReadOut == 1'b1) && (Rs == ex_memRdOut || Rt == ex_memRdOut))
                  {NOPS, IF_IDWrite, PCWrite} <= 3'b100;
                else 
                  {NOPS, IF_IDWrite, PCWrite} <= 3'b011;
              end
              else begin
                if ((id_exRdMuxOut != 0) && (id_exMemReadOut == 1'b1) && (Rs == id_exRdMuxOut || Rt == id_exRdMuxOut))
                  {NOPS, IF_IDWrite, PCWrite} <= 3'b100;
                else
                  {NOPS, IF_IDWrite, PCWrite} <= 3'b011;
              end
            end
endmodule