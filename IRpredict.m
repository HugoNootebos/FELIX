function data = IRpredict(file)
    scaling = false;
    manual = false;
    plotting = false;
    anharmonic = true; %if false then read harmonic .out files only

    fid = fopen(file);
    tline = fgetl(fid);
    dataset = zeros(2,0);
    while ischar(tline)
        if anharmonic
            line = "OVERTONES AND COMBINATION BANDS";
            firstChar = 10;
        else
            line = "IR SPECTRUM";
            firstChar = 5;
        end
        if contains(tline,line)
            for i = 1:6
                tline = fgetl(fid);
            end
            while tline ~= ""
                current_line = convertStringsToChars(tline);
                lock = 0;
                for i = firstChar:length(current_line)
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
    wavenumber = 0.01:0.01:3500;
    fwhm = 10;
    dirac = zeros(1,length(wavenumber));
    for i = 1:length(dataset)
        for ii = 1:length(wavenumber)
            if dataset(1,i) == wavenumber(ii)
                dirac(ii) = dataset(2,i);
            end
        end
    end
    data = [wavenumber ; dirac];
    data(2,:) = data(2,:)./8;
    if scaling
        pivot1 = 3034;
        peak1 = 1.23;%27.37;
        pivot2 = 3096;
        peak2 = 7.01;%21.87;
        for i = 1:length(data)
            if data(2,i) == peak1
                wn1 = data(1,i);
            elseif data(2,i) == peak2
                wn2 = data(1,i);
            end
        end
        stretch = (pivot1-pivot2)/(wn1-wn2);
        data(1,:) = data(1,:).*stretch;
        disp("Scaling factor: " + stretch)
        %range = 0.000075;
        for i = 1:length(data)
            if data(2,i) == peak1   %data(2,i) > 0.13685 - range && data(2,i) < 0.13685 + range
                offset = data(1,i) - pivot1;
                disp("offset = " + offset)
            end
        end
        data(1,:) = data(1,:) - offset;
    end
    if manual
        stretch = 0.99355;
        offset = 92.7796;
        data(1,:) = data(1,:).*stretch - offset;
    end
    writematrix(data,"outIRpredict.csv")
    if plotting
        figure('Name',file);
        plot(wavenumber,dirac)
        xlabel("wavenumber (cm-1)");
        ylabel("intensity");
        title("IR prediction: " + file);
        exportgraphics(gcf,"IRpredict_out.png");
    end
end
