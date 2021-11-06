
module SLT(A, B, Result);
	input   [31:0]  A, B;	    // inputs
    always @(A,B)
    begin
		begin // SLT
				if (A[31] != B[31]) begin
					if (A[31] > B[31]) begin
						Result <= 1;
					end else begin
						Result <= 0;
					end
				end else begin
					if (A < B)
					begin
						Result <= 1;
					end
					else
					begin
						Result <= 0;
					end
				end
			end
	end
endmodule