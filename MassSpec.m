function intensity = MassSpec(file,wavelength)
    plotting = false;
    params = h5read(file,"/Parameters");
    point = abs(wavelength - params.scanStart)/params.scanStep + 1;
    file_char = convertStringsToChars(file);
    if point < 10
        add = "0000";
    elseif point < 100
        add = "000";
    elseif point < 1000
        add = "00";
    elseif point < 10000
        add = "0";
    else
        add = "";
    end
    lock = true;
    try
        data = h5read(file, "/Rawdat/P" + add + point + "_" + num2str(wavelength,'%.4f') + "/Trace");
        disp("Loading P" + add+point+"/"+num2str(wavelength,'%.4f') + " from " + file_char(25:end))
    catch
        %ERROR continue to next file
        intensity = -1;
        data = -1;
        lock = false;
    end
    if lock
        tof = [];
        intensity = [];
        background = mean(data,'all');
        for i = 1:length(data)
            tof(end+1) = i;
            intensity(end+1) = data(i) - background;
        end
    end
    if plotting
        figure();
        plot(tof,intensity)
        xlabel("time of flight")
        ylabel("intensity")
    end
end
