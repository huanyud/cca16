function [toursCell, toursCost, toursRwd, finalTeamReward] = CGW_two_point_exchange(node, rwd, BGT, toursCell, toursCost, toursRwd)

M = 3;
isSaturated = false;
while(~isSaturated)
    breakMultipleFORLoops = false;
    record = sum(toursRwd(1:M));
    for topItr = 1:M
        for ii = 2:length(toursCell{topItr})
            bestTeamRwd = -Inf;
            for botItr = M+1:length(toursCell)
                for jj = 2:length(toursCell{botItr})
                    % Store the orginal top and bottom tours
                    tmpTopTour = toursCell{topItr};
                    tmpBotTour = toursCell{botItr};
                    
                    % Remove 'topRemoved' and 'botRemoved' from tmp tours
                    topRemoved = tmpTopTour(ii);
                    botRemoved = tmpBotTour(jj);
                    tmpTopTour(ii) = [];
                    tmpBotTour(jj) = [];
                    
                    % Compute team reward after exchanging two nodes
                    tmpToursRwd = toursRwd;
                    tmpToursRwd(topItr) = tmpToursRwd(topItr)...
                        + rwd(botRemoved) - rwd(topRemoved);
                    tmpToursRwd(botItr) = tmpToursRwd(botItr)...
                        + rwd(topRemoved) - rwd(botRemoved);
                    [sortedTmpToursRwd, idx] = sort(tmpToursRwd, 'descend');
                    thisTeamRwd = sum(sortedTmpToursRwd(1:M));
                    
                    % If thisTeamRwd <= bestTeamRwd, no need to do the following
                    if (thisTeamRwd <= bestTeamRwd)
                        continue;
                    end
                    
                    % Tour costs after deleting one node from either tour
                    tmpTopCost = get_tour_cost(node, tmpTopTour);
                    tmpBotCost = get_tour_cost(node, tmpBotTour);
                    
                    % Insert 'topRemoved' to bottom tour using cheapest insertion
                    minIncreCost_t2b = Inf;
                    for ttt = 1:length(tmpBotTour)
                        % Compute insertion position in bottom tour
                        AA = ttt;
                        if (ttt == length(tmpBotTour))
                            BB = 1;
                        else
                            BB = ttt+1;
                        end
                        tmpIncreCost = get_edge_weight(node(topRemoved, :), node(tmpBotTour(AA), :))...
                            + get_edge_weight(node(topRemoved, :), node(tmpBotTour(BB), :))...
                            - get_edge_weight(node(tmpBotTour(AA), :), node(tmpBotTour(BB), :));
                        if (tmpIncreCost < minIncreCost_t2b)
                            minIncreCost_t2b = tmpIncreCost;
                            minBotTour = [tmpBotTour(1:AA), topRemoved, tmpBotTour(AA+1:end)];
                        end
                    end
                    
                    % Insert 'botRemoved' to top tour using cheapest insertion
                    minIncreCost_b2t = Inf;
                    for ttt = 1:length(tmpTopTour)
                        % Compute insertion position in bottom tour
                        AA = ttt;
                        if (ttt == length(tmpTopTour))
                            BB = 1;
                        else
                            BB = ttt+1;
                        end
                        tmpIncreCost = get_edge_weight(node(botRemoved, :), node(tmpTopTour(AA), :))...
                            + get_edge_weight(node(botRemoved, :), node(tmpTopTour(BB), :))...
                            - get_edge_weight(node(tmpTopTour(AA), :), node(tmpTopTour(BB), :));
                        if (tmpIncreCost < minIncreCost_b2t)
                            minIncreCost_b2t = tmpIncreCost;
                            minTopTour = [tmpTopTour(1:AA), botRemoved, tmpTopTour(AA+1:end)];
                        end
                    end
                    
                    % If feasible, update
                    if (get_tour_cost(node, minTopTour) <= BGT &&...
                            get_tour_cost(node, minBotTour) <= BGT)
                        % Record the new team reward, the two tours being
                        % exchanged, the two points being exchanged, and 
                        % the two insertion positions
                        bestTeamRwd = thisTeamRwd;
                        bestTopItr  = topItr;
                        bestBotItr  = botItr;
                        bestTopTour = minTopTour;
                        bestBotTour = minBotTour;
                    end
                end
            end
            % If best team reward > record, perform the exchange
            if bestTeamRwd > record
                % Update the two tours
                toursCell{bestTopItr} = bestTopTour;
                toursCell{bestBotItr} = bestBotTour;
                toursCost(bestTopItr) = get_tour_cost(node, bestTopTour);
                toursCost(bestBotItr) = get_tour_cost(node, bestBotTour);
                toursRwd(bestTopItr)  = sum(rwd(bestTopTour));
                toursRwd(bestBotItr)  = sum(rwd(bestBotTour));
                
                % Sort all tours by toursRwd, keep tours with higher rwd in
                % the front and update the cost
                [toursRwd, idx] = sort(toursRwd, 'descend');
                toursCell = toursCell(idx);
                toursCost = toursCost(idx);
                
                % Set a flag to break multiple 'FOR loops'
                breakMultipleFORLoops = true;
                break;
            else
                isSaturated = true;
            end
            if (breakMultipleFORLoops)
                break;
            end
        end
        if (breakMultipleFORLoops)
            break;
        end
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