function [wavelength_set,intensity] = Readh5(file,mass)
    int = 10;
    params = h5read(file,"/Parameters");
    if params.scanStop > params.scanStart
        ud = 1;
    else
        ud = -1;
    end    
    %fail = true;
    intensity = [];
    wavelength_set = [];
    resume = true;
    %for wavelength = params.scanStop-ud*params.scanStep:-ud*params.scanStep:params.scanStart
    for wavelength = params.scanStart:ud*params.scanStep:params.scanStop-ud*params.scanStep
        [current_tof, current_I] = MassSpec(file, wavelength);
        if current_tof == -1
            disp("Scan ends at " + wavelength + ". Opening next file")
            resume = false;
            break
        end
        if resume
            sz = size(current_I);
            if sz(1) == 2
                current_I = current_I(1,:) - current_I(2,:);
            end
            %integrate intensity of +- int points around mass tof
            integral = 0;
            for i = -int:1:int
                integral = integral + current_I(mass+i);
            end
            intensity(end+1) = -integral;
            wavelength_set(end+1) = wavelength;
        end
    end
end
