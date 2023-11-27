function data = IRpredict(file)
    %data = readtable(file);
    freq = zeros(1,4000);
    data_freq = [2000, 1500, 1200, 1000];%data();
    data_intensity = [1,2,10, 1];%data();
    for i = 1:length(data_freq)
        current_freq = round(data_freq(i),0);
        if current_freq == freq(current_freq)

    figure(1);
    plot(freq, intensity)
    xlabel("wavenumber (cm-1)");
    ylabel("intensity");
    title("IR prediction: " + file);
    exportgraphics(gcf,"IRpredict_out.png");
end