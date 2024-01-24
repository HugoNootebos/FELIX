function void = VibProg(file)
    %plots a CSV file and returns any recurring spacings between
    %significant peaks

    %screen dimensions
    width = 1600;
    height = 780;

    %import data
    rempi = readmatrix(file);

%-------------------------handles-----------------------------------------------------------------------------------
    minPeakSize = 0.005;
    damping = 0.9971;
    prog1 = 0.84;
    prog1_start = 569.32;
    prog2 = 0.84;
    prog2_start = 569.12;
    prog3 = 1;
    prog3_start = 1;
    duration = 16;
%-------------------------handles-----------------------------------------------------------------------------------
    
    %plotting
    figure()
    hold on
    set(gcf,'position',[200 200 width*3/4 height*3/4])
    plot(rempi(1,:), rempi(2,:))

    %placing lines
    for i = 0:duration
        xline(prog1_start - prog1*i*(damping^i),'r')
        xline(prog2_start - prog2*i*(damping^i),'--r')
    end
end
