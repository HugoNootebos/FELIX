function calc_values = PowerCal(n, w, power) %n = order, w = wavelength in µm, power in mJ
    coeffs = polyfit(w,power,n);
    current_val = 0;
    str_out = "";
    calc_values = [];
    diff = [];
    for i = 1:n+1
        str_out = str_out + coeffs(i) + "[w^" + string(n+1-i) + "] + ";
    end
    for i = 1:length(w)
        for ii = 1:n+1
            current_val = current_val + (w(i)^(n+1-ii))*coeffs(ii);
        end
        calc_values(end+1) = current_val;
        diff(end+1) = abs(power(i) - current_val);
        current_val = 0;
    end
    err = sum(diff);
    disp(str_out)
    disp("Total error: " + round(err,0))
    figure(1);
    plot(w, calc_values, w, power, w, diff)
    xlabel("wavelength (µm)");
    ylabel("mean power (mJ)");
    legend("polyfit", "power scan", "error");
end