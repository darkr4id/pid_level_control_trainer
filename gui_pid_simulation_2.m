function gui_pid_simulation
    % Load parameters before creating the GUI
    A = pi*(0.15^2)/4;
    a = pi*(0.0035^2)/4;
    C = a*sqrt(2*9.8);
    % Assign these parameters to the base workspace if needed by the models
    assignin('base','A',A);
    assignin('base','a',a);
    assignin('base','C',C);
    
    %% Create the GUI Figure
    fig = figure('Position',[400 200 550 450],...
        'MenuBar','none',...
        'Name','PID Simulation/Experimental GUI',...
        'NumberTitle','off',...
        'Resize','off');
    
    % Global variable (local to the function) to signal abort requests
    abortFlag = false;
    
    %% Define Model Paths (Use full paths to avoid shadowing issues)
    simModelPath = 'C:\Users\labadmin\Desktop\Thesis\GUI\pid_sim.slx';
    expModelPath = 'pid_exp.slx';  % Adjust if a full path is needed for the experimental model
    
    % Extract model names from full file paths
    [~, simModelName, ~] = fileparts(simModelPath);
    [~, expModelName, ~] = fileparts(expModelPath);
    
    %% Mode Selection (top left)
    uicontrol('Style','text','Position',[30 410 80 20],...
        'String','Mode:','HorizontalAlignment','right');
    modePopup = uicontrol('Style','popupmenu',...
        'Position',[120 410 100 25],...
        'String',{'Simulation','Experimental'},...
        'Value',1,...
        'Callback',@toggleMode);
    
    %% Single Gain Controls (left side)
    % Kp input
    uicontrol('Style','text','Position',[30 370 60 20],...
        'String','Kp:','HorizontalAlignment','right','Tag','singleLabel');
    editKp = uicontrol('Style','edit','Position',[100 370 80 25],'String','0','Tag','singleEdit');
    
    % Ki input (raw value)
    uicontrol('Style','text','Position',[30 330 60 20],...
        'String','Ki:','HorizontalAlignment','right','Tag','singleLabel');
    editKi = uicontrol('Style','edit','Position',[100 330 80 25],'String','20','Tag','singleEdit');
    
    % Kd input
    uicontrol('Style','text','Position',[30 290 60 20],...
        'String','Kd:','HorizontalAlignment','right','Tag','singleLabel');
    editKd = uicontrol('Style','edit','Position',[100 290 80 25],'String','0','Tag','singleEdit');
    
    %% Common Parameters (left side)
    % Simulation Time
    uicontrol('Style','text','Position',[30 250 80 20],...
        'String','Sim Time (s):','HorizontalAlignment','right');
    editSimTime = uicontrol('Style','edit','Position',[120 250 80 25],'String','2000');
    
    % Setpoint
    uicontrol('Style','text','Position',[30 210 80 20],...
        'String','Setpoint:','HorizontalAlignment','right');
    editSetpoint = uicontrol('Style','edit','Position',[120 210 80 25],'String','0.16');
    
    % Pause Time (only for experimental mode)
    uicontrol('Style','text','Position',[30 170 80 20],...
        'String','Pause Time (s):','HorizontalAlignment','right','Tag','pauseLabel','Visible','off');
    editPauseTime = uicontrol('Style','edit','Position',[120 170 80 25],'String','300','Tag','pauseEdit','Visible','off');
    
    % Save File Name (for saving workspace data)
    uicontrol('Style','text','Position',[30 130 80 20],...
        'String','Save File:','HorizontalAlignment','right','Tag','saveLabel');
    editSaveFile = uicontrol('Style','edit','Position',[120 130 80 25],'String','workspace.mat','Tag','saveEdit');
    
    % Warning label for Experimental Mode
    warnLabel = uicontrol('Style','text','Position',[30 90 200 30],...
        'String','Warning: Ensure experimental setup is connected!',...
        'ForegroundColor',[1 0 0],'HorizontalAlignment','left','Visible','off','Tag','warnLabel');
    
    %% Multiple Gains Controls (right side)
    % Toggle for Multiple Gains mode
    multipleModeCheckbox = uicontrol('Style','checkbox',...
        'Position',[350 380 120 20],...
        'String','Multiple Gains',...
        'Value',0,...
        'Callback',@toggleMultipleMode);
    
    % Dropdown to select number of gain sets (visible only in multiple mode)
    uicontrol('Style', 'text', 'Position', [350 380 100 20],...
        'String', 'Number of Gains:', 'HorizontalAlignment','left', 'Visible','off','Tag','numGainsLabel');
    numGainsPopup = uicontrol('Style','popupmenu',...
        'Position',[450 380 40 20],...
        'String', {'1','2','3','4','5'},...
        'Value', 3,...
        'Visible','off',...
        'Callback', @updateTableData);
    
    % Toggle for plot type (comparison vs. individual) in multiple mode
    plotComparisonCheckbox = uicontrol('Style','checkbox',...
        'Position',[350 350 140 20],...
        'String','Plot in Comparison',...
        'Value',1,...
        'Enable','off',...
        'Visible','off');
    
    % Table for entering multiple gains (default 3 rows)
    defaultData = {0, 20, 0; 0, 50, 0; 0, 100, 0};
    uitableGains = uitable('Data', defaultData, ...
        'ColumnName', {'Kp','Ki','Kd'},...
        'ColumnEditable', [true true true],...
        'Position', [350, 150, 140, 180],...
        'Visible', 'off');
    
    %% New UI Controls: Elapsed Time Display and Abort Button
    % Timer display (top-right) -- moved downward (y-coordinate = 400)
    uicontrol('Style','text','Position',[350 400 120 25],...
        'String','Elapsed: 0 s','Tag','timeLabel');
    
    % Abort Button (placed next to the Run button)
    uicontrol('Style','pushbutton',...
        'Position',[360 50 150 40],...
        'String','Abort',...
        'Callback',@abortCallback);
    
    %% Run Simulation/Experiment Button (bottom left)
    uicontrol('Style','pushbutton',...
        'Position',[200 50 150 40],...
        'String','Run',...
        'Callback',@runCallback);
    
    %% Callback Functions
    function toggleMode(~,~)
        contents = get(modePopup, 'String');
        sel = contents{get(modePopup, 'Value')};
        if strcmp(sel, 'Experimental')
            set(findobj(fig,'Tag','pauseLabel'),'Visible','on');
            set(findobj(fig,'Tag','pauseEdit'),'Visible','on');
            set(warnLabel, 'Visible','on');
        else
            set(findobj(fig,'Tag','pauseLabel'),'Visible','off');
            set(findobj(fig,'Tag','pauseEdit'),'Visible','off');
            set(warnLabel, 'Visible','off');
        end
    end

    function toggleMultipleMode(~,~)
        if get(multipleModeCheckbox, 'Value') == 1
            hSingleLabels = findobj(fig,'Tag','singleLabel');
            hSingleEdits  = findobj(fig,'Tag','singleEdit');
            set(hSingleLabels, 'Visible','off');
            set(hSingleEdits, 'Visible','off');
            set(uitableGains, 'Visible','on');
            set(plotComparisonCheckbox, 'Enable','on','Visible','on');
            set(findobj(fig,'Tag','numGainsLabel'),'Visible','on');
            set(numGainsPopup, 'Visible','on');
        else
            hSingleLabels = findobj(fig,'Tag','singleLabel');
            hSingleEdits  = findobj(fig,'Tag','singleEdit');
            set(hSingleLabels, 'Visible','on');
            set(hSingleEdits, 'Visible','on');
            set(uitableGains, 'Visible','off');
            set(plotComparisonCheckbox, 'Enable','off','Visible','off');
            set(findobj(fig,'Tag','numGainsLabel'),'Visible','off');
            set(numGainsPopup, 'Visible','off');
        end
    end

    function updateTableData(~,~)
        contents = get(numGainsPopup, 'String');
        idx = get(numGainsPopup, 'Value');
        numRows = str2double(contents{idx});
        newData = repmat({0, 20, 0}, numRows, 1);
        set(uitableGains, 'Data', newData);
    end

    function runCallback(~,~)
        abortFlag = false;
        modeContents = get(modePopup, 'String');
        selectedMode = modeContents{get(modePopup, 'Value')};
        
        if strcmp(selectedMode, 'Experimental')
            runExperimental();
        else
            runSimulation();
        end
        
        % Save selected workspace data (avoid saving graphics objects)
        finalFileName = get(editSaveFile, 'String');
        if ~isempty(finalFileName)
            savedData.kp = evalin('base','kp');
            savedData.ki = evalin('base','ki');
            savedData.kd = evalin('base','kd');
            savedData.setpoint = evalin('base','setpoint');
            savedData.A = evalin('base','A');
            savedData.a = evalin('base','a');
            savedData.C = evalin('base','C');
            if evalin('base', 'exist(''height_sim'', ''var'')')
                savedData.height_sim = evalin('base','height_sim');
            end
            if evalin('base', 'exist(''simerror_calc'', ''var'')')
                savedData.simerror_calc = evalin('base','simerror_calc');
            end
            save(finalFileName, '-struct', 'savedData');
            fprintf('Selected workspace data saved to %s\n', finalFileName);
        else
            disp('No file name provided. Data not saved.');
        end
    end

    function abortCallback(~,~)
         abortFlag = true;
         try
             set_param(simModelName, 'SimulationCommand', 'stop');
         catch
         end
         try
             set_param(expModelName, 'SimulationCommand', 'stop');
         catch
         end
         disp('Abort button pressed. Simulation/Experiment aborted.');
    end

    %% Experimental Mode Callback
    function runExperimental()
        simTime = str2double(get(editSimTime, 'String'));
        ptime = str2double(get(editPauseTime, 'String'));
        setpoint = str2double(get(editSetpoint, 'String'));
        
        open_system(expModelPath);
        model = expModelName;
        set_param(model, 'SimulationMode', 'external');
        assignin('base','simTime', simTime);
        
        if get(multipleModeCheckbox, 'Value') == 1
            gainsData = get(uitableGains, 'Data');
            numExperiments = size(gainsData, 1);
        else
            numExperiments = 1;
            gainsData = {str2double(get(editKp, 'String')), ...
                         str2double(get(editKi, 'String')), ...
                         str2double(get(editKd, 'String'))};
        end
        
        exp_pi_height = cell(1, numExperiments);
        exp_pi_ht = cell(1, numExperiments);
        exp_error_calc = cell(1, numExperiments);
        exp_error_time = cell(1, numExperiments);
        exp_kp_g = cell(1, numExperiments);
        exp_ki_g = cell(1, numExperiments);
        exp_kd_g = cell(1, numExperiments);
        expLabels = cell(1, numExperiments);
        
        for iter = 1:numExperiments
            if abortFlag
                disp('Aborting experiments.');
                return;
            end
            
            if numExperiments == 1
                kp_val = gainsData{1};
                ki_val = gainsData{2};
                kd_val = gainsData{3};
            else
                kp_val = gainsData{iter,1};
                ki_val = gainsData{iter,2};
                kd_val = gainsData{iter,3};
            end
            
            fprintf('Experiment %d: Running with Kp = %g, Ki = %g, Kd = %g\n',...
                iter, kp_val, ki_val, kd_val);
            expLabels{iter} = sprintf('Exp %d: Kp=%g, Ki=%g, Kd=%g', iter, kp_val, ki_val, kd_val);
            
            assignin('base','kp', kp_val);
            assignin('base','ki', ki_val);
            assignin('base','kd', kd_val);
            assignin('base','m_on', 1);
            
            set_param(model, 'SimulationCommand', 'start');
            fprintf('External simulation started.\n');
            
            tStart = tic;
            while toc(tStart) < simTime
                pause(0.1);
                elapsed = toc(tStart);
                set(findobj(fig, 'Tag','timeLabel'),'String', sprintf('Elapsed: %.1f s', elapsed));
                drawnow;
                if abortFlag
                    set_param(model, 'SimulationCommand', 'stop');
                    disp('Experiment aborted during run.');
                    return;
                end
            end
            set_param(model, 'SimulationCommand', 'stop');
            fprintf('External simulation stopped.\n');
            assignin('base','m_on', 0);
            
            maxWaitTime = 10; elapsedTime = 0;
            while elapsedTime < maxWaitTime && ( ~evalin('base','exist(''pi_height'',''var'')') || ~evalin('base','exist(''error_calc'',''var'')') )
                pause(0.1);
                elapsedTime = elapsedTime + 0.1;
            end
            if ~evalin('base','exist(''pi_height'',''var'')')
                error('Variable pi_height did not appear within allotted time.');
            end
            if ~evalin('base','exist(''error_calc'',''var'')')
                error('Variable error_calc did not appear within allotted time.');
            end
            
            pi_height_ts  = evalin('base', 'pi_height');
            error_calc_ts = evalin('base', 'error_calc');
            kp_g_ts       = evalin('base', 'kp_g');
            ki_g_ts       = evalin('base', 'ki_g');
            kd_g_ts       = evalin('base', 'kd_g');
            
            exp_pi_height{iter} = squeeze(pi_height_ts.Data);
            exp_pi_ht{iter} = pi_height_ts.Time;
            exp_error_calc{iter} = squeeze(error_calc_ts.Data);
            exp_error_time{iter} = error_calc_ts.Time;
            exp_kp_g{iter} = squeeze(kp_g_ts.Data);
            exp_ki_g{iter} = squeeze(ki_g_ts.Data);
            exp_kd_g{iter} = squeeze(kd_g_ts.Data);
            
            fileName = sprintf('exp_kp%gki%gkd%g.mat', kp_val, ki_val, kd_val);
            save(fileName, 'exp_pi_height', 'exp_pi_ht', 'exp_error_calc', 'exp_error_time', 'exp_kp_g', 'exp_ki_g', 'exp_kd_g');
            fprintf('Saved experimental data to file: %s\n', fileName);
            
            if iter < numExperiments && ~abortFlag
                fprintf('Pausing for %d seconds to allow the tank to drain...\n', ptime);
                pause(ptime);
            end
        end
        
        if abortFlag
            disp('Experiment aborted. No plots generated.');
            return;
        end
        
        figure('Name','Height vs Time - Experimental Comparison','NumberTitle','off');
        hold on;
        for iter = 1:numExperiments
            plot(exp_pi_ht{iter}, exp_pi_height{iter}, 'LineWidth',1.5, 'DisplayName', expLabels{iter});
        end
        yline(0.1, 'r--','y = 0.1');
        xlabel('Time (s)');
        ylabel('Height (m)');
        title('Height Variation with Time (Experimental)');
        xlim([0, simTime]);
        legend('show','Location','Best');
        grid on;
        hold off;
        
        figure('Name','Error vs Time - Experimental Comparison','NumberTitle','off');
        hold on;
        for iter = 1:numExperiments
            plot(exp_error_time{iter}, exp_error_calc{iter}, 'LineWidth',1.5, 'DisplayName', expLabels{iter});
        end
        xlabel('Time (s)');
        ylabel('Error Calculation');
        title('Error Variation with Time (Experimental)');
        xlim([0, simTime]);
        legend('show','Location','Best');
        grid on;
        hold off;
        
        for iter = 1:numExperiments
            figure;
            hold on;
            plot(exp_pi_ht{iter}, exp_kp_g{iter}, '-r', 'LineWidth',1.0);
            plot(exp_pi_ht{iter}, exp_ki_g{iter}, '-g', 'LineWidth',1.0);
            plot(exp_pi_ht{iter}, exp_kd_g{iter}, '-b', 'LineWidth',1.0);
            xlabel('Time (s)');
            ylabel('Control Signal Contribution');
            title(sprintf('PID Contributions (Exp %d: Kp=%g, Ki=%g, Kd=%g)', iter, gainsData{iter,1}, gainsData{iter,2}, gainsData{iter,3}));
            legend('Proportional','Integral','Derivative','Location','Best');
            grid on;
            hold off;
        end
    end

    %% Simulation Mode Callback
    function runSimulation()
        simTime = str2double(get(editSimTime, 'String'));
        setpoint = str2double(get(editSetpoint, 'String'));
        C3 = 255*5;
        
        assignin('base','simTime', simTime);
        
        if get(multipleModeCheckbox, 'Value') == 1
            gainsData = get(uitableGains, 'Data');
            numExperiments = size(gainsData, 1);
        else
            numExperiments = 1;
            gainsData = {str2double(get(editKp, 'String')), ...
                         str2double(get(editKi, 'String')), ...
                         str2double(get(editKd, 'String'))};
        end
        
        % Prepare cell arrays to store raw simulation outputs if needed
        heightSimOut = cell(1, numExperiments);
        errorSimOut = cell(1, numExperiments);
        experimentLabels = cell(1, numExperiments);
        % Also prepare a structure "sim" to store extracted signal values
        sim = struct('h', {{}}, 'inflow_rate', {{}}, 'error_calc', {{}}, 'tout', {{}});
        
        for iter = 1:numExperiments
            if abortFlag
                disp('Simulation aborted.');
                return;
            end
            
            if numExperiments == 1
                rawKp = gainsData{1};
                rawKi = gainsData{2};
                kd_val = gainsData{3};
            else
                rawKp = gainsData{iter,1};
                rawKi = gainsData{iter,2};
                kd_val = gainsData{iter,3};
            end
            kp_val = rawKp * C3;
            ki_val = rawKi / C3;
            experimentLabels{iter} = sprintf('Exp %d: Kp=%g, Ki=%g, Kd=%g', iter, rawKp, rawKi, kd_val);
            
            A = pi*(0.15^2)/4;
            a = pi*(0.0035^2)/4;
            C = a*sqrt(2*9.81);
            g = 9.81;
            
            assignin('base','kp', kp_val);
            assignin('base','ki', ki_val);
            assignin('base','kd', kd_val);
            assignin('base','setpoint', setpoint);
            assignin('base','A', A);
            assignin('base','a', a);
            assignin('base','C', C);
            
            open_system(simModelPath);
            model = simModelName;
            
            tStart = tic;
            set_param(model, 'SimulationCommand', 'start');
            while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped')
                pause(0.1);
                elapsed = toc(tStart);
                set(findobj(fig, 'Tag','timeLabel'),'String', sprintf('Elapsed: %.1f s', elapsed));
                drawnow;
                if abortFlag
                    set_param(model, 'SimulationCommand', 'stop');
                    disp('Simulation aborted during run.');
                    return;
                end
            end
            
            % Wait for 2 seconds after simulation completes.
            pause(2);
            % Retrieve the complete simulation output stored in "out"
            if evalin('base', 'exist(''out'', ''var'')')
                out = evalin('base', 'out');
                % Extract each field’s Signals.Values and tout
                sim.h{iter} = out.height_sim.signals.values;
                sim.inflow_rate{iter} = out.sim_inflow_rate.signals.values;
                sim.error_calc{iter} = out.simerror_calc.signals.values;
                sim.tout{iter} = out.tout;
            else
                disp('Error retrieving simulation outputs: variable "out" does not exist.');
            end
            
            % Optionally, also save the raw outputs if desired.
            try
                heightSimOut{iter} = evalin('base','height_sim');
                errorSimOut{iter} = evalin('base','simerror_calc');
            catch
                disp('Error retrieving raw simulation outputs.');
            end
        end
        
        if abortFlag
            disp('Simulation aborted.');
            return;
        end
        
        if numExperiments > 1 && get(plotComparisonCheckbox, 'Value') == 1
            figure('Name','Height vs Time - Comparison','NumberTitle','off');
            hold on;
            for iter = 1:numExperiments
                % Use the extracted simulation data from sim.h
                timeVec = sim.tout{iter};
                dataVec = sim.h{iter};
                plot(timeVec, dataVec, 'LineWidth',1.5, 'DisplayName', experimentLabels{iter});
            end
            yline(setpoint, 'k--','Setpoint');
            xlabel('Time (s)');
            ylabel('Height (m)');
            title('Height Variation with Time (Comparison)');
            xlim([0, simTime]);
            ylim([0, 0.22]);
            legend('show','Location','best');
            grid on;
            hold off;
            
            figure('Name','Error vs Time - Comparison','NumberTitle','off');
            hold on;
            for iter = 1:numExperiments
                timeVec = sim.tout{iter};
                dataVec = sim.error_calc{iter};
                plot(timeVec, dataVec, 'LineWidth',1.5, 'DisplayName', experimentLabels{iter});
            end
            xlabel('Time (s)');
            ylabel('Error');
            title('Error Variation with Time (Comparison)');
            xlim([0, simTime]);
            ylim([-0.1, 0.22]);
            legend('show','Location','best');
            grid on;
            hold off;
        else
            for iter = 1:numExperiments
                figure('Name',sprintf('Height vs Time - %s', experimentLabels{iter}),'NumberTitle','off');
                timeVec = sim.tout{iter};
                dataVec = sim.h{iter};
                plot(timeVec, dataVec, 'b', 'LineWidth',1.5);
                hold on;
                yline(setpoint, 'k--','Setpoint');
                xlabel('Time (s)');
                ylabel('Height (m)');
                title(sprintf('Height Variation - %s', experimentLabels{iter}));
                xlim([0, simTime]);
                ylim([0, 0.22]);
                grid on;
                hold off;
                
                figure('Name',sprintf('Error vs Time - %s', experimentLabels{iter}),'NumberTitle','off');
                timeVec = sim.tout{iter};
                dataVec = sim.error_calc{iter};
                plot(timeVec, dataVec, 'r', 'LineWidth',1.5);
                xlabel('Time (s)');
                ylabel('Error');
                title(sprintf('Error Variation - %s', experimentLabels{iter}));
                xlim([0, simTime]);
                ylim([-0.1, 0.22]);
                grid on;
            end
        end
    end

    %% End of function; workspace data is saved using the filename provided.
end
