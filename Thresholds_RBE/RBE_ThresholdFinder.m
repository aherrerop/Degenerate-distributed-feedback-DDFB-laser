%
clear all; close all; clc

%%
clc
%
numberCells_vec = [60, 80, 100, 120];
lb = [0, 0, 0, 0];
ub = [3000, 2000, 600, 400];
delta_freq = [0.5, 0.3, 0.1, 0.05];
freq_RBE = 190.04; % In THz
Tolerance = 1;

% Initialize arrays to store gain values and corresponding peak S21 values
all_gain_values = [];
all_S21_peaks = [];

% Connect MATLAB and CST
cst = actxserver('CSTStudio.Application.2021');
% Create and open the file
path = pwd;

for ii = 1:length(numberCells_vec)

    numberCells = numberCells_vec(ii);
    disp(['Number of unit cells :', num2str(numberCells)]);
    % % Create new file for N
    filename = strcat('Threshold_RBE_N_', num2str(numberCells), '_CM_v-2.cst');
    status = copyfile('Freq_RBE_NXX_CM_v-1.cst', filename);
    fullname = [path '\' filename];
    [cst, mws] = OpenCST_2021(fullname);
    

    % Initial gain range
    gain_range = [lb(ii), ub(ii)];
    
    while abs(gain_range(2) - gain_range(1)) > Tolerance  % Stopping criterion
        % Generate 5 equally spaced gain values within the current gain range
        gain_values = linspace(gain_range(1), gain_range(2), 5);
        S21_peaks = zeros(1, 5);

        for jj = 1:5
            gain_value = gain_values(jj);
            % Update simulation parameters
            mws.invoke('StoreDoubleParameter', 'centerFreq', freq_RBE);
            mws.invoke('StoreDoubleParameter', 'Ncells', numberCells);
            mws.invoke('StoreDoubleParameter', 'aa_bulkGain', gain_value);
            mws.invoke('StoreDoubleParameter', 'freq_delta', delta_freq(ii));
            mws.invoke('Rebuild');  % Equivalent to pressing F7
            
            disp(['Starting simulation. Gain value is :', num2str(gain_value)]);

            % Run the simulation
            hSolver = invoke(mws, 'FDSolver');
            hSolver.invoke('Start');
            
            % Extract S21 results
            
            ResultTree = mws.invoke('Resulttree');
            Results_S21_11 = ResultTree.invoke('GetResultFromTreeItem', '1D Results\S-Parameters\S2,1', '3D:RunID:0');
            Real_S21_11 = Results_S21_11.invoke('GetArray', 'yre');
            Imag_S21_11 = Results_S21_11.invoke('GetArray', 'yim');
            S21_11 = Real_S21_11 + 1i * Imag_S21_11;
            Log_S21_11 = 20 * log10(abs(S21_11));  % Calculate log magnitude of S21
            
            % Find the peak of Log_S21_11 and store it
            S21_peaks(jj) = max(Log_S21_11);  
        end

        % Append gain values and corresponding S21 peaks to the arrays
        all_gain_values = [all_gain_values, gain_values];
        all_S21_peaks = [all_S21_peaks, S21_peaks];

        % Find the index of the gain value with the maximum S21 peak
        [~, max_index] = max(S21_peaks);
        disp(['Updated maximum gain :', num2str(gain_values(max_index))]);
        % Adjust gain range based on the position of max_index
        if max_index == 1
            % Max is at the lower bound, extend the lower range slightly
            new_lower = gain_values(1) - (gain_values(2) - gain_values(1)) / 2;
            gain_range = [new_lower, gain_values(2)];
        elseif max_index == 5
            % Max is at the upper bound, extend the upper range slightly
            new_upper = gain_values(5) + (gain_values(5) - gain_values(4)) / 2;
            gain_range = [gain_values(4), new_upper];
        else
            % Set range around the max gain value
            gain_range = [gain_values(max_index - 1), gain_values(max_index + 1)];
        end
        disp(['Updated gain range: ',num2str(gain_values(1)), num2str(gain_values(2)]);
    end
end

% At the end, all_gain_values will contain all tested gains,
% and all_S21_peaks will contain the corresponding peak values of S21.
