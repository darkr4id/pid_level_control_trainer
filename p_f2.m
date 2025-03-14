%% Clear Workspace and Setup
clear all;
close all;
clc;

%% Controller Parameters
simTime = 200;   % Simulation duration in seconds
ptime   = 300;   % Pause time between experiments to drain the tank

%controller gains (each row is one set: [Kp, Ki, Kd; Kp2, Ki2, Kd2;])
pidGains = [ 15, 0,0;
            15,  50, 10;
            15,   10, 2;
             ];
            

% Name of the Simulink model
model = 'pid_exp';

%% Open the Model and Set External Mode
open_system(model);
set_param(model, 'SimulationMode', 'external');

%% Loop Through Each PID Gain Set (each experiment handles one set)
numExperiments = size(pidGains,1);

for iter = 1:numExperiments
    fprintf('Experiment %d: Running with Kp = %g, Ki = %g, Kd = %g\n', ...
        iter, pidGains(iter,1), pidGains(iter,2), pidGains(iter,3));
    
    % Upload the PID gains to the base workspace for the Simulink model
    assignin('base', 'kp', pidGains(iter,1));
    assignin('base', 'ki', pidGains(iter,2));
    assignin('base', 'kd', pidGains(iter,3));
    
    % Set m_on = 1 to turn on the motor pump at the beginning of the experiment
    assignin('base', 'm_on', 1);
    
    % Start the simulation (this uploads the code to the Arduino)
    set_param(model, 'SimulationCommand', 'start');
    fprintf('Simulation started in External Mode.\n');
    
    % Let the simulation run for the specified simulation time
    pause(simTime);
    
    % Stop the simulation
    set_param(model, 'SimulationCommand', 'stop');
    fprintf('Simulation stopped.\n');
    
    % Set m_on = 0 to turn off the motor pump after the experiment
    assignin('base', 'm_on', 0);
    
    % Wait for the To Workspace blocks to write their data.
    % We'll wait (up to 10 seconds) for variables 'pi_height' and 'error_calc' to appear.
    maxWaitTime = 10; % seconds
    elapsedTime = 0;
    while elapsedTime < maxWaitTime && ( ~evalin('base','exist(''pi_height'',''var'')') || ~evalin('base','exist(''error_calc'',''var'')') )
        pause(0.1);
        elapsedTime = elapsedTime + 0.1;
    end
    if ~evalin('base','exist(''pi_height'',''var'')')
        error('Variable pi_height did not appear in the base workspace within the allotted time.');
    end
    if ~evalin('base','exist(''error_calc'',''var'')')
        error('Variable error_calc did not appear in the base workspace within the allotted time.');
    end

    % Retrieve output signals from the base workspace using evalin.
    pi_height_ts  = evalin('base', 'pi_height');
    error_calc_ts = evalin('base', 'error_calc');
    kp_g_ts       = evalin('base', 'kp_g');
    ki_g_ts       = evalin('base', 'ki_g');
    kd_g_ts       = evalin('base', 'kd_g');
    
    % Extract and save the data from the timeseries.
    % Save the pi_height data and its corresponding time vector (named pi_htN)
    eval(sprintf('pi_height%d = squeeze(pi_height_ts.Data);', iter));
    eval(sprintf('pi_ht%d   = pi_height_ts.Time;', iter));  % New variable for time vector
    
    eval(sprintf('error_calc%d = squeeze(error_calc_ts.Data);', iter));
    eval(sprintf('error_time%d   = error_calc_ts.Time;', iter));
    
    eval(sprintf('kp_g%d = squeeze(kp_g_ts.Data);', iter));
    eval(sprintf('ki_g%d = squeeze(ki_g_ts.Data);', iter));
    eval(sprintf('kd_g%d = squeeze(kd_g_ts.Data);', iter));
    
    % Save simulation data to a MAT-file named based on the current PID gains.
    fileName = sprintf('exp_kp%gki%gkd%g.mat', pidGains(iter,1), pidGains(iter,2), pidGains(iter,3));
    varsToSave = {sprintf('pi_height%d', iter), sprintf('pi_ht%d', iter), ...
                  sprintf('error_calc%d', iter), sprintf('error_time%d', iter), ...
                  sprintf('kp_g%d', iter), sprintf('ki_g%d', iter), sprintf('kd_g%d', iter)};
    save(fileName, varsToSave{:});
    fprintf('Saved simulation data to file: %s\n', fileName);
    
    % Pause to allow the tank to drain before the next experiment (if not last)
    if iter < numExperiments
        fprintf('Pausing for %d seconds to allow the tank to drain...\n', ptime);
        pause(ptime);
    end
end

%% Plotting the Results

% Create legend labels for each experiment
labels = cell(1, numExperiments);
for iter = 1:numExperiments
    labels{iter} = sprintf('Kp = %g, Ki = %g, Kd = %g', pidGains(iter,1), pidGains(iter,2), pidGains(iter,3));
end

% Plot 1: PI Height Variation with Time (all experiments)
figure;
hold on;
colors = {'-r', '-g', '-b', '-m', '-c', '-k'};  % Extend if needed
for iter = 1:numExperiments
    time_vec   = eval(sprintf('pi_ht%d', iter));
    heightData = eval(sprintf('pi_height%d', iter));
    plot(time_vec, heightData, 'LineWidth', 1.0);
end
xlabel('Time (s)');
ylabel('Height (m)');
xlim([0 simTime]);
yline(0.1, 'r--', 'y = 0.1');
title('Height Variation with Time (All Experiments)');
legend([labels, {'Reference'}], 'Location', 'Best');
grid on;
hold off;

% Plot 2: Error Calculation Variation with Time (all experiments)
figure;
hold on;
for iter = 1:numExperiments
    errTime = eval(sprintf('error_time%d', iter));
    errData = eval(sprintf('error_calc%d', iter));
    plot(errTime, errData,'LineWidth', 1.0); %colors{iter}
end
xlabel('Time (s)');
ylabel('Error Calculation Value');
xlim([0 simTime]);
title('Error Calculation Variation with Time (All Experiments)');
legend(labels, 'Location', 'Best');
grid on;
hold off;

%% Plotting PID Control Contributions for Each Experiment
for iter = 1:numExperiments
    % Retrieve the time vector for this experiment
    % (Assuming the time vector for the control signals is the same as pi_htN)
    t = eval(sprintf('pi_ht%d', iter));

    % Retrieve the control contribution data
    kp_val = eval(sprintf('kp_g%d', iter));
    ki_val = eval(sprintf('ki_g%d', iter));
    kd_val = eval(sprintf('kd_g%d', iter));

    % Create a new figure for this experiment
    figure;
    hold on;

    % Plot each PID component with a different color/style
    plot(t, kp_val, '-r', 'LineWidth', 1.0); % Proportional contribution in red
    plot(t, ki_val, '-g', 'LineWidth', 1.0); % Integral contribution in green
    plot(t, kd_val, '-b', 'LineWidth', 1.0); % Derivative contribution in blue

    % Customize the plot
    xlabel('Time (s)');
    ylabel('Control Signal Contribution');
    title(sprintf('PID Contributions for Experiment %d (Kp = %g, Ki = %g, Kd = %g)', ...
        iter, pidGains(iter,1), pidGains(iter,2), pidGains(iter,3)));
    legend('Proportional', 'Integral', 'Derivative', 'Location', 'Best');
    grid on;
    hold off;
end

%% Save Entire Workspace Data
finalFileName = input('Enter filename to save the entire workspace (e.g., workspace.mat): ', 's');
save(finalFileName);
fprintf('Entire workspace data saved to %s\n', finalFileName);
