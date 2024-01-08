function [wavenumbers, intensity_wn] = PlotFolder(folder, mass)
    disp("Reading folder: " + folder)
    int = 6;
    source = dir(folder);
    plotFiles = "";
    for i = 1:length(source)
        if endsWith(source(i).name,".h5") == 1
            plotFiles(end+1) = folder + "/" + source(i).name;
        end
    end
    plotFiles(1) = [];
    wl = [];
    intensity = [];
    err_count = 0;
    err_lst = [];
    for file = 1:length(plotFiles)
        params = h5read(plotFiles(file),"/Parameters");
        if params.scanStop > params.scanStart
            ud = 1;
        else
            ud = -1;
        end
        wavelength_set = [];
        for wli = params.scanStart : ud*params.scanStep : params.scanStop-ud*params.scanStep
            ms = MassSpec(plotFiles(file), wli);
            if ms == -1
                term = true;
                %data appears to randomly skip points, fix here
                for i = -5:1:5
                   ms = MassSpec(plotFiles(file), wli-i*params.scanStep);
                   if ms ~= -1
                       term = false;
                   end
                end
                if term
                    err_count = err_count+1;
                    err_lst = [err_lst,file];
                    break
                end
            end
            %integrate intensity of +- int points around mass tof
            integral = 0;
            for i = -int:1:int
                integral = integral + ms(mass+i);
            end
            intensity(end+1) = -integral;
            wl(end+1) = wli;
        end
    end
    %wl = wl/2;
    wavenumbers = 1./(wl.*10^(-7));
    disp(length(plotFiles) - err_count + "/" + length(plotFiles) + " files plotted successfully")
    disp(err_lst)
    [wl, I] = sort(wl);
    intensity = intensity(I);
    [wavenumbers, I2] = sort(wavenumbers);
    intensity_wn = intensity(I2);
    figure('name',"cm" + folder);
    plot(wavenumbers,intensity_wn)
    xlabel("Wavenumbers (cm-1)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
    %set(gca, 'XDir','reverse')
    exportgraphics(gcf,"PlotFolder_out_cm.png");
    figure('name',"nm" + folder);
    plot(wl,intensity);
    xlabel("wavelength (nm)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
    exportgraphics(gcf,"PlotFolder_out_nm.png");
    out = [wavenumbers;intensity_wn];
    writematrix(out,"out.csv")
end
