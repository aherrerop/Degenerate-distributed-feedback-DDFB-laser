%% Eigenmode_3D_DBE_Finder_Script
clear all; close all; clc
% Info about eigenmode solver: https://space.mit.edu/RADIO/CST_online/mergedProjects/VBA_3D/special_vbasolver/special_vbasolver_eigenmodesolver_object.htm
%% Prepare 
    % Initialize parameters
% Set parameters
claddingSize = 700; % In nm
owgWidth = 450; % In nm
owgHeight = 220; % In nm

% Variables
period = 260; % In nm
gapSize = 50;
teethShift = period/2; % In nm
teethWidth = 50; % In nm
teethHeight = 50; % In nm

% Initial sigma values
sigma = 21e25;
F1 = 193.54;

global S
S.sigma = sigma;
S.F1 = F1;
S.teethWidth = teethWidth;
S.teethShift = teethShift;
S.teethHeight = teethHeight;
S.period = period;
S.gapSize = gapSize;

% Parametric sweep
Phase_Z_Min = 160;
Phase_Z_Max = 200;
Phase_Z_Length = 11;

    % Create the simulation from "DDFB_FD_Active_NXX.cst"
path=pwd; % Get the folder path of this m.file
filename=strcat('Eigenmode_DBE_DG_',num2str(Phase_Z_Min),'-',num2str(Phase_Z_Max),'-',num2str(Phase_Z_Length),'.cst'); % Name of CST file
status = copyfile('Eigenmode_DG_DBE_Template.cst', filename);
fullname=[path '\' filename];

    % Connect MATLAB and CST
cst = actxserver('CSTStudio.Application');

    % Define global variables
global mws EigenmodeSolver Phase_Z_vec Function_Counter Results_filename

Function_Counter = 1; % Counter in the function
Phase_Z_vec = linspace(Phase_Z_Min,Phase_Z_Max,Phase_Z_Length); % Vector with different Phase_Z
Results_filename = 'Test1_FiveVariables.csv';

    % Open CST, open the file
[cst,mws] = OpenCST(fullname);
EigenmodeSolver = invoke(mws,'EigenmodeSolver');
EigenmodeSolver.invoke('SetStoreResultsInCache','False');
% EigenmodeSolver.invoke('FrequencyRange',centerFreq - deltaFreq, centerFreq + deltaFreq);

    % Parametric Sweep
A = mws.invoke('ParameterSweep'); % Open parametric sweep
A.invoke('DeleteAllSequences'); % Delete old sequences

mws.invoke('StoreDoubleParameter','ac_claddingSize',claddingSize); % Change the parameter
mws.invoke('StoreDoubleParameter','period',period); % Change the parameter
mws.invoke('StoreDoubleParameter','teethShift',teethShift); % Change the parameter
mws.invoke('StoreDoubleParameter','teethWidth',teethWidth); % Change the parameter
mws.invoke('StoreDoubleParameter','teethHeight',teethHeight); % Change the parameter
mws.invoke('StoreDoubleParameter','owgHeight',owgHeight); % Change the parameter
mws.invoke('StoreDoubleParameter','owgWidth',owgWidth); % Change the parameter
mws.invoke('Rebuild'); % Equivalent to pressing F7

% Initial guess
X0 = [teethWidth, teethShift, teethHeight, period, gapSize];
opts = optimset('MaxIter',1000, 'Display','none');
% Gives X at the DBE. Sigma is the eigenvector coalescence parameter (the more similar the
% eigenvalues, the smaller it is (tends to zero)).
[X,sigma, exitflag] = fminsearch(@Eigenmode_DBE_DG_Function_FiveVariables_v1, X0, opts);
display(strcat('fminsearch sweep is finished'));
display(strcat('exitflag: ',num2str(exitflag)));
if exitflag>0
    teethWidth_vec = X(1);
    teethShift_vec = X(2);
    teethHeight_vec = X(3);
    period_vec = X(4);
    gapSize = X(5);
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
owgHeight_min = S.owgHeight(index_min);
teethWidth_min = S.teethWidth(index_min);
teethShift_min = S.teethShift(index_min);
teethHeight_min = S.teethHeight(index_min);
periodUnitCell_min = S.periodUnitCell(index_min);

