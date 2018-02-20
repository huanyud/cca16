%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('satImageData_v5.mat');  % The chosen dataset is 'satImageData_v5.mat'
BGTVec = [20:20:80];
ourAvgReward  = zeros(1,length(BGTVec));
ourAvgMisDet  = zeros(1,length(BGTVec));
ourAvgFalAla  = zeros(1,length(BGTVec));
cgwAvgReward  = zeros(1,length(BGTVec));
cgwAvgMisDet  = zeros(1,length(BGTVec));
cgwAvgFalAla  = zeros(1,length(BGTVec));
ourTimer      = zeros(1,length(BGTVec));
cgwTimer      = zeros(1,length(BGTVec));
ourAvgLeftBgt = zeros(1,length(BGTVec));
cgwAvgLeftBgt = zeros(1,length(BGTVec));
for bgtNo = 1:length(BGTVec)
    % --our TOP algorithm--
    tic;
    [tmpOurAvgReward, tmpOurAvgMisDet, tmpOurAvgFalAla, tmpOurAvgLeftBgt] = main2_sub_greedy_TOP(experimentalData, BGTVec(bgtNo));
    ourTimer(bgtNo) = ourTimer(bgtNo) + toc;
    ourAvgReward(bgtNo)  = tmpOurAvgReward;
    ourAvgMisDet(bgtNo)  = tmpOurAvgMisDet;
    ourAvgFalAla(bgtNo)  = tmpOurAvgFalAla;
    ourAvgLeftBgt(bgtNo) = tmpOurAvgLeftBgt;
%     % --Chao-Golden-Wasil TOP algorithm--
%     tic;
%     [tmpCgwAvgReward, tmpCgwAvgMisDet, tmpCgwAvgFalAla, tmpCgwAvgLeftBgt] = main2_sub_cgw_TOP(experimentalData, BGTVec(bgtNo));
%     cgwTimer(bgtNo) = cgwTimer(bgtNo) + toc;
%     cgwAvgReward(bgtNo)  = tmpCgwAvgReward;
%     cgwAvgMisDet(bgtNo)  = tmpCgwAvgMisDet;
%     cgwAvgFalAla(bgtNo)  = tmpCgwAvgFalAla;
%     cgwAvgLeftBgt(bgtNo) = tmpCgwAvgLeftBgt;
end

RESULT_TABLE = [ 
                 BGTVec;
                 ourAvgReward;
                 cgwAvgReward;
                 ourAvgMisDet;
                 cgwAvgMisDet;
                 ourAvgFalAla;
                 cgwAvgFalAla;
                 ourTimer;
                 cgwTimer;
                 ourAvgLeftBgt;
                 cgwAvgLeftBgt;
               ];

save('tempRESULT.mat', 'RESULT_TABLE');
clear;
load('tempRESULT.mat', 'RESULT_TABLE');
