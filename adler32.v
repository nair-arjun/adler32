module adler32(clock, rst_n, size_valid, size, data_start, data, checksum_valid, checksum);
    input rst_n, clock, size_valid, data_start;
    input [31:0] size;
    input [7:0] data;
    output reg checksum_valid;
	output reg [31:0] checksum;

    reg [31:0] count;
    reg [2:0] state;
    parameter [2:0] STATE0=3'b000,STATE1=3'b001,STATE2=3'b010,STATE3=3'b011,STATE4=3'b100;

    always @ (posedge clock)
    if (!rst_n)
        begin
            count <= 1'b00000000000000000000000000000000;
            checksum <= 32'h00000001;			
            state <= STATE0;
            checksum_valid <= 1'b0;
        end
    else
        begin
            case(state)
            STATE0:
                if(size_valid)
                begin
                    count <= size;
                    state <= STATE1;
                end
                else state <= STATE0;
            STATE1:
                if(data_start)
                begin
                    state <= STATE2;
                    count <= count;
                end
                else state <= STATE1;
            STATE2:
                if(count==1)
                begin
                    checksum_valid <= 1'b1;
                    checksum[15:0] <= checksum[15:0] + data;
			        checksum[31:16] <= checksum[31:16] + checksum[15:0] + data;
                    state <= STATE3;
                end
                else
                begin
                    count <= count - 1'b1;
                    checksum[15:0] <= checksum[15:0] + data;
			        checksum[31:16] <= checksum[31:16] + checksum[15:0] + data;
                    state <= STATE2;
                end
            STATE3:
            begin
                checksum_valid <= 1'b0;
                state <= STATE4;
            end
            STATE4:
            begin
                checksum[31:0] <= 32'b1;
                count <= 1'b0;
                state <= STATE0;
            end
            default:
                state <= STATE0;
            endcase
        end
endmodule
