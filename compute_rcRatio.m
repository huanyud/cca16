function [rcRatio, connCost, knnIdx] = compute_rcRatio(node, rwd, unsel, sel_1, sel_2, sel_3)

nodesUnsel = node(unsel, :);

% Compute the reward-cost ratio for un-selected node subset with respect to the 1st branch
nodesSel_1 = node(sel_1(2:end), :);                   % Must skip the homeNode 1 here
knnIdx_1 = knnsearch(nodesSel_1, nodesUnsel,...       % Find index of nearest neighbor in nodesSel_1 for each nodesUnsel
    'Distance', @get_edge_weight_oneToMany);          % Distance function used is specified by @
knnSel_1 = nodesSel_1(knnIdx_1, :);                   % Length of knnSel_1 is the same as that of unsel/nodesUnsel
connCost_1 = Inf * ones(size(nodesUnsel,1), 1);       % Compute connection cost for each nodesUnsel
for ii = 1:size(nodesUnsel,1)
    connCost_1(ii) = get_edge_weight(nodesUnsel(ii,:), knnSel_1(ii,:));
end
rcRatio_1 = rwd(unsel) ./ connCost_1;                 % Length of rcRatio_1 is the same as that of unsel/nodesUnsel

% Compute the reward-cost ratio for un-selected node subset with respect to the 2nd branch
nodesSel_2 = node(sel_2(2:end), :);                   % Must skip the homeNode 1 here
knnIdx_2 = knnsearch(nodesSel_2, nodesUnsel,...       % Find index of nearest neighbor in nodesSel_2 for each nodesUnsel
    'Distance', @get_edge_weight_oneToMany);          % Distance function used is specified by @
knnSel_2 = nodesSel_2(knnIdx_2, :);                   % Length of knnSel_2 is the same as that of unsel/nodesUnsel
connCost_2 = Inf * ones(size(nodesUnsel,1), 1);       % Compute connection cost for each nodesUnsel
for ii = 1:size(nodesUnsel,1)
    connCost_2(ii) = get_edge_weight(nodesUnsel(ii,:), knnSel_2(ii,:));
end
rcRatio_2 = rwd(unsel) ./ connCost_2;                 % Length of rcRatio_2 is the same as that of unsel/nodesUnsel

% Compute the reward-cost ratio for un-selected node subset with respect to the 3rd branch
nodesSel_3 = node(sel_3(2:end), :);                   % Must skip the homeNode 1 here
knnIdx_3 = knnsearch(nodesSel_3, nodesUnsel,...       % Find index of nearest neighbor in nodesSel_3 for each nodesUnsel
    'Distance', @get_edge_weight_oneToMany);          % Distance function used is specified by @
knnSel_3 = nodesSel_3(knnIdx_3, :);                   % Length of knnSel_3 is the same as that of unsel/nodesUnsel
connCost_3 = Inf * ones(size(nodesUnsel,1), 1);       % Compute connection cost for each nodesUnsel
for ii = 1:size(nodesUnsel,1)
    connCost_3(ii) = get_edge_weight(nodesUnsel(ii,:), knnSel_3(ii,:));
end
rcRatio_3 = rwd(unsel) ./ connCost_3;                 % Length of rcRatio_3 is the same as that of unsel/nodesUnsel

knnIdx   = [knnIdx_1; knnIdx_2; knnIdx_3];            % knnIdx is a stacked column vector; its length is 3 * length of unsel/nodesUnsel
connCost = [connCost_1 connCost_2 connCost_3];        % connCost is a length(unsel)-by-3 matrix
rcRatio  = [rcRatio_1; rcRatio_2; rcRatio_3];         % rcRatio is a stacked column vector; its length is 3 * length of unsel/nodesUnsel
