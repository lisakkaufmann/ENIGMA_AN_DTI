The method of freewater correction will vary depending on whether data are single or multi-band.

For single band data, use an adaption of the Fernet package (https://github.com/DiCIPHR-Lab/Fernet), available for download here, and single-band_fw.py script. 

For multiband data, you can use the multi-band script: multi-band_fw.py.

Both scripts use python packages and tools. You will need to have the following packages in your python library:
numpy, nibabel, dipy
