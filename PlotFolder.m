function [wavenumbers, intensity] = PlotFolder(folder, mass)
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
    for file = 1:length(plotFiles)
        params = h5read(plotFiles(file),"/Parameters");
        if params.scanStop > params.scanStart
            ud = 1;
        else
            ud = -1;
        end
        wavelength_set = [];
        for wli = params.scanStart:ud*params.scanStep:params.scanStop-ud*params.scanStep
            ms = MassSpec(plotFiles(file), wli);
            if ms == -1
                disp("Scan ends at " + wli + ". Opening next file")
                break
            end
            %integrate intensity of +- int points around mass tof
            integral = 0;
            for i = -int:1:int
                integral = integral + ms(mass+i);
            end
            intensity(end+1) = -integral;
            wl(end+1) = wli;
        end
        if isempty(Readh5(plotFiles(file),mass))
            err_count = err_count + 1;
        end
    end
    %wl = wl/2;
    wavenumbers = 1./(wl.*10^(-7));
    disp(length(plotFiles) - err_count + "/" + length(plotFiles) + " files plotted successfully")
    figure('name',"cm" + folder);
    plot(wavenumbers,intensity)
    xlabel("Wavenumbers (cm-1)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
    set(gca, 'XDir','reverse')
    exportgraphics(gcf,"PlotFolder_out_cm.png");
    figure('name',"nm" + folder);
    plot(wl,intensity);
    xlabel("wavelength (nm)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
    exportgraphics(gcf,"PlotFolder_out_nm.png");
    out = [wavenumbers;intensity];
    writematrix(out,"out.csv")
end
