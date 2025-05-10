# MATLAB+Simulink based PID Fluid level control trainer - Bachelor Thesis project.
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
Additionally a GUI program is included to run both the simulations and the experiment methods in a graphical environment.* 
The project demonstrates the practical application of control theory using MATLAB, where a PID controller is developed and tuned to regulate the fluid level in a training environment.

## Overview

This project explores the design, simulation, and implementation of a Proportional-Integral-Derivative (PID) controller to regulate fluid levels in a training setup. The main objectives include:

- **Design and Simulation:** Creating a model of the fluid level system in MATLAB.
- **PID Tuning:** Experimenting with different PID parameters to achieve optimal performance.
- **Analysis:** Documenting system responses and comparing simulation results with theoretical expectations.
- **Implementation:** Integrating the PID controller within a practical fluid level training system.

## Project Structure

The repository is organized as follows:

- README.md : This file
- p_f2.m : Main automation script
- pid_exp.slx : Main experimental simulink model
- pid_sim.slx : Main simulation model
- gui_pid_simulation_2.m : GUI Program for the project (Beta)

To run the MATLAB Simulink models and explore the PID controller design:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/darkr4id/pid_level_control_trainer.git
   cd pid_level_control_trainer
2. **Open MATLAB:**

Navigate to the matlab/ directory and open the primary simulation script (pid_sim.slx) and the experimental simulink model (pid_exp.slx).
GUI Program at 
Run the Simulation:

**Important**
The experimental setup is designed using a Arduino UNO R4, therefore its essential for any replications of the setup to have the same microcontroller or for the Simulink external mode settings to be adjusted according to the controller used.
Motor Driver: L298N
Pump: Brushed DC pump of 12V (Exact model can be found on the Thesis Defence presentation)

**Important**
The GUI program was in the beta version as of 2025 May, no further development would be available for it due to time constraints and due to me finally moving on from this project to my master, but the GUI program worked just fine except for some minute errors in handling the experimental mode with multiple gain combos.

Execute the script in MATLAB. Make sure you have the necessary toolboxes installed, Arduino Support package for simulink and matlab, Digital signal processing toolbox. Adjust the PID parameters in p2_f.m when running the script.

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

## Acknowledgements
Special thanks to supervisors Prof Frank Platte and Dr. Peter Henselder, friends and family that supported this project. 

* however this is still in its beta phase and even though at times the runs were successful at times it had issues with communicating with Simulink.
