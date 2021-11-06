// This is the class that we will randomize.
class my_item;
  
  typedef enum {ADD, SUB, DIV, MOV} inst_e;

  rand int m_int;
  rand bit[3:0] m_array[];
  rand inst_e inst;

  // Randomization constraints.
  constraint c {
    m_int > 500;
    m_int <= 1000;
    m_array.size() < 5;
    inst inside {ADD, DIV};
    if (m_int > 700) {
      m_array.size() == 1;
    }
  }
  
  // Print out the items.
  function void print();
    $display("m_int:%0d", m_int);
    $display("m_array.size:%0d", m_array.size());
    foreach(m_array[i])
      $display("m_array[%0d]:%0d", i, m_array[i]);
    $display("inst:%s", inst.name());
  endfunction
  
endclass

module automatic test;
  
  function void run;
    my_item item = new();
    $display("INITIAL");
    item.print();
    for (int i = 0; i < 5; i++) begin
      $display("NORMAL RANDOMIZE %0d", i);
      item.randomize();
      item.print();
    end
    
    $display("RANDOMIZE WITH");
    item.randomize() with {
      m_int == 1000;
    };
    item.print();
  endfunction
  
  initial run();
  
endmodule