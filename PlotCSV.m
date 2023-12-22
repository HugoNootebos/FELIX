function void = PlotCSV(file)
    figure('name',"cm" + file);
    data = readmatrix(file);
    plot(data(1,:),data(2,:));
    xlabel("wavenumbers (cm-1)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
    set(gca, 'XDir','reverse')

    wavelength = 1./(data(1,:).*10^(-7));
    figure('name', "nm" + file);
    plot(wavelength,data(2,:));
    xlabel("wavelength (nm)")
    ylabel("Intensity (arbitrary units)")
    grid on
    grid minor
end
