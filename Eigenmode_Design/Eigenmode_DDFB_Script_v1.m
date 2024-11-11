%% Eigenmode_3D_DBE_Finder_Script
clear all; close all; clc
% Info about eigenmode solver: https://space.mit.edu/RADIO/CST_online/mergedProjects/VBA_3D/special_vbasolver/special_vbasolver_eigenmodesolver_object.htm
%% Prepare 
    % Initialize parameters
% Variables
period = 265.12;
teethHeight = 100;
gapSize = 50;
teethShift = 61.8;
teethThickness = 100;

% Initial values
target_freq = 193.54;
Phase_Z = 160;
sigma = 1e3;
F3 = target_freq;

    % Define global variables
global mws EigenmodeSolver Function_Counter filename S Results_filename

% Saving initial data
S.sigma = sigma;
S.teethWidth = teethWidth;
S.teethShift = teethShift;
S.owgWidth = owgWidth;
S.period = period;
S.F3 = F3;

    % Create the simulation from the template
path=pwd; % Get the folder path of this m.file
filename='Eigenmode_ThinDG_ModeCoalescenceOptimization'; % Name of CST file
% status = copyfile('Eigenmode_CW_Tripleteeth_Template.cst', [filename '.cst']);
fullname=[path '\' filename '.cst'];

    % Connect MATLAB and CST
cst = actxserver('CSTStudio.Application');

Function_Counter = 1; % Counter in the function
Results_filename = 'Results_CW_Tripleteeth_ModeOptimization_v1.csv';

    % Open CST, open the file
[cst,mws] = OpenCST(fullname);
EigenmodeSolver = invoke(mws,'EigenmodeSolver');
EigenmodeSolver.invoke('SetStoreResultsInCache','False');
% EigenmodeSolver.invoke('FrequencyRange',centerFreq - deltaFreq, centerFreq + deltaFreq);

    % Parametric Sweep
A = mws.invoke('ParameterSweep'); % Open parametric sweep
A.invoke('DeleteAllSequences'); % Delete old sequences

mws.invoke('StoreDoubleParameter','teethHeight',teethHeight); % Change the parameter
mws.invoke('StoreDoubleParameter','teethShift',teethShift); % Change the parameter
mws.invoke('StoreDoubleParameter','teethThickness',teethThickness); % Change the parameter
mws.invoke('StoreDoubleParameter','period',period); % Change the parameter
mws.invoke('StoreDoubleParameter','gapSize',gapSize); % Change the parameter
mws.invoke('StoreDoubleParameter','Phase_Z',Phase_Z); % Change the parameter
mws.invoke('Rebuild'); % Equivalent to pressing F7

% Initial guess
X0 = [teethHeight, teethShift, teethThickness, period, gapSize];
opts = optimset('MaxIter',1e5, 'Display','none');
% Gives X at the DBE. Sigma is the eigenvector coalescence parameter (the more similar the
% eigenvalues, the smaller it is (tends to zero)).
[X,sigma, exitflag] = fminsearch(@Eigenmode_CW_Function_v1, X0, opts);
display(strcat('fminsearch sweep is finished'));
display(strcat('exitflag: ',num2str(exitflag)));
if exitflag>0
    teethWidth_vec = X(1);
    shortteethWidth_vec = X(2);
    owgWidth_vec = X(3);
    period_vec = X(4);
    sigma_vec = sigma;
end

%% Notify
% Send notification when done
Email_ID = 'aherrero.jmzafra';
Subject = strcat('Simulation ','Eigenmode',' is finished');
Message = '';

send_mail_message(Email_ID, Subject, Message);

%% Best DBE?
[sigma_min,index_min] = min(S.sigma);
owgWidth_min = S.owgWidth(index_min);
teethWidth_min = S.teethWidth(index_min);
shortteethWidth_min = S.shortteethWidth(index_min);
period_min = S.period(index_min);

