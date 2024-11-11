function [sigma] = Eigenmode_DDFB_Function_v1(X)

% Initialize parameters
teethHeight = X(1);
teethShift = X(2);
teethThickness = X(3);
period = X(4);
gapSize = X(5);

global mws EigenmodeSolver Function_Counter filename Results_filename S

% Update parameters
mws.invoke('StoreDoubleParameter','teethHeight',teethHeight); % Change the parameter
mws.invoke('StoreDoubleParameter','teethShift',teethShift); % Change the parameter
mws.invoke('StoreDoubleParameter','teethThickness',teethThickness); % Change the parameter
mws.invoke('StoreDoubleParameter','period',period); % Change the parameter
mws.invoke('StoreDoubleParameter','gapSize',gapSize); % Change the parameter
mws.invoke('StoreDoubleParameter','Phase_Z',Phase_Z); % Change the parameter
mws.invoke('Rebuild'); % Equivalent to pressing F7

% Run simulation
EigenmodeSolver.invoke('Start');

fullpathexports = ['C:\Users\AHerrero\Documents\GitHub\FullWave-SIP-Waveguide\Corrugated_Waveguide\3D\Eigenmode\' filename '\Export\3d'];

% Calculate coalescence parameter
[Coalescence_Parameter] = CW_Check_ModeFieldCoalescence(fullpathexports);
    

% Enforce Constraints
if owgWidth < 100 || teethWidth < 100 || shortteethWidth < 100|| period < 300
    Coalescence_Parameter = 1e3;
end

% If we change Phase_Z
% Read frequency. How do we set Phase_Z? As the Phase_Z where freq(")
% \approx 193.54 THz.
freq(1) = EigenmodeSolver.invoke('GetModeFrequencyInHz',1); 
freq(2) = EigenmodeSolver.invoke('GetModeFrequencyInHz',2);
freq(3) = EigenmodeSolver.invoke('GetModeFrequencyInHz',3);
freq(4) = EigenmodeSolver.invoke('GetModeFrequencyInHz',4);

target_freq = 193.54e12;
% Phase_Z = (target_freq/freq(2))*Phase_Z;

% if freq(1) < 180e12 || freq(4) > 210e12
%     Coalescence_Parameter = 1e3;
% end

sigma = Coalescence_Parameter;

% Display results
display(strcat(num2str(Function_Counter),' Coal.Param: ',num2str(Coalescence_Parameter)));
display(strcat('teethWidth: ',num2str(teethWidth)));
display(strcat('shortteethWidth: ',num2str(shortteethWidth)));
display(strcat('owgWidth: ',num2str(owgWidth)));
display(strcat('period: ',num2str(period)));
display(strcat('freq mode 2: ',num2str(freq(2)*1e-12),'THz'));
Function_Counter = Function_Counter + 1;

% Saving data
S.sigma = [S.sigma; sigma];
S.teethWidth = [S.teethWidth; teethWidth];
S.shortteethWidth = [S.shortteethWidth; shortteethWidth];
S.owgWidth = [S.owgWidth; owgWidth];
S.period = [S.period; period];
S.F2 = [S.F2; freq(2)*1e-12];

% Write file
T = struct2table(S);
writetable(T,Results_filename);


end
