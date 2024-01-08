function [wavenumbers,dep] = PlotFolderOPO(folder, mass)
    strt = [3100, 3100, 3060, 3060, 3020, 3020, 3140, 3140, 2940, 2940, 2900, 2900, 2980]; %magic numbers. The wavenumber at which each scan starts. IN ORDER
    pts = 334; %Number of points in each scan
    rng = 40; %Wavenumbers covered in one scan
    int = 6; %width of integration
    smoothening = true; %set plotAll to false
    plotAll = false; %for plotting all channels
    basis = [];
    doubles = [];
    for i = 1:length(strt)
        if ismember(strt(i),basis) 
            doubles(end+1) = i;
        else
            basis(end+1) = strt(i);
        end
    end
    disp("Reading folder: " + folder)
    source = dir(folder);
    plotFiles = "";
    for i = 1:length(source)
        if endsWith(source(i).name,".h5") == 1
            plotFiles(end+1) = folder + "/" + source(i).name;
        end
    end
    plotFiles(1) = [];
    channel1 = [];
    channel2 = [];
    wavenumbers = [];
    dep = [];
    lock = true;
    for i = 1:length(plotFiles)
        for pt = 1:pts
            wavenumbers(end+1) = strt(i)-(pt*rng/pts);
            ms = MassSpecOPO(plotFiles(i),pt);
            if ms == -1
                lock = false;
            end
            if lock
                channel1 = ms(1,:);
                channel2 = ms(2,:);
                integral1 = 0;
                integral2 = 0;
                for ii = -int:1:int
                    integral1 = integral1 + channel1(mass+ii);
                    integral2 = integral2 + channel2(mass+ii);
                end
                dep(end+1) = -log(integral1/integral2);
            else
                lock = true;
            end
        end
    end
    dep2 = [];
    wn2 = [];
    for i = 2:length(doubles)+1
        dep2 = [dep2,dep(pts*(i-1):pts*(i))];
        wn2 = [wn2,wavenumbers(pts*(i-1):pts*(i))];
        dep(pts*(i-1):pts*(i)) = [];
        wavenumbers(pts*(i-1):pts*(i)) = [];
    end
    [wavenumbers, I] = sort(wavenumbers);
    dep = dep(I);
    [wn2, I2] = sort(wn2);
    dep2 = dep2(I2);
    if smoothening
        for i = 1:length(wn2)
            for ii = 1:length(wavenumbers)
                if wn2(i) == wavenumbers(ii)
                    dep(ii) = (dep2(i)+dep(ii))/2;
                end
            end
        end
        dep = smooth(dep);
    end
    figure('name',folder);
    plot(wavenumbers,dep)
    hold on
    if plotAll
        plot(wn2,dep2)
    end
    xlabel("Wavenumbers (cm-1)")
    ylabel("Cross section (-ln(dep))")
    grid on
    grid minor
    exportgraphics(gcf,"PlotFolderOPO_out.png");
    hold off
end
