DWI data require preprocessing prior to estimating the diffusion tensor and completing the TBSS analysis. The pipeline ideally includes the following steps:

•	Denoising
•	Susceptibility distortion correction
•	Motion correction
•	Eddy current correction

Notably, deringing (removal of Gibbs ringing artifact) is optional since there is little evidence this step is necessary.

Prior to preprocessing, check your data for artifacts. This resource might be helpful:
https://sites.google.com/a/labsolver.org/dsi-studio/course/diffusion-mri-signals

In the event that artifacts are observed, you can remove them using the remove_badvols.sh script, which will drop the volumes from both the dwi series and the bval and bvec files.

If data are already preprocessed, they do not need re-processing. However if preprocessing is required, QSIprep can complete all of the steps in a convenient wrapper, and so we recommend this (but feel free to use a different pipeline or set of functions).

QSIprep installation information is available here: https://qsiprep.readthedocs.io/en/latest/installation.html

Once installed, the following command will ensure all corrections noted above are implemented:

qsiprep -i $inputdir -o $outputdir -d $workdir -l qsilog.log --output-resolution 1.00 --separate-all-dwis --participant_label $subname --hmc_model eddy --fs-license-file $FS_license_location


If there are GPUs available on your computing system, you can implement slice to volume correction using FSL eddy. In this case, the command looks a little different, and includes the eddy_config flag:

qsiprep -i $inputdir -o $outputdir -d $workdir -l qsilog.log --output-resolution 1.00 --separate-all-dwis --participant_label $subname --hmc_model eddy --fs-license-file $FS_license_location eddy_config eddy_params.json

An example of the eddy_params.json content is available in this repository. You will need to provide your own slice order information (in a file called slspec.txt) and specify mporder after following the guidelines provided here to identify a reasonable parameter: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy/UsersGuide#A--mporder
