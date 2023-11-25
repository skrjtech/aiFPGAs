# aiFPGAs
AIモデルをFPGAに組み込む目的としている
# FPGA 環境 (Intel(旧Altera) MAX10 10M08SAE144C8G)

# [UART Module (VerilogHDL)](VerilogHDLSources/UART)
Simulation Pattern  
Clock: 100
BaudRate: 50  
TestBench: 
- [Uart tb.v](VerilogHDLSources/UART/Simulation/TestBench/tb.v)  

ModelSim Run DO Command:  

- [Transmit.do](VerilogHDLSources/UART/Simulation/ModelSim/Transmit.do)  
- [Recieve.do](VerilogHDLSources/UART/Simulation/ModelSim/Recieve.do)  

★ Transmit TimingCharts  

![Transmit](/VerilogHDLSources/UART/Simulation/Images/Transmit.PNG)  

★ Recieve TimingCharts  

![Recieve](/VerilogHDLSources/UART/Simulation/Images/Recieve.PNG)  

★ Uart TimingCharts  

![Uart](/VerilogHDLSources/UART/Simulation/Images/Uart.PNG)  

