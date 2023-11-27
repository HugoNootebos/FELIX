classdef BestFitPolynomial
    properties
        order
        value
        coeffs
        x = [1,2,3,4]
        y = [1, 2, 3, 4]
    end

    methods
        function obj = setOrder(obj, n)
            obj.order = n;
            obj.coeffs = polyfit(obj.x,obj.y,obj.order);
            
            obj.value
        end

        function obj = out(obj)
            string = '';
            for i = obj.order:-1:1
                string = string + obj.coeffs(i);
            end
            disp(string)
        end

        function obj = importData(obj,x,y)
        end
    end
end