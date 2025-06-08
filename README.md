# Processors for the PARCv2 ISA, for CPSC/ECE 4201

This repository contains my implementations for four different processors:

## Lab 1: Integer Multiply/Divide Unit

Implemented integer multiplication and division modules for the CPU in Verilog, with both iterative
and single-cycle versions. Each module accepted two 32-bit inputs and yielded a 64-bit output to be
parsed as the product, quotient, or remainder from its respective operation, using a val/rdy
interface. The submodules were integrated into a compound module, and the entire system was tested
using a common testbench.

## Lab 2: Pipelined Processor

Extended the pipelined PARCv1 processor to support full PARCv2 ISA (suite of immediate, arithmetic,
subword memory, and branch MIPS32 instructions required to run any C program without any system
calls). Implemented various hazard resolution techniques for a 5-stage pipeline, including stalling,
bypassing, and long bypassing, and integrated a piplined mul/div unit. Benchmarked IPC through
entire instruction set and C programs (masked filter, binary search, complex multiplication, and
vector addition), demonstrating performance improvements.

## Lab 3: Superscalar Processor

Extended the pipedlined processor from Lab 2 into a two-wide superscalar processor. First, I
implemented a dual-fetch, single-issue, then full dual-issue within the pipelined processor. The
updated processor fetches two instructions per cycle and issues them to functional
units A or B through a combined decode-issue stage. The respective scoreboards and
steering logic for both processors were implemented within the control logic.
Unit A retains fully functionality, while unit B supports ALU instructions.

## Lab 4: Out-of-Order and Speculative Execution

Implemented a reorder buffer to convert an I2O1 processor into an I2O2 processor with out-of-order execution.
Additionally added speculative execution of instructions immediately following branch instructions.
Reorder buffer was modified to ensure proper handling of WAW, WAR, and RAW hazards
for speculative execution. Benchmarked IPC through
entire instruction set and C programs (masked filter, binary search, complex multiplication, and
vector addition), demonstrating performance improvements.
