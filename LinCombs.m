function void = LinCombs(product)
%Useful for predicting anharmonicities. Set basis to the harmonic modes
%that have significant intensity
    basis = [194,447, 714.05, 768, 912, 1120, 1144, 1212, 1244, 128.53, 1331, 1377, 1491.29, 1496, 1522, 1615, 1641.64, 2996, 3012, 3156, 3189, 3198];
    err = 5;
    past_results = [];
    for i = 1:length(basis)
        for ii = 1:length(basis)
            for iii = 1:length(basis)
                results = [basis(i)+basis(ii), basis(i)+basis(iii), basis(ii)+basis(iii), basis(i)+basis(ii)+basis(iii)];
                for n = 1:length(results)
                    if ~ismember(results(n),past_results)
                        if (results(n) - err < product) && (product < results(n) + err)
                            if n == 1
                                disp("Found a match: " + basis(i) + " + " + basis(ii) + "; Error: " + (results(n)-product))
                            elseif n == 2
                                disp("Found a match: " + basis(i) + " + " + basis(iii) + "; Error: " + (results(n)-product))
                            elseif n == 3
                                disp("Found a match: " + basis(ii) + " + " + basis(iii) + "; Error: " + (results(n)-product))
                            elseif n == 4
                                disp("Found a match: " + basis(i) + " + " + basis(ii) + " + " + basis(iii) + "; Error: " + (results(n)-product))
                            end
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
