import argparse

def options():
    parser = argparse.ArgumentParser()
    parser.add_argument('--fname', type=str, required=True)
    parser.add_argument('--tres', type=float, required=False, default=0.5)
    parser.add_argument('--outname', type=str, required=False, default="tmp")
    parser.add_argument('--mip', action='store_true')
    parser.add_argument('--ref', type=str, help='ref', required=False)
    parser.add_argument('--scaling', type=float, help='scaling', required=False, default=1e6)
    parser.add_argument('--troi', type=str, help='index', required=False, default='')
    parser.add_argument('--xroi', type=str, help='index', required=False, default='')
    parser.add_argument('--yroi', type=str, help='index', required=False, default='')
    parser.add_argument('--zroi', type=str, help='index', required=False, default='')
    parser.add_argument('--vrange', type=str, help='index', required=False, default='0,1')
    parser.add_argument('--subspace', action='store_true')
    parser.add_argument('--show_axis', type=str, help='x,y,z / x,y / x,z / y,z', required=False, default='x,y,z')
    parser.add_argument('--cmap', type=str, help='cmap', required=False, default='grey')
    parser.add_argument('--axis', type=int, help='0 horizontal, 1 vertical', required=False, default=0)
    parser.add_argument('--filetype', type=str, help='mp4/png', required=False, default='mp4')
    parser.add_argument('--mask', type=str, help='mask', required=False)
    args = parser.parse_args()

    return args

def parse_list(roi, dtype='int'):
    if roi == '':
        return None
    if dtype == 'int':
        r = [int(i) for i in roi.split(',')]
    elif dtype == 'float':
        r = [float(i) for i in roi.split(',')]
    return r