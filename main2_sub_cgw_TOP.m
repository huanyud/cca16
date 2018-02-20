function [tmpCgwAvgReward, tmpCgwAvgMisDet, tmpCgwAvgFalAla, tmpCgwAvgLeftBgt] = main2_sub_cgw_TOP(experimentalData, BGTScala)

rewardCounter = 0;
misDetCounter = 0;
truPosCounter = 0;
falAlaCounter = 0;
truNegCounter = 0;
leftBgtAccumulator = 0;
totalDataNum = size(experimentalData, 3);
for datasetNo = 1:totalDataNum
    node = zeros(size(experimentalData,1), 3);
    node(:, 1:2)   = experimentalData(:, 1:2, datasetNo);
    node(2:end, 3) = 3 * ones(size(experimentalData,1)-1, 1);
    rwd = experimentalData(:, 3, datasetNo)';
    % rwd = -rwd.*log2(rwd)-(1-rwd).*log2(1-rwd);
    predLabel = experimentalData(:, 4, datasetNo);
    trueLabel = experimentalData(:, 5, datasetNo);
    diffOfLabel = predLabel - trueLabel;
    
    [toursCell, cgwReward, avgLeftBgt] = CGW_algo_TOP(node, rwd, BGTScala);
    cgwTour = [toursCell{1}, toursCell{2}, toursCell{3}];
    rewardCounter = rewardCounter + cgwReward;
    misDetCounter = misDetCounter + (sum(diffOfLabel == -1) - sum(diffOfLabel(cgwTour) == -1));
    truPosCounter = truPosCounter + sum(trueLabel == 1);
    falAlaCounter = falAlaCounter + (sum(diffOfLabel ==  1) - sum(diffOfLabel(cgwTour) ==  1));
    truNegCounter = truNegCounter + sum(trueLabel == 0);
    leftBgtAccumulator = leftBgtAccumulator + avgLeftBgt;
end

tmpCgwAvgReward  = rewardCounter / totalDataNum;
tmpCgwAvgMisDet  = misDetCounter / truPosCounter;
tmpCgwAvgFalAla  = falAlaCounter / truNegCounter;
tmpCgwAvgLeftBgt = leftBgtAccumulator / totalDataNum;