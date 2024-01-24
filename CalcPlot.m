function void = CalcPlot()
%for plotting measured OPO spectra on top of anharmonic and harmonic
%calculations

    width = 1600; %screen dimensions
    height = 780;

    %Import data
    harmonic = readmatrix("/Users/hnootebos/Documents/MATLAB/outIRpredict2.csv");
    anharmonic = readmatrix("/Users/hnootebos/Documents/MATLAB/outIRpredict.csv");
    opo = readmatrix("/Users/hnootebos/Documents/MATLAB/outOPO.csv");
    
    %Manipulate data
%-----------------------------handles--------------------------------------------------------------
    scaling = false;
    resize = true;
    scaleOnly = true;
    pivot1 = 3048.02;% promising: 3033.89 with peak1 = 10.62
    peak1 = 10.33;
    pivot2 = 1;
    peak2 = 1;
    xopo = 100;
    xharm = 1;
    xanharm = 300;
    anharmCap = 45;
%-----------------------------handles--------------------------------------------------------------
    if scaling
        wn1 = -1;
        wn2 = -1;
        for i = 1:length(harmonic)
            if harmonic(2,i) == peak1
                wn1 = harmonic(1,i);
            elseif harmonic(2,i) == peak2
                wn2 = harmonic(1,i);
            end
        end
        if wn1 == -1
            disp("ERROR: peak1 not found")
        end
        if wn2 == -1
            disp("ERROR: peak2 not found")
        end
        stretch = (pivot1-pivot2)/(wn1-wn2);
        harmonic(1,:) = harmonic(1,:).*stretch;
        disp("Scaling factor: " + stretch)
        for i = 1:length(harmonic)
            if harmonic(2,i) == peak1
                offset = harmonic(1,i) - pivot1;
                disp("Offset = " + offset)
            end
        end
        harmonic(1,:) = harmonic(1,:) - offset;
        anharmonic(1,:) = anharmonic(1,:).*stretch;
        anharmonic(1,:) = anharmonic(1,:) - offset; 
    end
    if resize
        harmonic(2,:) = harmonic(2,:).*xharm;
        anharmonic(2,:) = anharmonic(2,:).*xanharm;
        opo(2,:) = opo(2,:).*xopo;
        for i = 1:length(anharmonic)
            if anharmonic(2,i) > anharmCap
                anharmonic(2,i) = anharmCap;
            end
        end
    end
    if scaleOnly
        for i = 1:length(harmonic)
            if harmonic(2,i) == peak1
                stretch = pivot1/harmonic(1,i);
                disp("Scaling factor: " + stretch)
                break
            end
        end
        anharmonic(1,:) = anharmonic(1,:).*stretch;
        harmonic(1,:) = harmonic(1,:).*stretch;
    end

    %Plotting
    %close all
    figure()
    hold on
    ax = gca;
    ax.XLim = [2860,3140];
    set(gcf,'position',[200 200 width*3/4 height*3/4])
    plot(harmonic(1,:),harmonic(2,:),'Color','b');
    plot(anharmonic(1,:),anharmonic(2,:),'Color','r');
    plot(opo(1,:),opo(2,:));
    legend('harmonic DFT', 'overtones and combination bands', 'opo')
    ylabel("intensity")
    xlabel("wavelength (cm-1)")
end
