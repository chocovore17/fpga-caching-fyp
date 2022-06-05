

*Useful links + bibiography*: 

  <div id="top"></div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/chocovore17/HSV_Coursework">
    
  </a>

  <h3 align="center">Caching on FPGAs to speedup algorithmic trading</h3>

  <p align="center">
    4th year Final Year Project 
    <br />
    <a href="https://github.com/chocovore17/HSV_Coursework"><strong>Link to git repository »</strong></a>
    <br />
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#context">Context</a></li>
      </ul>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
      <ul>
        <li><a href="#repository-structure">Repository structure</a></li>
      </ul>
      <ul>
        <li><a href="#challlenges">What to do next</a></li>
      </ul>
      <!-- <ul>
        u<li><a href="#built-with">Built With</a></li>
      </l> -->
    </li>
    <li>
      <a href="#running-the-project">Running the project</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#producing-outputs">Producing the test outputs</a></li>
      </ul>
    </li>
    <li><a href="#unittest">Unit tests</a>
      <ul>
        <li><a href="#unittestlog">Logs</a></li>
        <li><a href="#unittestassumptions">Assumptions</a></li>
        <li><a href="#unittestperformance">Performance</a></li>
      </ul>
    </li>
    <li><a href="#toplevel"> Top level testing</a>
    </li>
    <li><a href="#fv">Formal verification</a>
      <ul>
        <li><a href="#fvlogs">Logs</a></li>
        <li><a href="#fvassumptions">Assumptions</a></li>
        <li><a href="#fvperformance">Performance</a></li>
      </ul>
    </li>
    <li><a href="#references">References</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Final year project for MEng. Electronic and Information Engineering, Imperial College London

<p align="right">(<a href="#top">back to top</a>)</p>



### Built With

The repository constains the following frameworks/libraries. 

* [Verilog](http://www.asic-world.com/verilog/tools.html)
* [SystemVerilog](https://www.chipverify.com/systemverilog/systemverilog-tutorial)
* [Assembly](https://www.ibm.com/docs/en/zos/2.1.0?topic=introduction-assembler-language)
* [JasperGold](https://www.cadence.com/en_US/home/tools/system-design-and-verification/formal-and-static-verification/jasper-gold-verification-platform.html)

<p align="right">(<a href="#top">back to top</a>)</p>




<!-- GETTING STARTED -->
## Running the Project 

In order to make running the project simpler and faster, we wrote a script to remove the gui and run a faster simulation. These bash script can be found under Hardware folder. 

## What to do next for future developers

1. Formal Verification with Jasper Gold and TLA+ - script provided
2. Synthesis on FPGA 

### Prerequisites

This repository load local variable to run questasim. It is therefore required to:
1. Use Imperial College VPN or connect to Imperial Wifi
2. SSH into one of Imperial's machine. 

Alternative is to install system verilog and verilog compilers as well as questasim.

* load local variables 
  ```sh
  source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh
  ```

### Producing Outputs

_Please find below how to run both GPIO and 7 segement unit tests._

1. Clone the repo (or unzip the repository zipfile)
   ```sh
   git clone https://github.com/username/HSV_Coursework.git
   ```
### Repository Structure 

Logs of the outputs can be found under tbench/. The files are organised as follows 

AHB_peripherals_files

    |_ Code 

        |_ downstream  

            |_ top module, downstream module

            |_ get_cxl to obtain and read new cancels

            |_ output logs

        |_ upstream  

            |_ top module, upstream module

            |_ risk check module to ensure accumulated orders <= max orders

            |_ output logs


        |_ shared 

            |_ downstream ram - two entries (c_id, amount)
        
            |_  upstream ram - three entries (c_id, amount, max amount)


    |_ Documentation # screenshots, diagrams 
    

    |_ testbench  

        |_ Module   

        |_ Outputs   

        |_ tbenchoutputs 

        |_ unitlevel 

            |_ downstream - module level randomsed test + jaspergold fles
        
            |_  upstream - module level randomsed test + jaspergold fles
        
            |_  top - module level randomsed test + jaspergold fles
        



<p align="right">(<a href="#top">back to top</a>)</p>



### Challenges 

<!-- UNIT TESTS -->
## Unit tests

### Logs

### Assumptions 
1. Client id = adress to read

## Repository structure 

all the relevant pieces of code is under code/ folder. 
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


<p align="right">(<a href="#top">back to top</a>)</p>




<!-- TOP LEVEL TESTS -->
## Top-level testing

All assembly files can be found under src/*. These files were compiled and provided the following outputs.




## References
[baseline-module-tests]:( https://www.edaplayground.com/playgrounds?searchString=&language=SystemVerilog%2FVerilog&simulator=&methodologies=&_libraries=on&_svx=on&_easierUVM=on&curated=true&_curated=on
)
Lecture notes


<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Maëlle Guerre - [@github](https://github.com/chocovore17)
John Wickerson - [@webpage](https://johnwickerson.github.io/)

<p align="right">(<a href="#top">back to top</a>)</p>

