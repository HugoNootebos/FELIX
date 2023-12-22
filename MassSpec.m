function [tof,intensity_set] = MassSpec(file,wavelength)
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
        intensity_set_raw = h5read(file, "/Rawdat/P" + add + point + "_" + num2str(wavelength,'%.4f') + "/Trace");
        disp("Loading " + add+point+"/"+num2str(wavelength,'%.4f' + " from " + file_char(25:end)))
    catch
        %continue to next file
        tof = -1;
        intensity_set = -1;
        lock = false;
    end
    if lock
        tof = [];
        intensity_set = [];
        background = mean(intensity_set_raw);
        for i = 1:length(intensity_set_raw)
            tof(end+1) = i;
            intensity_set(end+1) = intensity_set_raw(i) - background;
        end
        % plot(tof,intensity_set)
        % xlabel("time of flight")
        % ylabel("intensity")
    end
end
