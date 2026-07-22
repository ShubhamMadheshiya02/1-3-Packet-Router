# 1-3-Packet-Router
This project implements a packet-based router architecture using Verilog. It includes FIFO buffering, synchronization logic, finite state machine control, and register handling to simulate a basic data-routing system typically used in SoC and NoC designs.

Features : Modular architecture

FIFO-based buffering
FSM-based packet control
Synchronization between domains
Clean and synthesizable SystemVerilog code
Suitable for FPGA and ASIC learning projects
Test-ready RTL structure
Expandable for multi-port routing
Module Description:

ROUTER.sv (Top Module) Acts as the main interconnection unit integrating: FIFO buffers, FSM controller, Register logic, Synchronization modules.

FIFO.v Implements a queue structure to: Buffer incoming packets, Manage read/write pointers, Generate full/empty flags.

FSM_CONTROLLER.v Controls: Packet flow sequence, State transitions, Read/write coordination, Routing enable logic.

SYNCHRONIZER.v Handles: Signal stabilization, CDC (Clock domain crossing) type safety, Metastability prevention.

REGISTER.v Implements simple register storage for: Packet holding, Temporary buffering, Data stabilization.
