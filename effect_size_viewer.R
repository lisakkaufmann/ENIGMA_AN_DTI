###Create a figure to view in FSL
# Make sure you are in the project folder

#Set modality (i.e., FA, MD, RD, AD, etc)

modality <- "FA"
output <- "AN_HC_contrast.nii.gz"
read.csv(paste0("correlations_ENIGMA_",modality,".csv"))
results_map <- function(dataframe,model,output){
  frame <- subset(frame, frame$info==model) 
  frame <- merge(frame, LUT, by.x="test", by.y="Short")
  map <- oro.nifti::readNIfTI("projection.nii.gz")
  data <- map@.Data
  this.im.dat <- ifelse(!(this.im.dat %in% frame$Index),0,this.im.dat)
  frame$Index <- as.character(frame$Index)
  for(i in 1:nrow(frame)){this.im.dat[this.im.dat==(frame$Index[i])] <- as.character(frame$t[i])}
  map@.Data[!is.na(map@.Data)] <- as.numeric(this.im.dat)
  oro.nifti::writeNIfTI(image, output)
}

##You can locate the output in the project folder...open in FSL