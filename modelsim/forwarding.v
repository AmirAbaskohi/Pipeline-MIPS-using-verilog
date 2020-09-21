module forwarding(input[4:0] Rs, Rt, id_exRtOut, ex_memRdOut, id_exRsOut, mem_wbRdOut,
                       input ex_memRegWriteOut, mem_wbRegWriteOut,
                       output reg [1:0] EqCS1, EqCS2, ALUAS, ALUBS);
                       
    always@(Rs, Rt, id_exRtOut, ex_memRdOut, id_exRsOut, mem_wbRdOut, ex_memRegWriteOut, mem_wbRegWriteOut) begin
        {ALUAS, ALUBS, EqCS1, EqCS2} <= 8'b00000000;
        if ((ex_memRdOut != 0) && (id_exRsOut == ex_memRdOut) && (ex_memRegWriteOut == 1'b1))
            ALUAS <= 2'b01;
        else if ((mem_wbRdOut != 0) && (id_exRsOut == mem_wbRdOut) && (mem_wbRegWriteOut == 1'b1))
            ALUAS <= 2'b10;

        if ((ex_memRdOut != 0) && (id_exRtOut == ex_memRdOut) && (ex_memRegWriteOut == 1'b1))
            ALUBS <= 2'b01;
        else if ((mem_wbRdOut != 0) && (id_exRtOut == mem_wbRdOut) && (mem_wbRegWriteOut == 1'b1))
            ALUBS <= 2'b10;

        if ((ex_memRdOut != 0) && (Rs == ex_memRdOut) && (ex_memRegWriteOut == 1'b1))
            EqCS1 <= 2'b01;
        else if ((mem_wbRdOut != 0) && (Rs == mem_wbRdOut) && (mem_wbRegWriteOut == 1'b1))
            EqCS1 <= 2'b10;

        if ((ex_memRdOut != 0) && (Rt == ex_memRdOut) && (ex_memRegWriteOut == 1'b1))
            EqCS2 <= 2'b01;
        else if ((mem_wbRdOut != 0) && (Rt == mem_wbRdOut) && (mem_wbRegWriteOut == 1'b1))
            EqCS2 <= 2'b10;
    end
endmodule