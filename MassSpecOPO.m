function intensity = MassSpecOPO(file,point)
    %reading the mass spectrum of one point in an h5 file
    plotting = false;
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
    try
        intensity = h5read(file, "/Rawdat/P" + add + point + "_" + num2str(point,'%.4f') + "/Trace");
        disp("Loading P" + add+point+"/"+num2str(point,'%.4f') + " from " + file_char(25:end))
    catch
        %continue to next file
        intensity = -1;
    end
    if plotting
        tof = 1:1:60000;
        figure();
        plot(tof,intensity(1,:));
        xlabel("time of flight")
        ylabel("intensity")
        figure();
        plot(tof,intensity(1,:));
        xlabel("time of flight")
        ylabel("intensity")
        % if lock
        %     tof = [];
        %     intensity_set = [];
        %     sz = size(intensity);
        %     for ii = 1:sz(1)
        %         background = mean(intensity(ii,:),'all');
        %         for i = 1:length(intensity)
        %             tof(end+1) = i;
        %             intensity_set(ii,end+1) = intensity(i) - background;
        %         end
    end
end
