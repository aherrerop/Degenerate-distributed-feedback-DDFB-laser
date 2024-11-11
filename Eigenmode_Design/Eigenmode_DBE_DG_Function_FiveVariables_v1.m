function [sigma_3] = Eigenmode_DBE_DG_Function_FiveVariables_v1(X)

% Initialize parameters
teethWidth = X(1);
teethShift = X(2);
teethHeight = X(3);
period = X(4);
gapSize = X(5);

global mws EigenmodeSolver Phase_Z_vec Function_Counter S Results_filename

mws.invoke('StoreDoubleParameter','teethShift',teethShift); % Change the parameter
mws.invoke('StoreDoubleParameter','teethWidth',teethWidth); % Change the parameter
mws.invoke('StoreDoubleParameter','teethHeight',teethHeight); % Change the parameter
mws.invoke('StoreDoubleParameter','period',period); % Change the parameter
mws.invoke('StoreDoubleParameter','gapSize',gapSize); % Change the parameter
mws.invoke('Rebuild'); % Equivalent to pressing F7

F = zeros(4,length(Phase_Z_vec));
for ii = 1:length(Phase_Z_vec)
    mws.invoke('StoreDoubleParameter','Phase_Z',Phase_Z_vec(ii)); % Change the parameter
    mws.invoke('Rebuild'); % Equivalent to pressing F7

    EigenmodeSolver.invoke('Start');
    
    F(1,ii) = EigenmodeSolver.invoke('GetModeFrequencyInHz',1); 
    F(2,ii) = EigenmodeSolver.invoke('GetModeFrequencyInHz',2); 
    F(3,ii) = EigenmodeSolver.invoke('GetModeFrequencyInHz',3); 
    F(4,ii) = EigenmodeSolver.invoke('GetModeFrequencyInHz',4); 
    
    display(strcat(num2str(ii),'/',num2str(length(Phase_Z_vec))));
end

for jj = 1:4
    Derivative_F(jj,:) = diff(F(jj,:))./diff(Phase_Z_vec(1:2));
    Average_F(jj) = mean(F(jj,:));
    Average_DerF(jj) = mean(Derivative_F(jj,:));
    
    [F_max(jj,:), index_max(jj,:)] = max(F(jj,:));
    [F_min(jj,:), index_min(jj,:)] = min(F(jj,:));
    F_ave_max(jj) = F_max(jj,1) - F_min(jj,1);
    
    F_std_dev(jj) = std(F(jj,:));
    
end

% Sigma
sigma = F_std_dev(1);
sigma_2 = abs(Average_DerF(1));
sigma_3 = abs(F_ave_max(1));

% Get frequency between 193 & 194
F1 = F(1,round(length(F(1,:))/2));
% if F1 < 190e12 || F1 > 210e12
%     sigma = 1e20;
%     sigma_2 = 1e20;
%     sigma_3 = 1e20;
% end

% Display results
display(strcat(num2str(Function_Counter),' sigma: ',num2str(sigma_3*1e-12)));
display(strcat('teethWidth: ',num2str(teethWidth)));
display(strcat('teethShift: ',num2str(teethShift)));
display(strcat('teethHeight: ',num2str(teethHeight)));
display(strcat('period: ',num2str(period)));
display(strcat('gapSize: ',num2str(gapSize)));
display(strcat('DBE freq: ',num2str(F1*1e-12),'THz'));
Function_Counter = Function_Counter + 1;

% Saving data
S.sigma = [S.sigma; sigma_3*1e-12];
S.teethWidth = [S.teethWidth; teethWidth];
S.teethShift = [S.teethShift; teethShift];
S.teethHeight = [S.teethHeight; teethHeight];
S.period = [S.period; period];
S.gapSize = [S.gapSize; gapSize];
S.F1 = [S.F1; F1*1e-12];

% Write file
T = struct2table(S);
writetable(T,Results_filename);

end
