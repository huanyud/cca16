function write_lkh_input(node, sel, RUNS)

if nargin < 3
    RUNS = 10;
end

% Write parameter file
fileID1 = fopen( 'lkhInput.par', 'wt' );
fprintf(fileID1, 'PROBLEM_FILE = lkhInput.tsp\n');  
fprintf(fileID1, 'OUTPUT_TOUR_FILE = lkhOutput.txt\n');
fprintf(fileID1, 'MOVE_TYPE = 5\n');
fprintf(fileID1, 'RUNS = %d\n', RUNS); 
fclose(fileID1);

% Write TSP file (like in TSPLIB)
fileID2 = fopen('lkhInput.tsp', 'wt');
fprintf(fileID2, 'NAME: lkhInput\n');
fprintf(fileID2, 'TYPE: TSP\n');
fprintf(fileID2, 'COMMENT: Find TSP tour on selected node subset (Huanyu Ding)\n');
fprintf(fileID2, 'DIMENSION: %d\n', length(sel));
fprintf(fileID2, 'EDGE_WEIGHT_TYPE: EXPLICIT\n');
fprintf(fileID2, 'EDGE_WEIGHT_FORMAT: LOWER_DIAG_ROW\n');
fprintf(fileID2, 'EDGE_WEIGHT_SECTION\n');
for ii = 1:length(sel)
    for jj = 1:ii
        if (jj == ii)
            fprintf(fileID2, '0 \n');
        else
            entry = get_edge_weight(node(sel(ii),:), node(sel(jj),:));
            entry = round(100*entry);
            fprintf(fileID2, '%d\n', entry);
        end
    end
end
fclose(fileID2);
            
            
