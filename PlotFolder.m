function [wavenumbers, intensity] = PlotFolder(folder, mass)
    disp("Reading folder: " + folder)
    source = dir(folder);
    plotFiles = "";
    for i = 1:length(source)
        if endsWith(source(i).name,".h5") == 1
            plotFiles(end+1) = folder + "/" + source(i).name;
        end
    end
    plotFiles(1) = [];
    wavelength_range = [];
    intensity = [];
    err_count = 0;
    err_files = [];
    for ii = 1:length(plotFiles)
        [new_wavelength_range, new_intensity] = Readh5(plotFiles(ii),mass);
        wavelength_range = [wavelength_range, new_wavelength_range];
        intensity = [intensity, new_intensity];
        if isempty(Readh5(plotFiles(ii),mass))
            err_count = err_count + 1;
        end
    end
    wavelength_range = wavelength_range;%/2;
    wavenumbers = 1./(wavelength_range.*10^(-7));
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
    plot(wavelength_range,intensity);
    xlabel("wavelength (nm)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
    exportgraphics(gcf,"PlotFolder_out_nm.png");
    out = [wavenumbers;intensity];
    writematrix(out,"out.csv")
end
