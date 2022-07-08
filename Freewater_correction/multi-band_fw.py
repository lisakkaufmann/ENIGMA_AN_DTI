import sys
fdwi=sys.argv[1]
bval=sys.argv[2]
bvec=sys.argv[3]
mask=sys.argv[4]

import nibabel as nib
import dipy
import dipy.reconst
import dipy.reconst.fwdti as fwdti
import dipy.reconst.dti as dti
import matplotlib.pyplot as plt
from dipy.data import fetch_cenir_multib
from dipy.data import read_cenir_multib
from dipy.segment.mask import median_otsu
from dipy.io import read_bvals_bvecs
bvals, bvecs = read_bvals_bvecs(bval, bvec)
from dipy.core.gradients import gradient_table
gtab = gradient_table(bvals, bvecs)
n=len(bval)
from dipy.io.image import load_nifti
data, affine, img = load_nifti(fdwi, return_img=True)
maskdata,mask = median_otsu(data, vol_idx=[0, 1], median_radius=4, numpass=2,
                             autocrop=False, dilate=1)

fwdtimodel = fwdti.FreeWaterTensorModel(gtab)
fwdtifit = fwdtimodel.fit(maskdata)
FA = fwdtifit.fa
MD = fwdtifit.md

dtifit = dtimodel.fit(maskdata)
FA_orig = dtifit.fa
MD_orig = dtifit.md

from dipy.io.image import save_nifti
name=fdwi.replace(".nii.gz","_fw_corrected.nii.gz")
name1= fdwi.replace(".nii.gz","_fa.nii.gz")
save_nifti(name, FA, affine)
save_nifti(name1, FA_orig, affine)
save_nifti("mask.nii.gz", maskdata, affine)
