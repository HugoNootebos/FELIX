function data = PlotFolder(folder, mass)
%input a folder with .h5 files and time-of-flight mass (/60,000) of desired
%molecule. Output is a 2xn matrix

%----------------------------handles-------------------------------------------------------------
    int = 4; %integration width
    width = 1600; %screen dimensions
    height = 780;

    %modes
    closing = false;
    averaging = true;
    power_cal = true;
    smoothening = false;
    massSpec = true;
    trueWavelength = true;
%----------------------------handles-------------------------------------------------------------
    
    %--init--
    source = dir(folder);
    plotFiles = "";
    wl = [];
    intensity = [];
    err_count = 0;
    err_lst = [];
    problem_wl = [];
    skips = 0;

    %making list of filenames
    disp("Reading folder: " + folder)
    if closing
        close all
    end
    for i = 1:length(source)
        if endsWith(source(i).name,".h5") == 1
            plotFiles(end+1) = folder + "/" + source(i).name;
        end
    end
    plotFiles(1) = [];

    %mass spec GUI
    dims = ceil(sqrt(length(plotFiles)));
    tiledlayout(dims,dims)
    set(gcf,'position',[0 0 width*3/4 height*3/4])

    %reading data points
    for file = 1:length(plotFiles)
        ref = massSpec;
        params = h5read(plotFiles(file),"/Parameters");
        if params.scanStop > params.scanStart
            ud = 1;
        else
            ud = -1;
        end
        for wli = params.scanStart : ud*params.scanStep : params.scanStop-ud*params.scanStep %skipped points could lead to missing data at end of loop
            ms = MassSpec(plotFiles(file), wli);
            if ms == -1
                disp("ERROR: point not found. Looking for skipped points...")
                term = true;
                %data appears to randomly skip points, fix here
                for i = 1:4
                   ms = MassSpec(plotFiles(file), wli + ud*i*params.scanStep);
                   if ms ~= -1
                       term = false;
                       disp(i + " point(s) appear to be skipped. Continuing...")
                       skips = skips + i;
                       break
                   end
                end
                if term
                    disp("ERROR cannot be resolved. Moving onto next file")
                    err_count = err_count+1;
                    err_lst = [err_lst,file];
                    problem_wl = [problem_wl, wli];
                    break
                end
            end
            background_rng = [40 2];
            background = mean(smooth(smooth(ms(mass-background_rng(1)*int : mass-background_rng(2)*int))));
            integral = 0;
            for i = -int:1:int
                integral = integral + ms(mass+i) - background;
            end
            if ref
                nexttile
                tof = 1:1:60000;
                plot(tof,ms)
                xline([mass-int, mass+int], '--r');
                xline(mass,'k');
                xline([mass-background_rng(1)*int, mass-background_rng(2)*int], '--g')
                ax = gca;
                ax.XLim = [mass-3*int mass+3*int];
                title("MS file: " + file)
                ref = false;
            end
            intensity(end+1) = -integral;
            wl(end+1) = wli;
        end
    end
    if trueWavelength
        wl = wl/2;
    end
    [wl, I] = sort(wl);
    intensity = intensity(I);
    if averaging
        dupes = 0;
        index = double.empty;
        for i = 1:length(wl)-1
            if wl(i) == wl(i+1)
                dupes = dupes + 1;
            else
                index(1,end+1) = i;
                index(2,end) = dupes;
                dupes = 0;
            end
        end
        data = double.empty;
        for i = 1:length(index)
            if index(2,i) ~= 0
                dupes = index(2,i);
                sum = intensity(index(1,i));
                for ii = 1:dupes
                    sum = sum + intensity(index(1,i)+ii);
                end
                data(1,end+1) = wl(index(1,i));
                data(2,end) = sum/dupes;
            else
                data(1,end+1) = wl(index(1,i));
                data(2,end) = intensity(index(1,i));
            end
        end
        if power_cal
            for i = 1:length(data)
                w = data(1,i);
                power = -0.0001054*w^3 + 0.1661*w^2 - 87.18*w + 15220;
                data(2,i) = data(2,i)/abs(power);
            end
        end
        if smoothening
            data(2,:) = smooth(data(2,:));
        end

        %printing diagnostics
        disp("Skipped points: " + skips)
        disp(length(plotFiles) - err_count + "/" + length(plotFiles) + " files plotted successfully")
        if ~isempty(err_lst)
            disp(err_lst)
            disp(problem_wl)
        end

        %plotting
        figure('Name',folder);
        plot(data(1,:), data(2,:))
        % for i = 1:height
        %     plot(data(1,:),data(i,:))
        % end
        xlabel("wavelength (nm)")
        ylabel("Intensity (arbitrary units)")
        grid on
        grid minor
        set(gcf,'position',[0 height/4 width*3/4 height*3/4])
        writematrix(data,"PlotFolder_out.csv")
        exportgraphics(gcf,"PlotFolder_out_nm.png");
    else
        % wavenumbers = 1./(wl.*10^(-7));
        % [wavenumbers, I2] = sort(wavenumbers);
        % intensity_wn = intensity(I2);
        % figure('name',"cm" + folder);
        % plot(wavenumbers,intensity_wn)
        % xlabel("Wavenumbers (cm-1)")
        % ylabel("Intensity (arbitrary units)")
        % grid on
        % grid minor
        % %set(gca, 'XDir','reverse')
        % exportgraphics(gcf,"PlotFolder_out_cm.png");
        figure('name',"nm" + folder);
        plot(wl,intensity);
        xlabel("wavelength (nm)")
        ylabel("Intensity (arbitrary units)")
        grid on
        grid minor
    end
end
