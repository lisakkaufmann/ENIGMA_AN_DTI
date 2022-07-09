#! /usr/bin/env python
from __future__ import print_function

import os
import numpy as np
import nibabel as nib
import argparse
import sys


DESCRIPTION = '''
Multi-shell FW correction
'''

def buildArgsParser():
    p = argparse.ArgumentParser(description=DESCRIPTION)
    p.add_argument('-d','-k','--data',action='store',metavar='data',dest='dwis_filename',
                    type=str, required=True, 
                    help='Input DWIs data file (Nifti or Analyze format).'
                    )
    p.add_argument('-r','--bvecs', action='store', metavar='bvecs', dest='bvecs',
                    type=str, required=False, default=None,
                    help='Gradient directions (.bvec file).'
                    )
    p.add_argument('-b','--bvals', action='store', metavar='bvals', dest='bvals',
                    type=str, required=False, default=None,
                    help='B-values (.bval file).'
                    )

    p.add_argument('-o', '--output', action='store', metavar='output', dest='output',
                    type=str, required=True,
                    help='Output basename for init tensor map and volume fraction.'
                    )

    return p

def main():    
    parser = buildArgsParser()
    args = parser.parse_args()
    dwis_filename = args.dwis_filename
    bvals_filename = args.bvals
    bvecs_filename = args.bvecs
    output_basename = args.output
    print('''
     Multi-shell FW correction
    -------------------------------------------------------
''')
    run_fw_ms(dwis_filename, bvals_filename, bvecs_filename, output_basename)
                
def run_fw_ms(dwis_filename, bvals_filename, bvecs_filename, output_basename):

  import nibabel as nib
  import dipy
  import dipy.reconst
  import dipy.reconst.fwdti as fwdti
  import dipy.reconst.dti as dti
  import matplotlib.pyplot as plt
  import numpy as np
  from dipy.data import fetch_cenir_multib
  from dipy.data import read_cenir_multib
  from dipy.segment.mask import median_otsu
  from dipy.io import read_bvals_bvecs
  bvals, bvecs = read_bvals_bvecs(bvals_filename, bvecs_filename)
  from dipy.core.gradients import gradient_table
  gtab = gradient_table(bvals, bvecs)
  from dipy.io.image import load_nifti
  data, affine, img = load_nifti(dwis_filename, return_img=True)
  maskdata,mask = median_otsu(data, vol_idx=[0, 1], median_radius=4, numpass=2,
                             autocrop=False, dilate=1)
  from dipy.io.image import save_nifti
  save_nifti("mask.nii.gz", maskdata, affine)
  fwdtimodel = fwdti.FreeWaterTensorModel(gtab)
  fwdtifit = fwdtimodel.fit(maskdata)
  FA = fwdtifit.fa
  MD = fwdtifit.md

  dtifit = dtimodel.fit(maskdata)
  FA_orig = dtifit.fa
  MD_orig = dtifit.md

  from dipy.io.image import save_nifti
  name=dest+"_fw_corrected_FA.nii.gz"
  name1= dest+"_FA.nii.gz"
  name2= dest+"_fw_corrected.nii.gz"
  save_nifti(name, FA, affine)
  save_nifti(name1, FA_orig, affine)
  save_nifti(name2, fwdtifit, affine)


if __name__ == '__main__':
    main()

