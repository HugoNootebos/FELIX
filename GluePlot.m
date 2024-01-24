function void = GluePlot()
%for plotting sets of data that require separate scaling to fit together

    width = 1600; %screen dimensions
    height = 780;

    %Import data
    data1 = readmatrix("/Users/hnootebos/Desktop/GluePlot/520540.csv");
    data2 = readmatrix("/Users/hnootebos/Desktop/GluePlot/540570.csv");
    x1 = data1(1,:);
    y1 = data1(2,:);
    x2 = data2(1,:);
    y2 = data2(2,:);
    
%-----------------------------handles--------------------------------------------------------------
    autoscale = false;
    manscale = true;
    smoothen = true;
%-----------------------------handles--------------------------------------------------------------

    %Manipulate data
    if autoscale
        glue = y2(1)/y1(end);
        y1 = glue.*y1;
    end
    if manscale
        glue = 0.25;
        y1 = glue.*y1;
    end
    if smoothen

    end

    %Plotting
    close all
    figure()
    hold on
    ax = gca;
    ax.XLim = [min(x1),max(x2)];
    set(gcf,'position',[200 200 width*3/4 height*3/4])
    plot(x1,y1);
    plot(x2,y2);
    legend('data1', 'data2')
    ylabel("intensity")
    xlabel("wavelength (nm)")
end
