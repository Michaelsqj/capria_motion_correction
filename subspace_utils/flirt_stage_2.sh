# 1. split the combined images into 3D volumes

# 2. register odd image to even image, using flirt

# 3. register odd image to reference image, using flirt

# 3. concatenate the transformation
#       convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
