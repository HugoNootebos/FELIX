function data = PlotFolderOPO(folder, mass)
%Function for plotting .h5 files with 2 Trace channels. Returns 2xn matrix

%----------------------------handles------------------------------------------------------------
    strt = [3100, 3100, 3060, 3060, 3020, 3020, 3140, 3140, 2940, 2940, 2900, 2900, 2980]; %magic numbers. The wavenumber at which each scan starts. IN ORDER
    pts = 334; %Number of points in each scan
    rng = 40; %Wavenumbers covered in one scan
    int = 4; %width of integration
    width = 1600; %screen dimensions
    height = 780;

    %modes
    smoothening = true; %set plotAll to false
    plotAll = false; %for plotting all channels
%----------------------------handles-------------------------------------------------------------
    
    %--init--
    basis = [];
    doubles = [];
    plotFiles = "";
    channel1 = [];
    channel2 = [];
    wavenumbers = [];
    dep = [];
    lock = true;
    dep2 = [];
    wn2 = [];

    %making list of filenames
    for file = 1:length(strt)
        if ismember(strt(file),basis) 
            doubles(end+1) = file;
        else
            basis(end+1) = strt(file);
        end
    end
    disp("Reading folder: " + folder)
    source = dir(folder);
    for file = 1:length(source)
        if endsWith(source(file).name,".h5") == 1
            plotFiles(end+1) = folder + "/" + source(file).name;
        end
    end
    plotFiles(1) = [];

    %mass spec GUI
    dims = ceil(sqrt(length(plotFiles)));
    tiledlayout(dims,dims)
    set(gcf,'position',[0 0 width*3/4 height*3/4])

    %reading data points
    for file = 1:length(plotFiles)
        ref = true;
        for pt = 1:pts
            wavenumbers(end+1) = strt(file)-(pt*rng/pts);
            ms = MassSpecOPO(plotFiles(file),pt);
            if ms == -1
                lock = false;
            end
            if lock
                channel1 = ms(1,:);
                channel2 = ms(2,:);
                integral1 = 0;
                integral2 = 0;
                background_rng = [40 2];
                background1 = mean(smooth(smooth(ms(1, mass-background_rng(1)*int : mass-background_rng(2)*int))));
                background2 = mean(smooth(smooth(ms(2, mass-background_rng(1)*int : mass-background_rng(2)*int))));
                for ii = -int:1:int
                    integral1 = integral1 + channel1(mass+ii)/background1;
                    integral2 = integral2 + channel2(mass+ii)/background2;
                    %divide by background?
                end
                dep(end+1) = -log(integral1/integral2);
            else
                lock = true;
            end
            if ref
                nexttile
                tof = 1:1:60000;
                plot(tof,channel1,'r')
                plot(tof,channel2,'k')
                xline([mass-int, mass+int], '--r');
                xline(mass,'k');
                xline([mass-background_rng(1)*int, mass-background_rng(2)*int], '--g')
                ax = gca;
                ax.XLim = [mass-3*int mass+3*int];
                title("MS file: " + file)
                ref = false;
            end
        end
    end
    for file = 2:length(doubles)+1
        dep2 = [dep2,dep(pts*(file-1):pts*(file))];
        wn2 = [wn2,wavenumbers(pts*(file-1):pts*(file))];
        dep(pts*(file-1):pts*(file)) = [];
        wavenumbers(pts*(file-1):pts*(file)) = [];
    end
    [wavenumbers, I] = sort(wavenumbers);
    dep = dep(I);
    [wn2, I2] = sort(wn2);
    dep2 = dep2(I2);
    if smoothening
        for file = 1:length(wn2)
            for ii = 1:length(wavenumbers)
                if wn2(file) == wavenumbers(ii)
                    dep(ii) = (dep2(file)+dep(ii))/2;
                end
            end
        end
        dep = smooth(dep);
    end

    %Plotting
    figure('name',folder);
    plot(wavenumbers,dep)
    set(gcf,'position',[0 height/4 width*3/4 height*3/4])
    hold on
    if plotAll
        plot(wn2,dep2)
    end
    xlabel("Wavenumbers (cm-1)")
    ylabel("Cross section (-ln(dep))")
    grid on
    grid minor
    exportgraphics(gcf,"PlotFolderOPO_out.png");
    dep = transpose(dep);
    data = [wavenumbers ; dep];
    writematrix(data,"outOPO.csv")
    hold off
end
