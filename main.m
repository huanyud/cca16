clear; clc; close all
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
problem = '3.3';
instanceVec = 'cdefghijklmnopqrst';
BGTVec = zeros(1, length(instanceVec));
ourTeamRwdVec    = zeros(1, length(instanceVec));
cgwTeamRwdVec    = zeros(1, length(instanceVec));
ourTimerVec      = zeros(1, length(instanceVec));
cgwTimerVec      = zeros(1, length(instanceVec));
ourAvgLeftBgtVec = zeros(1, length(instanceVec));
cgwAvgLeftBgtVec = zeros(1, length(instanceVec));
for num = 1:length(instanceVec)
    fileName = ['p', problem, '.', instanceVec(num),'.txt'];
    [node, rwd, BGT] = read_ChaoGolden_dataset(fileName);
    BGTVec(num) = BGT;
    % --our algorithm--
    tic;
    [~, ourTeamReward, ourAvgLeftBgt] = greedy_algo_TOP(fileName);
    ourTimerVec(num) = ourTimerVec(num) + toc;
    ourTeamRwdVec(num) = ourTeamReward;
    ourAvgLeftBgtVec(num) = ourAvgLeftBgt;
%     saveas(gcf, ['results_team_orienteering/tours/p', problem, '.', instanceVec(num), '.png']);  % Save tour figures
%     saveas(gcf, ['results_team_orienteering/tours/p', problem, '.', instanceVec(num), '.fig']);  % Save tour figures
%     close gcf;
    % --Chao-Golden-Wasil algorithm for TOP--
    tic;
    [~, cgwTeamReward, cgwAvgLeftBgt] = CGW_algo_TOP(fileName);
    cgwTimerVec(num) = cgwTimerVec(num) + toc;
    cgwTeamRwdVec(num) = cgwTeamReward;
    cgwAvgLeftBgtVec(num) = cgwAvgLeftBgt;
end
plot(BGTVec, ourTeamRwdVec, 'ko-'); hold on;
plot(BGTVec, cgwTeamRwdVec, 'bx--');
xlabel('Budget');
ylabel('Team reward');
title(['Set ', problem]);
legend('New algorithm for TOP', 'CGW algorithm for TOP');
saveas(gcf, ['results_team_orienteering/p', problem, '.comparison.fig']);  % Save tour figures

RESULT_TABLE = [
                 ourTeamRwdVec;
                 cgwTeamRwdVec;
                 ourTimerVec;
                 cgwTimerVec;
                 ourAvgLeftBgtVec;
                 cgwAvgLeftBgtVec
               ];
save('tempRESULT.mat', 'RESULT_TABLE');
clear;
load('tempRESULT.mat', 'RESULT_TABLE');
