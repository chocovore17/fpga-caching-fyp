# Implementing a basic order book in system verilog 

Final year project to speedup orders send and cancels on fpgas

## Repository structure 
 1. Shared: memory files 
    1. Memory class 
    2. module to instantiate memory from a file 
    3. 2 different memory types (client, accumulated, max) and (client, reduced)
2. Downstream : downstream.sv to read from exchange and cancel orders - FSM 
3. Upstream
    1. SLT: returns 1 is A>B
    2. Risk check: from client id and amount, reads memory to compute if the new order passes/fails the checks (calls SLT)
    3. Upstream: FSM to describe how the processor behaves
    4. Upstream_top: puts together SLT, risk check and upstream  (TODO)
4. Testbench 
    1. Module: checks with pre defined scenarios, basic checks
    2. Random: use randomisation on classes (TODO)
    3. Formal verification & other methods to implement  (TODO)

Other (TODO)
1. Write functional coverage plan 
2. Test modules 
3. Write top level to put together modules 
4. Write & check memory 
5. Put modules in classes 


*Useful links + bibiography*: 
https://www.edaplayground.com/playgrounds?searchString=&language=SystemVerilog%2FVerilog&simulator=&methodologies=&_libraries=on&_svx=on&_easierUVM=on&curated=true&_curated=on