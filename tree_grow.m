% Grow 3 branches
function [sel_1, sel_2, sel_3, unsel] = tree_grow(node, rwd, BGT, alpha)

% Initialize sel and unsel
homeNode = 1;
unsel = setdiff(1:size(node, 1), homeNode);

%% Decide the root nodes for the 3 branches
% Divide the circle into fans of angle theta0 (=30) degrees
theta0 = 30;     % 30 looks best
radius = BGT/2;  % BGT/2 looks better
mostRwdFans = zeros(1, 360/theta0);
minNodeInEachFan = zeros(1, 360/theta0);
minDistInEachFan = Inf * ones(1, 360/theta0);
for i = 2:size(node, 1)
    dx = node(i, 1) - node(1, 1);
    dy = node(i, 2) - node(1, 2);
    r = sqrt(dx^2 + dy^2);
    if (r > radius)
        continue;
    end
    if (dx == 0)
        if (dy > 0)
            jiao_du = 90;
        else
            jiao_du = 270;
        end
    else
        jiao_du = atan(dy/dx) / pi * 180;
        if (dx < 0)
            jiao_du = jiao_du + 180;
        end
    end
    jiao_du = rem(jiao_du+360.001, 360);
    whichFan = ceil(jiao_du/theta0);
    mostRwdFans(whichFan) = mostRwdFans(ceil(jiao_du/theta0)) + rwd(i);
    if (r < minDistInEachFan(whichFan))
        minNodeInEachFan(whichFan) = i;
        minDistInEachFan(whichFan) = r;
    end
end

% Pick 3 fans with the largest values
[~, idx] = sort(mostRwdFans, 'descend');
root1 = minNodeInEachFan(idx(1));
root2 = minNodeInEachFan(idx(2));
root3 = minNodeInEachFan(idx(3));

% Selected nodes in each branch
sel_1 = [1 root1];
sel_2 = [1 root2];
sel_3 = [1 root3];

% Remove the 3 root nodes from unsel
unsel(unsel == root1) = [];
unsel(unsel == root2) = [];
unsel(unsel == root3) = [];

% -----test code-----
% plot(node(1,1),node(1,2),'d')
% hold on
% for k = 1:size(node, 1)
%     str = sprintf(' %d', k);
%     text(node(k,1), node(k,2), str);
%     plot(node(k,1), node(k,2), 'k.');
% end
% axis square
% ---x---x---x---x---


%% Build the 3 branches/subtrees using the 3rd party tree package by Tinevez
% For the 23th node, its value is 23.
% -----Usage 1-----
% Usage 1: Add value n1 below index/key nd0 in tree t and associate
% value n1 with index/key nd1
% Grammar: [t nd1] = t.addnode(nd0, n1);
% -----Usage 2-----
% Usage 2: Get the value of a node by giving its index
% Grammar: value = tree.get(index);
% -----Usage 3-----
% Usage 3: Traverse a tree by depth-first search
% Grammar:
% (1) iterator = tree.depthfirstiterator;
%       % iterator is the index of a node
% (2) for jj = 1:length(iterator)
%         tour = [tour tree.get(iterator(jj))];
%     end
% -----Usage 4-----
% Usage 4: Store and retrieve the index of a node
% Grammar: tree_idxOfNode(value) = index;
% -----Usage 5-----
% More information about a specific function can be found by typing:
% 'help tree/function_name' in the console.
% -----x-x-x-x-----
% Initialize 3 branches
% 1st branch
tree1  = tree(1);
tree1_idxOfNode = zeros(1, size(node, 1));  tree1_idxOfNode(1) = 1;
eval(sprintf('[tree1, tree1_idxOfNode(%d)] = tree1.addnode(tree1_idxOfNode(1), %d);', root1, root1));
% 2nd branch
tree2  = tree(1);
tree2_idxOfNode = zeros(1, size(node, 1));  tree2_idxOfNode(1) = 1;
eval(sprintf('[tree2, tree2_idxOfNode(%d)] = tree2.addnode(tree2_idxOfNode(1), %d);', root2, root2));
% 3rd branch
tree3  = tree(1);
tree3_idxOfNode = zeros(1, size(node, 1));  tree3_idxOfNode(1) = 1;
eval(sprintf('[tree3, tree3_idxOfNode(%d)] = tree3.addnode(tree3_idxOfNode(1), %d);', root3, root3));

