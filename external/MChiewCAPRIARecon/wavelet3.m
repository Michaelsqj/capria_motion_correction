classdef wavelet3 < matlab.mixin.Copyable
    %------------------
    %  class 
    %    forward: take image input and output wavelet decomposition 
    %       stacked in pyramid way
    %    backward: take pyramid shaped wavelet
    %
    properties
        name
        scale
        transp
        S
        im_size
        sizeINI
        level
        filters
        mode
        sizes
        coenum
    end
    properties ( Access = private )
    end
    methods
        function b = wavelet3(im_size)
            b.transp = 0;
            b.S = [];
            tmp = wavedec3(zeros(im_size), 4, 'db4', 'mode', 'per');
            b.im_size = im_size;
            b.sizeINI = tmp.sizeINI;
            b.level = tmp.level;
            b.filters = tmp.filters;
            b.mode = tmp.mode;
            b.sizes = tmp.sizes;
            b.coenum = 7*b.level+1;
        end
        function b = mtimes(obj, a)
            if obj.transp
                % a: [length(wavelet space), 1]
                w = recoverCoef(obj,a);
                b = waverec3(w);
            else
                a = reshape(a, obj.im_size);
                w = wavedec3(a, 4, 'db4', 'mode', 'per');
                b = flattenCoef(obj,w);
            end
        end
        function b = ctranspose(obj)
            b   =   copy(obj);
            b.transp = xor(obj.transp, 1); 
        end
        
        function b = flattenCoef(obj, w)
            b = reshape(w.dec{1}, [], 1);
            for ii = 2:obj.coenum
                b = [b; reshape(w.dec{ii}, [], 1)];
            end
        end

        function w = recoverCoef(obj, a)
            start = 1;
            w.dec{1,1} = reshape( a(start: start + prod(obj.sizes(1,:))-1), obj.sizes(1,:) );
            start = start + prod(obj.sizes(1,:));
            for n = 1:obj.level
                for ii = 1:7
                    jj = 1 + (n-1)*7 + ii;
                    w.dec{jj,1} = reshape( a(start:start+prod(obj.sizes(n,:))-1), obj.sizes(n,:));
                    start = start + prod(obj.sizes(n,:));
                end
            end
            w.sizeINI   = obj.sizeINI;
            w.level     = obj.level;
            w.filters   = obj.filters;
            w.mode      = obj.mode;
            w.sizes     = obj.sizes;
        end
        
    end
end
