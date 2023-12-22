function [wavelength,dirac] = IRpredict(file)
    fid = fopen(file);
    tline = fgetl(fid);
    dataset = zeros(2,0);
    while ischar(tline)
        if contains(tline,"IR SPECTRUM")
            for i = 1:6
                tline = fgetl(fid);
            end
            while tline ~= ""
                current_line = convertStringsToChars(tline);
                lock = 0;
                for i = 5:length(current_line)
                    if lock == 0 & current_line(i) ~= " "
                        start1 = i;
                        lock = 1;
                    elseif lock == 1 & current_line(i) == " "
                        end1 = i-1;
                        lock = 2;
                    elseif lock == 2 & current_line(i) ~= " "
                        lock = 3;
                    elseif lock == 3 & current_line(i) == " "
                        lock = 4;
                    elseif lock == 4 & current_line(i) ~= " "
                        start2 = i;
                        lock = 5;
                    elseif lock == 5 & current_line(i) == " "
                        end2 = i-1;
                        lock = 6;
                        break
                    end
                end
                dataset(1,end+1) = str2num(current_line(start1:end1));
                dataset(2,end) = str2num(current_line(start2:end2));
                tline = fgetl(fid);
            end
        end
        tline = fgetl(fid);
    end
    wavelength = 0.01:0.01:3500;
    fwhm = 10;
    dirac = zeros(1,length(wavelength));
    for i = 1:length(dataset)
        for ii = 1:length(wavelength)
            if dataset(1,i) == wavelength(ii)
                dirac(ii) = dataset(2,i);
            end
        end
    end
    figure('Name',file);
    plot(wavelength,dirac)
    xlabel("wavenumber (cm-1)");
    ylabel("intensity");
    title("IR prediction: " + file);
    exportgraphics(gcf,"IRpredict_out.png");
end
