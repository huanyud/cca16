function [toursCell, finalTeamReward, avgLeftBgt] = greedy_algo_TOP(var1, var2, var3)

switch nargin
    case 1
        fileName = var1;
        [node, rwd, BGT] = read_ChaoGolden_dataset(fileName);     
    case 3
        node = var1;
        rwd  = var2';
        BGT  = var3;
    otherwise
        disp('Error: The input of greedy_algo_TOP is wrong!!!!');
end

% -----test code-----
% clear; clc;
% fileName = 'p4.3.t.txt';
% [node, rwd, BGT] = read_ChaoGolden_dataset(fileName);
% ---x---x---x---x---

alpha = 1/2;

%% -----First stage: Grow 3 subtrees of cost within alpha*BGT-----
[sel_1, sel_2, sel_3, unsel] = tree_grow(node, rwd, BGT, alpha);

%% -----Second stage: Find 3 tours using LKH algorithm-----
% Run LKH to find 3 tours
for whichTour = 1:3
    eval(sprintf('len = length(sel_%d);', whichTour));
    if len > 3
        eval(sprintf('write_lkh_input(node, sel_%d, 5);', whichTour));
        %system('lkh.exe lkhInput.par');

        % Create a temporary file to store the return command
        fname = tempname;
        % Check for the existence of the temp file and if there is one, create a new one instead
        while exist(fname,'file')
            fname = tempname;
        end

        fid = fopen(fname, 'wt');
        fprintf(fid,'\r'); % Here we enter the carriage return needed to kill the program
        fclose(fid);

        system(['lkh.exe lkhInput.par < ' fname]);
        % Here the < actually means whatever in fname is being passed into the exe as inputs
        delete(fname);

        eval(sprintf('tspTour_%d = read_lkh_output(sel_%d);', whichTour, whichTour));
    else
        eval(sprintf('tspTour_%d = sel_%d;', whichTour, whichTour));
    end
end

% -----test code-----
total1 = sum(rwd([tspTour_1 tspTour_2 tspTour_3]));
% ---x---x---x---x---

%% -----Third Stage: Further exploitation using the given budget-----
% Compute the 3 tour costs
tourCost_1 = get_tour_cost(node, tspTour_1);
tourCost_2 = get_tour_cost(node, tspTour_2);
tourCost_3 = get_tour_cost(node, tspTour_3);

% -----test code-----
if (tourCost_1 > BGT || tourCost_2 > BGT || tourCost_3 > BGT)
    disp('Error: Exceed the budget limit!');
    disp(tourCost_1 - BGT);
    disp(tourCost_2 - BGT);
    disp(tourCost_3 - BGT);
    pause();
end
% ---x---x---x---x---

toursCell = {tspTour_1, tspTour_2, tspTour_3};           % Cell array
toursCost = [tourCost_1, tourCost_2, tourCost_3];        % 1-D array
% Further exploitation of the leftover budget
areAllSaturated = true;
while (~isempty(unsel) && ~areAllSaturated)
    if (areAllSaturated)
        [areAllSaturated, unsel, toursCell, toursCost] = further_exploit_once_TOP(node, rwd, BGT, unsel, toursCell, toursCost);
        ans=1;
    end
end

if (tourCost_1 > BGT || tourCost_2 > BGT || tourCost_3 > BGT)
    disp('Error: Exceed the budget limit!');
    disp(tourCost_1 - BGT);
    disp(tourCost_2 - BGT);
    disp(tourCost_3 - BGT);
    pause();
end

% -----test code-----
if (tourCost_1 > BGT || tourCost_2 > BGT || tourCost_3 > BGT)
    disp('Error: Exceed the budget limit!');
    disp(tourCost_1 - BGT);
    disp(tourCost_2 - BGT);
    disp(tourCost_3 - BGT);
    pause();
end
% ---x---x---x---x---

% -----test code-----
% total2 = sum(rwd([tspTours{1}, tspTours{2}, tspTours{3}]));
% improve1 = total2- total1
% ---x---x---x---x---

%% -----Fourth Stage: Perform one-point and two-point tour exchange-----
% toursRwd = [sum(rwd(toursCell{1})),
%             sum(rwd(toursCell{2})),
%             sum(rwd(toursCell{3}))];
% [toursCell, toursCost, toursRwd] = two_point_exchange(node, rwd, BGT, toursCell, toursCost, toursRwd);

% -----test code-----
% total3 = sum(rwd([tspTours{1}, tspTours{2}, tspTours{3}]));
% improve2 = total3- total2
% ---x---x---x---x---

%% -----Output-----
finalTeamReward = sum(rwd([toursCell{1}, toursCell{2}, toursCell{3}]));
avgLeftBgt = BGT - sum(toursCost(1:3)) / 3;

%% Test code: plot the tours
% figure();
% plot(node(:,1),node(:,2),'x')
% hold on
% plot(node(1,1),node(1,2),'d')
% plot(node(sel_1,1),node(sel_1,2),'go')
% plot(node(sel_2,1),node(sel_2,2),'k>')
% plot(node(sel_3,1),node(sel_3,2),'r<')
% plot_tour_simple(tspTour_1, node, rwd, BGT, 30)
% plot_tour_simple(tspTour_2, node, rwd, BGT, 30)
% plot_tour_simple(tspTour_3, node, rwd, BGT, 30)
% axis square