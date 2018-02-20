function [tspTour_1, tspTour_2, tspTour_3, unsel, finalReward] = greedy_algo_TOP_old(fileName)

% -----test code-----
% clear; clc;
% fileName = 'p4.3.b.txt';
% ---x---x---x---x---

[node, rwd, BGT] = read_ChaoGolden_dataset(fileName);
alpha = 1/2;

%% -----First stage: Grow 3 subtrees of cost within alpha*BGT-----
[sel_1, sel_2, sel_3, unsel] = tree_grow(node, rwd, BGT, alpha);

%% -----Second stage: Find 3 tours using LKH algorithm-----
% If no more node to add, then quit
if length(unsel) <= 0
    finalReward = sum(rwd([sel_1 sel_2 sel_3]));
    return;
end

% Run LKH to find 3 tours
for whichTour = 1:3
    eval(sprintf('len = length(sel_%d)', whichTour));
    if len > 3
        eval(sprintf('write_lkh_input(node, sel_%d, 10)', whichTour));
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

        eval(sprintf('tspTour_%d = read_lkh_output(sel_%d)', whichTour, whichTour));
    else
        eval(sprintf('tspTour_%d = sel_%d', whichTour, whichTour));
    end
end

%test
total1 = sum(rwd([sel_1 sel_2 sel_3]));

%% -----Third Stage: Further exploitation using the given budget-----
% Compute the 3 tour costs
tourCost_1 = get_tour_cost(node, tspTour_1);
tourCost_2 = get_tour_cost(node, tspTour_2);
tourCost_3 = get_tour_cost(node, tspTour_3);
tourCost   = [tourCost_1, tourCost_2, tourCost_3];

% -----test code-----
if (tourCost_1 > BGT || tourCost_2 > BGT || tourCost_3 > BGT)
    disp('Error: Exceed the budget limit!');
    disp(tourCost_1 - BGT);
    disp(tourCost_2 - BGT);
    disp(tourCost_3 - BGT);
    pause();
end
% ---x---x---x---x---

% Further exploitation of the leftover budget
hasMoreBgt_1 = true;
hasMoreBgt_2 = true;
hasMoreBgt_3 = true;
while (~isempty(unsel) && (hasMoreBgt_1 || hasMoreBgt_2 || hasMoreBgt_3))
    if (hasMoreBgt_1)
        [hasMoreBgt_1, sel_1, tspTour_1, tourCost_1] = further_exploit_once_TOP_old(node, rwd, BGT, sel_1, unsel, tspTour_1, tourCost_1);
        unsel = setdiff(1:size(node,1), [sel_1 sel_2 sel_3]);
    end
    if (hasMoreBgt_2)
        [hasMoreBgt_2, sel_2, tspTour_2, tourCost_2] = further_exploit_once_TOP_old(node, rwd, BGT, sel_2, unsel, tspTour_2, tourCost_2);
        unsel = setdiff(1:size(node,1), [sel_1 sel_2 sel_3]);
    end    
    if (hasMoreBgt_3)
        [hasMoreBgt_3, sel_3, tspTour_3, tourCost_3] = further_exploit_once_TOP_old(node, rwd, BGT, sel_3, unsel, tspTour_3, tourCost_3);
        unsel = setdiff(1:size(node,1), [sel_1 sel_2 sel_3]);
    end
end

if (tourCost_1 > BGT || tourCost_2 > BGT || tourCost_3 > BGT)
    disp('Error: Exceed the budget limit!');
    disp(tourCost_1 - BGT);
    disp(tourCost_2 - BGT);
    disp(tourCost_3 - BGT);
    pause();
end

%test
total2 = sum(rwd([sel_1 sel_2 sel_3]));
improve = total2- total1

finalReward = sum(rwd([sel_1 sel_2 sel_3]));

%% Test code: plot the tours
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