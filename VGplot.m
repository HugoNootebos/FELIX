function dataset = VGplot(file)

%for opening .spectrum files

    fid = fopen(file); 
    tline = fgetl(fid);
    dataset = zeros(2,0);
    while ischar(tline)
        if contains(tline,"Energy			TotalSpectrum		IntensityFC		IntensityHT")
            tline = fgetl(fid);
            start1 = 1;
            while ischar(tline)
                current_line = convertStringsToChars(tline);
                lock = 1;
                for i = 1:length(current_line)
                    if lock == 1 & current_line(i) == '.'
                        end1 = i+4;
                        lock = 2;
                    elseif lock == 2 & current_line(i) == "e"
                        start2 = i-8;
                        end2 = i+3;
                        lock = 3;
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
    figure('Name',file);
    plot(dataset(1,:),dataset(2,:))
    xlabel("energy");
    ylabel("intensity");
    title("VG prediction: " + file);
    exportgraphics(gcf,"VGplot_out.png");
end
