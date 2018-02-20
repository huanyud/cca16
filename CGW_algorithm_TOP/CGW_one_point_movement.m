function [toursCell, toursCost, toursRwd, finalTeamReward] = CGW_one_point_movement(node, rwd, BGT, toursCell, toursCost, toursRwd)

M = 3;
isSaturated = false;
while(~isSaturated)
    breakALoop = false;
    record = sum(toursRwd(1:M));
    % A loop:
    for thisNode = 2:size(node, 1)
        if (get_edge_weight(node(1, :), node(thisNode, :)) > BGT/2)
            continue;
        end
        bestTeamRwd = -Inf;
        % Find out which tour does thisNode belong to
        for tItr = 1:length(toursCell)
            if any(toursCell{tItr} == thisNode)
                thisWhichTour = tItr;
                break;
            end
        end
        % Copy the orginal thisTour
        tmpThisTour = toursCell{thisWhichTour};
        % Remove thisNode from tmpThisTour
        tmpThisTour(tmpThisTour == thisNode) = [];
        
        % B loop:
        for tItr = 1:length(toursCell)
            % Skip the same tour
            if (tItr == thisWhichTour)
                continue;
            end
            % Iterate through every node in thatTour
            for jj = 2:length(toursCell{tItr})
                % Copy the orginal thatTour
                tmpThatTour = toursCell{tItr};

                % Compute team reward after exchanging two nodes
                tmpToursRwd = toursRwd;
                tmpToursRwd(thisWhichTour) = tmpToursRwd(thisWhichTour) - rwd(thisNode);
                tmpToursRwd(tItr)          = tmpToursRwd(tItr)          + rwd(thisNode);
                [sortedTmpToursRwd, ~]   = sort(tmpToursRwd, 'descend');
                thisTeamRwd = sum(sortedTmpToursRwd(1:M));

                % If thisTeamRwd <= bestTeamRwd, no need to do the following
                if (thisTeamRwd <= bestTeamRwd || thisTeamRwd <= record)
                    continue;
                end

                % Insert 'thisNode' to tour 'tItr' using cheapest insertion
                minIncreCost = Inf;
                for ttt = 1:length(tmpThatTour)
                    % Compute insertion position in bottom tour
                    AA = ttt;
                    if (ttt == length(tmpThatTour))
                        BB = 1;
                    else
                        BB = ttt+1;
                    end
                    tmpIncreCost = get_edge_weight(node(thisNode, :), node(tmpThatTour(AA), :))...
                        + get_edge_weight(node(thisNode, :), node(tmpThatTour(BB), :))...
                        - get_edge_weight(node(tmpThatTour(AA), :), node(tmpThatTour(BB), :));
                    if (tmpIncreCost < minIncreCost)
                        minIncreCost = tmpIncreCost;
                        minThatTour = [tmpThatTour(1:AA), thisNode, tmpThatTour(AA+1:end)];
                    end
                end

                % If feasible, update
                if (get_tour_cost(node, minThatTour) <= BGT)
                    % Record the new team reward, the two tours being
                    % exchanged, the two points being exchanged, and 
                    % the two insertion positions
                    bestTeamRwd    = thisTeamRwd;
                    thatWhichTour  = tItr;
                    bestThatTour   = minThatTour;
                end
                
            end
        end
        
        % If best team reward > record, perform the exchange
        if bestTeamRwd > record
            % Update the two tours
            toursCell{thisWhichTour} = tmpThisTour;
            toursCell{thatWhichTour} = bestThatTour;
            toursCost(thisWhichTour) = get_tour_cost(node, tmpThisTour);
            toursCost(thatWhichTour) = get_tour_cost(node, bestThatTour);
            toursRwd(thisWhichTour)  = sum(rwd(tmpThisTour));
            toursRwd(thatWhichTour)  = sum(rwd(bestThatTour));

            % Sort all tours by toursRwd, keep tours with higher rwd in
            % the front and update the cost
            [toursRwd, idx] = sort(toursRwd, 'descend');
            toursCell = toursCell(idx);
            toursCost = toursCost(idx);
            break;
        end
    end
    
    if (thisNode == size(node, 1))
        isSaturated = true;
    end
end

finalTeamReward = sum(toursRwd(1:M));

% -----test code-----
% for ii = 1:length(toursCell)
%     get_tour_cost(node, toursCell{ii})
% end
% clear ans;
% ---x---x---x---x---

%% Test code: plot the tours
% figure();
% plot(node(:,1),node(:,2),'x')
% hold on
% plot(node(1,1),node(1,2),'d')
% plot(node(toursCell{1}, 1),node(toursCell{1}, 2),'go')
% plot(node(toursCell{2}, 1),node(toursCell{2}, 2),'k>')
% plot(node(toursCell{3}, 1),node(toursCell{3}, 2),'r<')
% plot_tour_simple(toursCell{1}, node, rwd, BGT, 30)
% plot_tour_simple(toursCell{2}, node, rwd, BGT, 30)
% plot_tour_simple(toursCell{3}, node, rwd, BGT, 30)
% axis square