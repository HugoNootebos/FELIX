function [wavenumbers,intensity] = PlotFolderOPO(folder, mass)
    strt = [3100, 3100, 3060, 3060, 3020, 3020, 3140, 3140, 2940, 2940, 2900, 2900, 2980]; %magic numbers. The wavenumber at which each scan starts. IN ORDER
    pts = 334; %Number of points in each scan
    rng = 40; %Wavenumbers covered in one scan
    disp("Reading folder: " + folder)
    source = dir(folder);
    plotFiles = "";
    for i = 1:length(source)
        if endsWith(source(i).name,".h5") == 1
            plotFiles(end+1) = folder + "/" + source(i).name;
        end
    end
    plotFiles(1) = [];
    range = [];
    intensity = [];
    err_count = 0;
    for ii = 1:length(plotFiles)
        [void, new_intensity] = Readh5(plotFiles(ii),mass);
        intensity = [intensity, new_intensity];
        if isempty(Readh5(plotFiles(ii),mass))
            err_count = err_count + 1;
        end
    end
    wavenumbers = [];
    for i = 1:length(plotFiles)
        for pt = 1:pts
            wavenumbers(end+1) = strt(i)-(pt*rng/pts);
        end
    end
    [wavenumbers, I] = sort(wavenumbers);
    intensity = intensity(I);
    disp(length(plotFiles) - err_count + "/" + length(plotFiles) + " files plotted successfully")
    figure('name',folder);
    plot(wavenumbers,intensity)
    xlabel("Wavenumbers (cm-1)")
    ylabel("Depletion (arbitrary units)")
    grid on
    grid minor
end
