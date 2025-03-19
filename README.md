# MATLAB based PID Fluid level trainer
This repository contains all the materials associated with the Bachelor thesis project on a **MATLAB based PID Fluid level trainer**. The work focuses on developing and implementing a PID controller for fluid level regulation, with a detailed analysis presented in the thesis document.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Key Features](#key-features)
- [Results](#results)
- [Acknowledgements](#acknowledgements)
- [License](#license)





This repository contains the complete materials for the Bachelor thesis project titled "MATLAB based PID Fluid level trainer." The project focuses on designing and implementing a fluid level trainer using a MATLAB-based PID controller. The files in the repository include:


MATLAB Code: Scripts and functions for implementing the PID controller, running simulations, and analyzing fluid level control.
Supporting Materials: MATLAB Code, Simulink Models, and supplementary documentation that support the thesis findings.
The project demonstrates the practical application of control theory using MATLAB, where a PID controller is developed and tuned to regulate the fluid level in a training environment.

## Overview

This project explores the design, simulation, and implementation of a Proportional-Integral-Derivative (PID) controller to regulate fluid levels in a training setup. The main objectives include:

- **Design and Simulation:** Creating a model of the fluid level system in MATLAB.
- **PID Tuning:** Experimenting with different PID parameters to achieve optimal performance.
- **Analysis:** Documenting system responses and comparing simulation results with theoretical expectations.
- **Implementation:** Integrating the PID controller within a practical fluid level training system.

## Project Structure

The repository is organized as follows:

├── README.md # This file ├── ├── matlab/ # MATLAB code for simulation and PID control │ ├── fluid_level_simulation.m # Main simulation script │ ├── pid_controller.m # PID controller implementation │ └── utils/ # Utility functions and helper scripts ├── data/ # Data files used in analysis and simulation │ └── experimental_results.csv # Sample data output └── docs/ # Additional documentation and reports └── presentation.pdf # Project presentation slides


To run the MATLAB simulations and explore the PID controller design:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/darkr4id/pid_level_control_trainer.git
   cd pid_level_control_trainer
Open MATLAB:

Navigate to the matlab/ directory and open the primary simulation script (pid_sim.slx).
GUI Program at 
Run the Simulation:

Execute the script in MATLAB. Make sure you have the necessary toolboxes installed. Adjust the PID parameters in pid_controller.m if needed.

Usage
Simulation: Run the fluid_level_simulation.m script to simulate the fluid level control.
Analysis: Check the generated plots and logs for performance analysis.
Experimentation: Modify the PID gains in the pid_controller.m file to observe different system responses.
Key Features
PID Controller Implementation: Robust PID algorithm tailored for fluid level control.
Simulation Environment: Detailed MATLAB simulation of a fluid tank system.
Data Analysis: Integrated tools for performance evaluation with plots and data logging.
Documentation: Comprehensive thesis report and supplementary documentation to support the findings.
Results
The project demonstrates successful control of fluid level dynamics using the PID controller. The simulation results indicate that with appropriate tuning, the system can maintain the fluid level within desired limits while responding effectively to disturbances.

Acknowledgements
Special thanks to supervisors Prof Frank Platte and Dr. Peter Henselder, friends and family that supported this project. 
