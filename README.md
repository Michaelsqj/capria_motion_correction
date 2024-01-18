# Motion correction

## Pipeline
### Acquisition
1.	Three datasets

    - 	scan_1: strong motion

    -	scan_2: mild motion

    -	scan_3: no motion

### Reconstruction
1.	reconstruct anat, estimate coil sens
2.	register initial anat to anat of scan_3 (perf/angi) -> single transform: xfm1
3.	reconstruct subspace navigator stage 1 
4.	register stage1.sh -> MAT1
5.	reconstruct subspace navigator stage2
6.	register stage2.sh -> MAT2: nav_i -> nav_1
7.	reconstruct anat again with MAT2
8.	register anat to anat of scan_3 (perf/angi) -> single transform: xfm2
9.	concat xfm2 with MAT2, to final registered_MAT3
10.	reconstruct perfusion, angio, struct with motion correction, using registered_MAT3
11.	reconstruct perfusion, angio, struct without motion correction, using xfm1


### Analysis
1.	correlation
    -	vessel mask
    -	brain mask for perfusion
    -	brain mask for structural
    -	calculate correlation of image with masks
2.	fabber_model_asl
    -	vessel mask, first 6 frames
    -	estimation
3.	Segmentation
    -	Brain mask for structural 
    -	Fast or synthseg