% Record current tree cost
costTree = [0 0 0];
costTree(1) = get_edge_weight(node(1, :), node(root1, :));
costTree(2) = get_edge_weight(node(1, :), node(root2, :));
costTree(3) = get_edge_weight(node(1, :), node(root3, :));

% Record the tree is tree saturated or topological tour saturated
isTreeSaturated = false;
isTourSaturated = false;
while(1)
    % -----test code-----
    % plot(node(sel_1,1),node(sel_1,2),'go')
    % plot(node(sel_2,1),node(sel_2,2),'k>')
    % plot(node(sel_3,1),node(sel_3,2),'r<')
    % disp(tree1.tostring);
    % disp(tree2.tostring);
    % disp(tree3.tostring);
    % ---x---x---x---x---
    [rcRatio, connCost, knnIdx] = compute_rcRatio(node, rwd, unsel, sel_1, sel_2, sel_3);
    [~, idx] = sort(rcRatio, 1, 'descend'); 
    if (~isTreeSaturated)
        % Select node with highest reward-cost ratio without exceeding budget constraint
        for k = 1:length(idx)
            whichTr = ceil(idx(k) / length(unsel));
            maxUnsel = unsel(rem(idx(k) - 1, length(unsel)) + 1);
            % Determine which sel node in the corresponding tree should
            % the new unsel node be added to
            switch whichTr
                case 1
                    selToAdd = sel_1(knnIdx(idx(k)) + 1);  % +1 since we have skipped the homeNode 1
                case 2
                    selToAdd = sel_2(knnIdx(idx(k)) + 1);
                case 3
                    selToAdd = sel_3(knnIdx(idx(k)) + 1);
            end
            eval(sprintf('idx_selToAddParent = tree%d.getparent(tree%d_idxOfNode(%d));', whichTr, whichTr, selToAdd));
            eval(sprintf('selToAddParent = find(tree%d_idxOfNode == idx_selToAddParent);', whichTr));
            % Check if worth replacing the original edge (selToAddParent, selToAdd) with new edge (selToAddParent, maxUnsel)
            potentialCostChange = get_edge_weight(node(selToAddParent, :), node(maxUnsel, :))...
                - get_edge_weight(node(selToAddParent, :), node(selToAdd, :));
            % If cost change > 0 after swap, do not swap
            if (potentialCostChange >= 0)
                % If feasible (do not exceed budget)
                if (connCost(rem(idx(k) - 1, length(unsel)) + 1, whichTr) + costTree(whichTr) <= alpha*BGT )
                    % Add un-selected node with max rcRatio to corresponding selected node (to corresponding tree 'whichTr')
                    eval(sprintf('[tree%d, tree%d_idxOfNode(%d)] = tree%d.addnode(tree%d_idxOfNode(%d), %d);',...
                        whichTr, whichTr, maxUnsel,...                             
                        whichTr, whichTr, selToAdd, maxUnsel));
                    % Update tree cost
                    costTree(whichTr) = costTree(whichTr)...  
                        + connCost(rem(idx(k) - 1, length(unsel)) + 1, whichTr);
                    % Update 'sel_1/2/3' and 'unsel'
                    eval(sprintf('sel_%d = [sel_%d, %d];',...                      % Add to selected node subset of the 'whichTr' branch
                        whichTr, whichTr, maxUnsel));
                    unsel(rem(idx(k) - 1, length(unsel)) + 1) = [];                % Delete from un-selected node subset
                    break;
                end
            % Else, do the swap, maxUnsel becomes the new parent of selToAdd
            else
                % If feasible (do not exceed budget)
                if (costTree(whichTr)...
                        + connCost(rem(idx(k) - 1, length(unsel)) + 1, whichTr)...
                        + potentialCostChange <= alpha*BGT)
                    % Store subtree rooted at selToAdd before chopping it off
                    eval(sprintf('subTreeChoppedOff = tree%d.subtree(tree%d_idxOfNode(%d));', whichTr, whichTr, selToAdd));
                    % Chop off subtree rooted at selToAdd
                    eval(sprintf('tree%d = tree%d.chop(tree%d_idxOfNode(%d));', whichTr, whichTr, whichTr, selToAdd));
                    % Build a new tree rooted at maxUnsel (the new node to insert),
                    % and glue/graft the chopped-off tree to it
                    t = tree(maxUnsel);
                    t = t.graft(1, subTreeChoppedOff);
                    % Glue/Graft the new tree to selToAddParent
                    eval(sprintf('tree%d = tree%d.graft(tree%d_idxOfNode(%d), t);',...
                        whichTr, whichTr, whichTr, selToAddParent));
                    % Set index for maxUnsel (the new node inserted) to be the size of the newly built tree
                    % (Actually this can be deleted since we have the
                    % adjustment step below)
                    eval(sprintf('tree%d_idxOfNode(%d) = length(tree%d.Node);', whichTr, maxUnsel, whichTr)); 
                    
                    % Make adjustments of the indices of the nodes
                    % based the information in the tree
                    for possibleID = 1:size(node, 1)
                        % Use try-catch since possibleID may not be a valid
                        % ID in the tree
                        try
                            eval(sprintf('tmp = tree%d.get(%d);', whichTr, possibleID)); 
                            eval(sprintf('tree%d_idxOfNode(%d) = %d;', whichTr, tmp, possibleID));
                        catch
                        end
                    end
                    
                    % Update tree cost
                    costTree(whichTr) = costTree(whichTr)...  
                        + connCost(rem(idx(k) - 1, length(unsel)) + 1, whichTr)...
                        + potentialCostChange;                                     % potentialCostChange is negative here
                    % Update 'sel_1/2/3' and 'unsel'
                    eval(sprintf('sel_%d = [sel_%d, %d];',...                      % Add to selected node subset of the 'whichTr' branch
                        whichTr, whichTr, maxUnsel));
                    unsel(rem(idx(k) - 1, length(unsel)) + 1) = [];                % Delete from un-selected node subset
                    break;
                end
            end
            % If have reached the end, but still cannot find one,
            % set isTreeSaturated to be true
            if (k == length(idx))
                isTreeSaturated = true;
                break;
            end
        end
    else
        for k = 1:length(idx)
            whichTr = ceil(idx(k) / length(unsel));
            currentUnsel = unsel(rem(idx(k) - 1, length(unsel)) + 1);
            switch whichTr
                case 1
                    selToAdd = sel_1(knnIdx(idx(k)) + 1);  % +1 since we have skipped the homeNode 1
                case 2
                    selToAdd = sel_2(knnIdx(idx(k)) + 1);
                case 3
                    selToAdd = sel_3(knnIdx(idx(k)) + 1);
            end
            % Build the new tree and the tour to see if its cost overflows
            eval(sprintf('newTree = tree%d;', whichTr));
            eval(sprintf('[newTree, tree%d_idxOfNode(%d)] = newTree.addnode(tree%d_idxOfNode(%d), %d);',...
                whichTr, currentUnsel,...
                whichTr, selToAdd, currentUnsel));
            % Build tour using preorder traversal
            iterator = newTree.depthfirstiterator;
            tmpTour = [];
            for jj = 1:length(iterator)
                eval(sprintf('tmpTour = [tmpTour newTree.get(%d)];', iterator(jj)));
            end
            % Compute tour cost
            tmpTourCost = get_tour_cost(node, tmpTour);
            % Test if satisfy BGT. If yes, add to selected node subset
            % and update the tree
            if tmpTourCost <= BGT
                eval(sprintf('tree%d = newTree;', whichTr));
                eval(sprintf('sel_%d = [sel_%d %d];', whichTr, whichTr, currentUnsel));  % Add to selected node subset of the 'whichTr' branch
                unsel(rem(idx(k) - 1, length(unsel)) + 1) = [];                          % Delete from un-selected node subset
                break;     
            end

            % If have checked every nodesUnsel, then set isTourSaturated to
            % be true and quit
            if (k == length(idx))
                isTourSaturated = true;
                break;
            end
        end
    end
  
    if (isTourSaturated)
        break;
    end
    
    if (length(unsel) <= 0)
        return;
    end
    
end

%% Test code: plot the trees (not implemented yet)
% plot(node(:,1),node(:,2),'x')
% hold on
% plot(node(1,1),node(1,2),'d')
% plot(node(sel_1,1),node(sel_1,2),'go')
% plot(node(sel_2,1),node(sel_2,2),'k>')
% plot(node(sel_3,1),node(sel_3,2),'r<')
% axis square

