# MIPS Pipelined RTL (with Branch Prediction & Datapath Forwarding)

The RTL design is for a 5-stage MIPS processor. Two versions of the pipelined processor were implemented. 
You can find the RTL code for both versions below, along with the FPGA demo video for version 1.

- RTL on simulation with branch prediction and data-path forwarding
- RTL on FPGA without branch prediction

The branch prediction was done using a simple 2-bit predictor. The datapath forwarding was implemented between the Execute, Memory, and Write Back stages of the pipeline. The initial scope of the project was only for simulating version 1, but I expanded on it to synthesize it on Artix-7 FPGA excluding some features from version 1 due to time limitation. 

## 5-stage pipeline 
![EE275-MP2-Page-4 drawio](https://github.com/bhavinpt/mips-rtl/assets/117598876/2efc5162-efa3-43fd-817c-c6b426b5b456 "5-stage pipeline")

## Datapath Forwarding
MEM and WB stages forward their register numbers and values back to EX stage. The EX stage prioritizes WB->MEM->ID while reading for the same register number.
![EE275-MP2-Forwarding drawio](https://github.com/bhavinpt/mips-rtl/assets/117598876/c72c551b-d13b-46bf-a48c-3bf9ef8d91f0 "Datapath Forwarding")

## Branch Prediction
On every branch instruction, IF stage keeps track of PC address to revert in case the prediction fails.
![EE275-MP2-branch prediction drawio](https://github.com/bhavinpt/mips-rtl/assets/117598876/56e7a2f5-dde6-4440-95f4-5063cf3454b2 "Branch Prediction")

## Demo

https://github.com/bhavinpt/mips-rtl/assets/117598876/8b2e1992-974b-4c42-a851-d564b0e374b0

![image](https://github.com/bhavinpt/mips-rtl/assets/117598876/982f8b02-ee0e-4f50-a284-c7d918663be3 "Expected Output") ![image](https://github.com/bhavinpt/mips-rtl/assets/117598876/5e096ac3-ece0-484e-a460-a06502c6ade5 "FPGA Output")


