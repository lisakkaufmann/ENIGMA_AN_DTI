The method of freewater correction will vary depending on whether data are single or multi-band.

For single band data, use an adaption of the Fernet package (https://github.com/DiCIPHR-Lab/Fernet), available for download here, and single-band_fw.py script. 

You will need to extract the corrected b0 volumes first, average them, and extract the brain from this average mask.
To extract b0 volumes use (note this only works if B0 volumes were collected at the beginning of the scan - check the acquisition protocol): 
fslroi $preprocessed_dwi_data $preprocessed_dwi_data_b0_volumes 0 $number_B0_vols 

Average these using: 
fslmaths $preprocessed_dwi_data_b0_volumes -Tmean $preprocessed_dwi_data_meanb0

Extract the brain with:
bet2 $preprocessed_dwi_data_meanb0 $preprocessed_dwi_data_meanb0_mask

To run the freewater correction on your single shell data, you will need to download the file called "net" to your python library. Once you have done that, simply use the command: 

python fernet.py -d $preprocessed_dwi_data -b $bval_file -r $bvec_file -m $b0_mask -o $path_to_output+prefix

For multiband data, you can use the multi-band script based on dipy tools (https://dipy.org/documentation/1.0.0./examples_built/reconst_fwdti/): multi-band_fw.py.

Both scripts use python packages and tools. You will need to have the following packages in your python library:
numpy, nibabel, dipy
