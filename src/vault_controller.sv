/////////////////////////////////////////////////////////////////////
// Design unit: vault_controller
//            :
// File name  : vault_controller.sv
//            :
// Description: vault controller
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/15
/////////////////////////////////////////////////////////////////////

module vault_controller (input logic clock, n_reset, direction, 
	input logic [4:0] vault_code,
	output logic [9:0] led // LEDs are used to display information about vault controller's behaviour
 );

enum {locked, started, unlocked, uptocomb1, lock_reset} state, next_state;

// include your implementation of the ASM chart here.

   always_ff @(posedge clock , negedge n_reset) begin : seq_fsm
      if(n_reset == 1'b0)
	state <= locked;
      else
	state <= next_state;      
   end

   always_comb
     begin : COMBO_LOGIC_FSM
	//Default values
	next_state = state;
	unique case (state)
	  locked: begin
	     if(direction == 1'b0 && vault_code == '0)
	       next_state = started;
	     else
	       next_state = locked;	     
	  end
	  started : begin
	     if(direction == 1'b1 && |vault_code == 1'b1)
	       next_state = uptocomb1;
	     else
	       next_state = started;
	  end
	  uptocomb1: begin
	     if(direction == 1'b1 && vault_code == 5'd7)
	       next_state = unlocked;
	     else if (direction == 1'b0 | (direction == 1'b1 && vault_code >7))
	       next_state = locked;
	     else if (direction == 1'b1 && vault_code < 7)
	       next_state = uptocomb1;
	  end
	  unlocked: begin
	     if(direction == 1'b1)
	       next_state = unlocked;
	     else
	       next_state = lock_reset;
	  end
	  lock_reset: begin
	     if(direction == 1'b0 && vault_code == '0)
	       next_state = locked;
	     else (direction == 1'b1 || (direction == 1'b0 && |vault_code == 1'b1))
	       next_state = lock_reset;
	  end
	endcase // unique case (state)
	
	  	  				      			    	  	       	     	    	   		           
always_comb	   // always_comb - combinational logic for output signals; implicit sensitivity list
  begin: com
  
	// leds are used to display information about the controller's operation
	led[0] = (state == locked);       // vault locked
	led[1] = (state == started);     // vault unlocked
	led[2] = (state == uptocomb1);    // rotating up towards combination
	led[3] = (state == unlocked);   // in process of resetting
	led[4] = direction;					 //direction of turning RE
	led[5] = vault_code[0];     	    // vault code
	led[6] = vault_code[1];           // vault code
	led[7] = vault_code[2];           // vault code
        led[8] = vault_code[3];           // vault code
	led[9] = vault_code[4];           // vault code
  end

endmodule
