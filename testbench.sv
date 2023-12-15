`timescale 1ns / 1ps


module testbench();

    logic clk;
    logic rstn;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic data_in_valid, data_out_valid;
    logic tx_ready;
    logic serial_data;

	// Send 19 random bytes:
    byte data_to_send[] = {8'h49, 8'h41, 8'h4E, 8'h20, 8'h4D, 8'h55, 8'h52, 8'h50, 8'h48, 8'h59, 8'h20, 8'h57, 8'h41, 8'h53, 8'h20, 8'h48, 8'h45, 8'h52, 8'h45};
    

    initial begin
        clk = 0;
        rstn = 0;
        #50;
        rstn = 1;
    end

    always #5 clk = ~ clk; // 100MHz

    initial begin
        data_in_valid <= 1'b0;
        data_in <= 8'h00;
    end
    
    always begin
        foreach(data_to_send[i]) begin
                // wait for UART to be ready before sending the next byte
                @(posedge clk)wait (tx_ready == 1);

                data_in_valid <= 1'b1;
                data_in <= data_to_send[i];
                $display("[%0t] Sending byte 0x%X", $time, data_to_send[i]);

                @(posedge clk)wait (tx_ready == 1);
                
        end
        // Done transmission
        data_in_valid <= 1'b0;
    end

    // Instantiate a UART twice, once as transmitter and once as a receiver and connect them:
    UART #(
        .BAUD(115200),
        .CLK_FREQ(100000000),
        .DATA_BITS(8),
        .STOP_BITS(1)
    ) transmitter ( 
        .clk(clk),
        .rstn(rstn),
        // Receiver ports (not used):
        .serial_data_in(),
        .data_out(),
        .data_out_valid(),
        // Transmitter ports:
        .serial_data_out(serial_data),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .tx_ready(tx_ready)
    );

    // Instantiate a UART receiver core:
    UART #(
        .BAUD(115200),
        .CLK_FREQ(100000000),
        .DATA_BITS(8),
        .STOP_BITS(1) // not used for the receiver
    ) receiver ( 
        .clk(clk),
        .rstn(rstn),
        // Receiver ports:
        .serial_data_in(serial_data),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        // Transmitter ports (not used):
        .serial_data_out(),
        .data_in(),
        .data_in_valid(),
        .tx_ready()
    );

endmodule
