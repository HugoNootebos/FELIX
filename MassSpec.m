function intensity = MassSpec(file,wavelength)
    plotting = false;
    params = h5read(file,"/Parameters");
    point = abs(wavelength - params.scanStart)/params.scanStep + 1;
    file_char = convertStringsToChars(file);
    dat_point = num2str(point); 
    while strlength(dat_point) < 5
        dat_point = "0" + dat_point;
    end
    lock = true;
    disp("Loading P" + dat_point+"/"+num2str(wavelength,'%.4f') + " from " + file_char(25:end))
    try
        data = h5read(file, "/Rawdat/P" + dat_point + "_" + num2str(wavelength,'%.4f') + "/Trace");
    catch
        intensity = -1;
        data = -1;
        lock = false;
        disp("ERROR: point not found. Going to next file")
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
