function [toursCell, toursCost, toursRwd] = two_point_exchange(node, rwd, BGT, toursCell, toursCost, toursRwd)
M = 3;

%% Exchange between tour and unsel. Both reward and cost will change
while (1)
    bestCostReduction = 0;
    for topItr = 1:M
        for ii = 2:length(toursCell{topItr})
            for botItr = 1:M
                if (botItr == topItr)
                    continue;
                end
                for jj = 2:length(toursCell{botItr})
                    % Store the orginal this and that tours
                    tmpTopTour = toursCell{topItr};
                    tmpBotTour = toursCell{botItr}; 
                    
                    % Change of tour cost after deleting one node from top tour
                    if (ii == length(toursCell{topItr}))
                        tmpTopCostReduction = get_edge_weight(node(tmpTopTour(ii-1), :), node(1, :))...
                            - get_edge_weight(node(tmpTopTour(ii-1), :), node(tmpTopTour(ii), :))...
                            - get_edge_weight(node(tmpTopTour(ii), :), node(1, :));
                    else
                        tmpTopCostReduction = get_edge_weight(node(tmpTopTour(ii-1), :), node(tmpTopTour(ii+1), :))...
                            - get_edge_weight(node(tmpTopTour(ii-1), :), node(tmpTopTour(ii), :))...
                            - get_edge_weight(node(tmpTopTour(ii), :), node(tmpTopTour(ii+1), :));
                    end
                    
                    % Remove 'topRemoved' from tmp top tour
                    topRemoved = tmpTopTour(ii);
                    tmpTopTour(ii) = [];
                         
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

                    % If feasible, and the total tour cost change is below
                    % 0 and below the 'bestCostReduction', then update
                    if (tmpTopCostReduction + minIncreCost_t2b < bestCostReduction &&...
                            get_tour_cost(node, minBotTour) <= BGT)
                        bestCostReduction = tmpTopCostReduction + minIncreCost_t2b;
                        bestTopItr  = topItr;
                        bestBotItr  = botItr;
                        bestTopTour = tmpTopTour;
                        bestBotTour = minBotTour;
                    end
                end
            end
        end
    end
    
    if bestCostReduction < 0
        toursCell{bestTopItr} = bestTopTour;
        toursCell{bestBotItr} = bestBotTour;
        toursCost(bestTopItr) = get_tour_cost(node, bestTopTour);
        toursCost(bestBotItr) = get_tour_cost(node, bestBotTour);
        toursRwd(bestTopItr)  = sum(rwd(bestTopTour));
        toursRwd(bestBotItr)  = sum(rwd(bestBotTour));
    else
        break;
    end
end

%% Exchange between tours. The reward will not change, but cost will
while (1)
    bestCostReduction = 0;
    for topItr = 1:M-1
        for ii = 2:length(toursCell{topItr})
            for botItr = topItr+1:M
                for jj = 2:length(toursCell{botItr})
                    % Store the orginal this and that tours
                    tmpTopTour = toursCell{topItr};
                    tmpBotTour = toursCell{botItr};    

                    % Change of tour costs after deleting one node from either tour
                    if (ii == length(toursCell{topItr}))
                        tmpTopCostReduction = get_edge_weight(node(tmpTopTour(ii-1), :), node(1, :))...
                            - get_edge_weight(node(tmpTopTour(ii-1), :), node(tmpTopTour(ii), :))...
                            - get_edge_weight(node(tmpTopTour(ii), :), node(1, :));
                    else
                        tmpTopCostReduction = get_edge_weight(node(tmpTopTour(ii-1), :), node(tmpTopTour(ii+1), :))...
                            - get_edge_weight(node(tmpTopTour(ii-1), :), node(tmpTopTour(ii), :))...
                            - get_edge_weight(node(tmpTopTour(ii), :), node(tmpTopTour(ii+1), :));
                    end
                    if (jj == length(toursCell{botItr}))
                        tmpBotCostReduction = get_edge_weight(node(tmpBotTour(jj-1), :), node(1, :))...
                            - get_edge_weight(node(tmpBotTour(jj-1), :), node(tmpBotTour(jj), :))...
                            - get_edge_weight(node(tmpBotTour(jj), :), node(1, :));
                    else
                        tmpBotCostReduction = get_edge_weight(node(tmpBotTour(jj-1), :), node(tmpBotTour(jj+1), :))...
                            - get_edge_weight(node(tmpBotTour(jj-1), :), node(tmpBotTour(jj), :))...
                            - get_edge_weight(node(tmpBotTour(jj), :), node(tmpBotTour(jj+1), :));
                    end
                    
                    % Remove 'topRemoved' and 'botRemoved' from tmp tours
                    topRemoved = tmpTopTour(ii);
                    botRemoved = tmpBotTour(jj);
                    tmpTopTour(ii) = [];
                    tmpBotTour(jj) = [];
                         
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

                    % If feasible, and the total tour cost change is below
                    % 0 and below the 'bestCostReduction', then update
                    if (tmpTopCostReduction + tmpBotCostReduction +...
                            minIncreCost_t2b + minIncreCost_b2t...
                            < bestCostReduction &&...
                            get_tour_cost(node, minTopTour) <= BGT &&...
                            get_tour_cost(node, minBotTour) <= BGT)
                        bestCostReduction = tmpTopCostReduction + tmpBotCostReduction +...
                            minIncreCost_t2b + minIncreCost_b2t;
                        bestTopItr  = topItr;
                        bestBotItr  = botItr;
                        bestTopTour = minTopTour;
                        bestBotTour = minBotTour;
                    end
                end
            end
        end
    end
    
    if bestCostReduction < 0
        toursCell{bestTopItr} = bestTopTour;
        toursCell{bestBotItr} = bestBotTour;
        toursCost(bestTopItr) = get_tour_cost(node, bestTopTour);
        toursCost(bestBotItr) = get_tour_cost(node, bestBotTour);
        toursRwd(bestTopItr)  = sum(rwd(bestTopTour));
        toursRwd(bestBotItr)  = sum(rwd(bestBotTour));
    else
        break;
    end
end

