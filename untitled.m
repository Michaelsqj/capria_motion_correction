p.a=1
p.b=2
p.c=3
p.cone_type='radial'
C = namedargs2cell(p)
% p={'a',a,'b',b,'c',c,'cone_type',cone_type};
% ttest('a',p.a,'b',p.b,'c',p.c,'cone_type',p.cone_type)
% 
% S.XLim = [1,100];
% S.Color = "red";
% S.Box = "on";
% C = namedargs2cell(S)
ttest(C(:))
function ttest(varargin)
varargin=varargin{1,1}
% type(varargin)

p = inputParser;
p.KeepUnmatched = true;
p.addParameter('a', 6);
p.addParameter('b',     2);
p.addParameter('c',     2);
p.addParameter('cone_type',     'cone');
p.parse(varargin{:});
p = p.Results;

p.a
p.b
p.c
p.cone_type
end