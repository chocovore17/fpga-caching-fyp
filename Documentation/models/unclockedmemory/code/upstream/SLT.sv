
module SLT(A, B, Result);
	input   [31:0]  A, B;	    // inputs
	output Result;
	reg sltresult;
	assign Result = sltresult;
    always @(A,B)
    begin
		begin // SLT
				if (A[31] != B[31]) begin
					if (A[31] > B[31]) begin
						sltresult <= 1;
					end else begin
						sltresult <= 0;
					end
				end else begin
					if (A < B)
					begin
						sltresult <= 1;
					end
					else
					begin
						sltresult <= 0;
					end
				end
			end
	end
endmodule