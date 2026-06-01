# AeroFuse Hybrid-Electric Aircraft Extension

AeroFuse is meant to be a toolbox for aircraft design analyses. It currently provides convenient methods for developing studies in aircraft geometry, aerodynamics and structures, with implementations in other relevant fields such as flight dynamics and propulsion in progress. This repository extends the work of Arjit Seth and Rhea P. Liem to support hybrid-electric aircraft sizing and mission analysis.

**Author**: Sabina Hassan

## Objectives

The current focus is to enable tutorials in computation in an aerospace educational curriculum, particularly at The Hong Kong University of Science and Technology. An additional aim is to write code compatible with automatic differentiation libraries written in Julia for enabling multidisciplinary studies.

>**Disclaimer**: The implementations are work-in-progress, and hence the results may not be entirely accurate. Please exercise caution when interpreting the results until validation cases are added. The framework is most appropriate as an early-stage conceptual design tool for identifying feasible regions, technology targets and trade-offs, rather than detailed aircraft certificationlevel design


## Features
- Battery and fuel sizing
- Mission segment power analysis
- Payload-range diagrams
- Constraint diagram calculations
- Battery volume visualisation


## Installation

Please install the current stable release of [Julia](https://julialang.org/downloads/) for your operating system, download the contents of this repository and execute the following commands in the REPL.

```julia
julia> using Pkg; Pkg.add("AeroFuse")
julia> Pkg.test("AeroFuse")
julia> using AeroFuse
julia> using HybridElectric
```
