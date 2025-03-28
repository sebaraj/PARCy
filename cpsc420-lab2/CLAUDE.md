# CLAUDE.md - CPSC 420 Lab 2 Reference

## Build Commands
- `cd build && make` - Build all processors (pv2stall, pv2byp, pv2long)
- `cd build && make check-asm-pv2stall` - Run all tests on pv2stall processor
- `cd build && make check-asm-pv2byp` - Run all tests on pv2byp processor
- `cd build && make check-asm-pv2long` - Run all tests on pv2long processor

## Run a Single Test
```
cd build
./pv2stall-sim +stats=1 +vcd=1 +exe=parcv2-<test-name>.vmh
./pv2byp-sim +stats=1 +vcd=1 +exe=parcv2-<test-name>.vmh
./pv2long-sim +stats=1 +vcd=1 +exe=parcv2-<test-name>.vmh
```

## Code Style Guidelines
- **Naming**: Module names prefixed with component (e.g., `pv2stall-`, `vc-`)
- **Module Structure**: Inputs first, then outputs, followed by internal wires
- **Includes**: Use `include` statements at top of file with full path
- **Constants**: Use backtick definitions for constants
- **Wire Widths**: Always specify bit widths explicitly
- **Ports**: Group related ports with comments
- **Testing**: Each module should have a corresponding test file (*.t.v)
- **Error Handling**: Use `vc-Assert.v` for runtime assertions

## Directory Structure
- `pv2stall/` - Stall-based pipeline implementation
- `pv2byp/` - Bypass-based pipeline implementation  
- `pv2long/` - Long-latency pipeline implementation
- `vc/` - Common verilog components
- `tests/` - Assembly tests