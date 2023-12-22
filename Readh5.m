function [wavelength_set,intensity] = Readh5(file,mass)
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
            %integrate intensity of +- 7 points around mass tof
            integral = 0;
            for i = -7:1:7
                integral = integral + current_I(mass+i);
            end
            intensity(end+1) = -integral;
            wavelength_set(end+1) = wavelength;
        end
    end
end
