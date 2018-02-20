function [toursCell, finalTeamReward, avgLeftBgt] = CGW_algo_TOP(var1, var2, var3)

switch nargin
    case 1
        fileName = var1;
        [node, rwd, BGT] = read_ChaoGolden_dataset(fileName);
    case 3
        node = var1;
        rwd  = var2;
        BGT  = var3;
    otherwise
        disp('Error: The input of CGW_algo_TOP is wrong!!!!');
end

% -----test code-----
% clear; clc;
% fileName = 'p4.3.t.txt';
% [node, rwd, BGT] = read_ChaoGolden_dataset(fileName);
% ---x---x---x---x---

%% -----First stage: Initialization-----
[toursCell, toursCost, toursRwd] = CGW_initialize(node, rwd, BGT);

%% -----Second stage: Two-point exchange-----
[toursCell, toursCost, toursRwd, finalTeamReward] = CGW_two_point_exchange(node, rwd, BGT, toursCell, toursCost, toursRwd);

%% -----Third stage: One-point movement-----
[toursCell, toursCost, toursRwd, finalTeamReward] = CGW_one_point_movement(node, rwd, BGT, toursCell, toursCost, toursRwd);

%% -----Output-----
avgLeftBgt = BGT - sum(toursCost(1:3)) / 3;

%% Test code: plot the tours
% figure();
% plot(node(:,1),node(:,2),'x')
% hold on
% plot(node(1,1),node(1,2),'d')
% plot(node(toursCell{1},1),node(toursCell{1},2),'go')
% plot(node(toursCell{2},1),node(toursCell{2},2),'k>')
% plot(node(toursCell{3},1),node(toursCell{3},2),'r<')
% plot_tour_simple(toursCell{1}, node, rwd, BGT, 30)
% plot_tour_simple(toursCell{2}, node, rwd, BGT, 30)
% plot_tour_simple(toursCell{3}, node, rwd, BGT, 30)
% axis square