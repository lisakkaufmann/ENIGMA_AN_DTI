# This repository is to support the completion of tract-based spatial statistics (TBSS) analyses for the ENIGMA-AN DTI working group

The aim of the TBSS analysis is to describe white matter alterations that are present among individuals with AN relative to healthy control peers (HC). This is possible via analysis of diffusion imaging data, which is sensitive to differences in the direction of water diffusion throughout the brain. When diffusion is more directed within white-matter tracts, it is assumed these tracts have better structural integrity. Where diffusion is more isotropic within white-matter (i.e., undirected) this can suggest poorer integrity of the brain tissue, potentially due to axonal degeneration or reduced myelination/axonal density. In this analysis we will estimate the direction of water flow in each voxel along a white matter skeleton. Average diffusion metrics (across voxels within 25 distinct regions of interest) will be calculated, and compared between individuals with AN and HC. The between-group analyses will generate a set of test statistics that will be combined across different sites in a meta-analysis, for large-scale comparison of white matter characteristics between individuals with AN and HC. 

To identify the diffusion properties in voxels along a white matter skeleton we will use the FSL TBSS method (described here: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/TBSS/UserGuide). This, and the calculation of white matter properties across the 25 regions of interest, is implemented using the ENIGMA workflow developed by Billah and colleagues (https://github.com/pnlbwh/TBSS). Some very minor changes have been made to the original pipeline, so as to calculate some additional metrics, including weighted tensor metrics in both the core and peripheral skeleton. The version we will use is here: https://github.com/CaitlinLloyd/TBSS_ENIGMA_AN

The instructions outlined in the "Instructions" word document are intended to allow the different sites to complete the analyses and submit results for the meta-analysis, however the processing and analyses can be completed centrally if the data sharing agreements permit this.

### Download this repository and follow the Instructions document to get started. 

## References

Billah, Tashrif; Bouix, Sylvain; Pasternak, Ofer; Generalized Tract Based Spatial Statistics (TBSS) pipeline, https://github.com/pnlbwh/tbss, 2019, DOI: https://doi.org/10.5281/zenodo.2662497

Smith SM, Jenkinson M, Johansen-Berg H, Rueckert D, Nichols TE, Mackay CE, Watkins KE, Ciccarelli O, Cader MZ, Matthews PM, Behrens TE. Tract-based spatial statistics: voxelwise analysis of multi-subject diffusion data. Neuroimage. 2006 Jul 15;31(4):1487-505. doi: 10.1016/j.neuroimage.2006.02.024.

## Acknowledgements

Thank you to Shuchen Hu and Marta Pena for assistance with script development and testing.
