function calc_values = AutoPowerCal(maxOrder, dataCSV) %w, power)%dataCSV) %maxOrder = upper limit to testing orders
    data = readtable(dataCSV);
    w = data{:,1}; %in µm
    power = data{:,2}; %in mJ
    current_val = 0;
    str_out = "";
    calc_values = zeros(maxOrder,length(w));
    diff = zeros(maxOrder,length(w));
    err = zeros(maxOrder,1);
    n = 0;

    for iii = 1:maxOrder
        n = n + iii;
        coeffs = polyfit(w,power,n);
        for i = 1:length(w)
            for ii = 1:n+1
                current_val = current_val + (w(i)^(n+1-ii))*coeffs(ii);
            end
            calc_values(iii,i) = current_val;
            diff(iii,i) = abs(power(i) - current_val);
            current_val = 0;
        end
        err(iii,1) = sum(diff(iii,:));
    end
    bestOrder = 1;
    for i = 2:length(err)
        if err(i) < err(bestOrder)
            bestOrder = i;
        end
    end
    disp("best fitting order is: " + bestOrder)
    coeffs = polyfit(w,power,bestOrder);
    for i = 1:bestOrder+1
        str_out = str_out + round(coeffs(i),4,'significant') + "[w^" + string(bestOrder+1-i) + "] + ";
    end
    disp(str_out)
    disp("Total error: " + round(err(bestOrder,1),2))
    figure(1);
    plot(w, calc_values(bestOrder,:), w, power, w, diff(bestOrder,:))
    xlabel("wavelength (µm)");
    ylabel("mean power (mJ)");
    title("FELIX power calibration from: " + dataCSV(end-12:end-4));
    legend({str_out, "power scan data", "error"},'location', 'east');
    exportgraphics(gcf,"powerscan.png");
end