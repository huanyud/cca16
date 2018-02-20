function [sortedToursCell, sortedToursCost, sortedToursRwd] = CGW_initialize(node, rwd, BGT)

unsel          = 2:size(node,1);
unselDist      = get_edge_weight_oneToMany(node(1, :), node(unsel, :));   
validUnsel     = unsel(unselDist <= BGT/2);
validUnselDist = unselDist(unselDist <= BGT/2);
[~, idx]       = sort(validUnselDist, 'descend');

%% Create L = min(5, N) tours
L = min(5, length(validUnsel));
for tItr = 1:L
    toursCell{tItr} = [1 validUnsel(idx(tItr))];
end
validUnsel(idx(1:L)) = [];

%% Insert the remaining points to the L tours using cheapest insertion
toursCost = zeros(1, length(toursCell));
for tItr = 1:L
    toursCost(tItr) = get_tour_cost(node, toursCell{tItr});
end
while(~isempty(validUnsel))
    % Compute insertion cost for each validUnsel, each tour, and each
    % connection cost; find the minimum feasible insertion cost; also
    % record which validUnsel, which tour and where to insert
    minIncreCost = Inf;
    for ii = 1:length(validUnsel)
        thisNode = node(validUnsel(ii), :);
        for tItr = 1:L
            for jj = 1:length(toursCell{tItr})               
                AA = toursCell{tItr}(jj);
                if jj == length(toursCell{tItr})
                    BB = toursCell{tItr}(1);
                else
                    BB = toursCell{tItr}(jj+1);
                end
                tempIncreCost = get_edge_weight(thisNode, node(AA, :))...
                    + get_edge_weight(thisNode, node(BB, :))...
                    - get_edge_weight(node(AA, :), node(BB, :));
                if (tempIncreCost < minIncreCost &&...
                        toursCost(tItr) + tempIncreCost <= BGT)
                    minIncreCost = tempIncreCost;
                    minUnseltoInsert = validUnsel(ii);
                    minWhichTour = tItr;
                    minInsertPos = jj;
                end
            end
        end
    end
    
    % Perform insertion
    if (minIncreCost < Inf)
        % Update tour
        tourToInsert = toursCell{minWhichTour};
        if minInsertPos == length(tourToInsert)
            toursCell{minWhichTour} = [tourToInsert, minUnseltoInsert];
        else
            toursCell{minWhichTour} = [tourToInsert(1:minInsertPos), minUnseltoInsert, tourToInsert(minInsertPos+1:end)];
        end
        % Update validUnsel
        validUnsel(validUnsel == minUnseltoInsert) = [];
        % Update tour costs
        toursCost(minWhichTour) = toursCost(minWhichTour) + minIncreCost;
    else
        break;
    end
end

%% Construct more tours for remaining nodes
while(~isempty(validUnsel))
    % Find the index of the furthest node in the remaining validUnsel
    validUnselDist = get_edge_weight_oneToMany(node(1, :), node(validUnsel, :));
    idx = find(validUnselDist == max(validUnselDist));
    idx = idx(1);
    % Construct a new tour for it
    len = length(toursCell);
    toursCell{len+1} = [1 validUnsel(idx)];
    % Compute the cost of the new tour
    toursCost = [toursCost, get_tour_cost(node, toursCell{end})];
    % Delete this node from validUnsel
    validUnsel(idx) = [];
    % Insert more nodes to this tour using cheapest insertion
    minIncreCost = Inf;
    for ii = 1:length(validUnsel)
        thisNode = node(validUnsel(ii), :);
        for jj = 1:length(toursCell{end})               
            AA = toursCell{end}(jj);
            if jj == length(toursCell{end})
                BB = toursCell{end}(1);
            else
                BB = toursCell{end}(jj+1);
            end
            tempIncreCost = get_edge_weight(thisNode, node(AA, :))...
                + get_edge_weight(thisNode, node(BB, :))...
                - get_edge_weight(node(AA, :), node(BB, :));
            if (tempIncreCost < minIncreCost &&...
                    toursCost(end) + tempIncreCost <= BGT)
                minIncreCost = tempIncreCost;
                minUnseltoInsert = validUnsel(ii);
                minInsertPos = jj;
            end
        end
    end
    if (minIncreCost < Inf)
        % Update tour
        if minInsertPos == length(toursCell{end})
            toursCell{end} = [toursCell{end}, minUnseltoInsert];
        else
            toursCell{end} = [toursCell{end}(1:minInsertPos), minUnseltoInsert, toursCell{end}(minInsertPos+1:end)];
        end
        % Update validUnsel
        validUnsel(validUnsel == minUnseltoInsert) = [];
        % Update tour costs
        toursCost(end) = toursCost(end) + minIncreCost;
    else
        continue;
    end
end

toursRwd = zeros(1, length(toursCell));
for tItr = 1:length(toursCell)
    toursRwd(tItr) = sum(rwd(toursCell{tItr}));
end
[sortedToursRwd, idx] = sort(toursRwd, 'descend');
sortedToursCell = toursCell(idx);
sortedToursCost = toursCost(idx);


% -----test code-----
% for ii = 1:length(sortedToursCell)
%     get_tour_cost(node, sortedToursCell{ii})
% end
% clear ans;
% ---x---x---x---x---



