###Create a figure to view your results
library(ggplot2)

# Make sure you are in the project folder
results_map <- function(dataframe,model,modality){
  temp <- subset(dataframe, dataframe$info==model)
  print(ggplot(temp, aes(x=test, y=d)) + geom_bar(stat="identity") + geom_errorbar(aes_string(ymin="ci.1.", ymax="ci.2.")) + ggtitle(modality) + xlab("Tract") + ylab("Effect size (d)") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
}

enigmadir <- "/Volumes/EDRU/Individual Folders/Caitlin/ENIGMA"
projectdir <- "/Volumes/EDRU/Individual Folders/Caitlin/ENIGMA/NYSPI"
statsdir <- paste0(projectdir,"/stats/")
results <- paste0(projectdir,"/results/")

#Set modality (i.e., FA, MD, RD, AD, etc)
setwd(results)
modality <- "FA"
# You can change the model to look at: hint, look at the model types in the info column of your results file
model <- "Patient v Control"
data <- read.csv(paste0("two_group_comparison_ENIGMA_",modality,".csv"))

#eg to view results of FA analyses with the simplest analysis
results_map(data, model, modality)
