function void = LinCombs(product)
    basis = [194,447, 714, 768, 912, 1120, 1144, 1212, 1244, 1284, 1331, 1377, 1491, 1496, 1522, 1615, 1642, 2996, 3012, 3156, 3189, 3198];
    err = 50;
    past_results = [];
    for i = 1:length(basis)
        for ii = 1:length(basis)
            for iii = 1:length(basis)
                results = [basis(i)+basis(ii), basis(i)+basis(iii), basis(ii)+basis(iii), basis(i)+basis(ii)+basis(iii)];
                for n = 1:length(results)
                    if ~ismember(results(n),past_results)
                        if results(n) == product
                            %add if n==1, n==2 etc. for printing values
                            disp(basis(i) + " + " + basis(ii))
                        elseif (results(n) - err < product) && (product < results(n) + err)
                            disp("Found a close match: " + basis(i) + " + " + basis(ii) + "; Error: " + (results(n)-product))
                        end
                        past_results = [past_results, results];
                    end
                end
            end
        end
    end
    if isempty(basis)
        disp("no matches found")
    end
end
