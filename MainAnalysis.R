install.packages("pacman")

pacman::p_load(ppcor, lsmeans, multcomp, vtable, dplyr, summarytools, readxl,sensemakr, emmeans,oro.nifti,readxl,stats,tidyr,voxel)

dir.create("/Volumes/EDRU/Individual Folders/Caitlin/ENIGMA/NYSPI/results", mode = '0777')


##tell R where your ENIGMA folders are
enigmadir <- "ENIGMA_AN_DTI"
projectdir <- "ENIGMA_AN_DTI/nameofyoursite"
statsdir <- paste0(projectdir,"/stats/")
results <- paste0(projectdir,"/results/")

setwd(enigmadir)
source("helpers.R")

files <- c("FA_combined_roi_avg.csv", "AD_combined_roi_avg.csv", "MD_combined_roi_avg.csv", "RD_combined_roi_avg.csv")
loop=0


for(file in files){
  TWO_GROUP <- data.frame()
  THREE_GROUP <- data.frame()
  STATS <- data.frame()

  setwd(statsdir)
  loop = loop + 1
  tbssfile <- file
  Dat <- read.csv(tbssfile, check.names = F); #Read in the phenotypes file
  # 
  # #check to make sure all of the necessary columns are present
  filetype <- gsub("_combined_roi_avg.csv","",file)
  colnames(Dat) <- gsub(filetype,"",colnames(Dat))
  Cols=c("Cases","Weighted_avg","Core_weighted_avg", "ACR","ACR-L","ACR-R","ALIC","ALIC-L","ALIC-R","Average","BCC","CGC","CGC-L","CGC-R","CGH","CGH-L","CGH-R","CP","CP-L","CP-R","CST","CST-L","CST-R","EC","EC-L","EC-R","FX","FX_ST","FX_ST-L","FX_ST-R","GCC","ICP","ICP-L","ICP-R","IFO","IFO-L","IFO-R","ML","ML-L","ML-R","PCR","PCR-L","PCR-R","PLIC","PLIC-L","PLIC-R","PTR","PTR-L","PTR-R","RLIC","RLIC-L","RLIC-R","SCC","SCP","SCP-L","SCP-R","SCR","SCR-L","SCR-R","SFO","SFO-L","SFO-R","SLF","SLF-L","SLF-R","SS","SS-L","SS-R","UNC","UNC-L","UNC-R", "Peri")
  Datcolind=match(Cols,names(Dat))
  if(length(which(is.na(Datcolind))) > 0){
    print(which(is.na(Datcolind)))
    stop('At least one of the required columns in your ',tbssfile,' file is missing. Make sure that the column names are spelled exactly as listed in the protocol.The the index of the missing cols is printed above','\n')
    
  }
  names <- colnames(Dat)
  names <- names[names != "Cases"]
  names <- names[!(names=="Average" | names=="Weighted_avg"| names=="Core_weighted_avg" | names=="Core_weighted_avg" | names=="Peri")]
  
  
  for(name in names){
    colnames(Dat) <- gsub(name, paste0(name,"_",filetype), colnames(Dat)) 
  }
  
  
  setwd(projectdir)
  Covs <- read.csv("Covariates.csv", check.names = F); #Read in the covariates file
  
  # Check for duplicated SubjIDs that may cause issues with merging data sets.
  if(anyDuplicated(Covs[,c("SubjID")]) != 0) { stop('You have duplicate SubjIDs in your Covariates.csv file.\nMake sure there are no repeat SubjIDs.') }
  
  
  mcols=c("SubjID","dx","dx3","age","bmi","bmi_sds","ap","ad","ao","durill","in_out","comorb","deprsymp","hand","parentses","iq","subtype", "site")
  colind=match(mcols,names(Covs))
  if(length(which(is.na(colind))) > 0){
    stop('At least one of the required columns in your Covariates.csv file is missing. Make sure that the column names are spelled exactly as listed:\nIt is possible that the problem column(s) is: ', mcols[which(is.na(colind))])
  }
  
  Covs$age2=Covs$age^2
  
  # factor coding for dx3
  Covs$dx3=factor(Covs$dx3)
  
  n.covs <- ncol(Covs) - 1; #Total number of covariates, -1 removes the SubjectID column
  n.sites <- unique(Covs$site); #Find the number of site variables, subtract the number of predictors (Dx, Age, etc.) from n.covs
  
  #combine the files into one dataframe
  merged_ordered = merge(Covs, Dat, by.x="SubjID", by.y="Cases");

  
  brain <- merged_ordered %>% dplyr::select(ends_with(filetype)) %>% colnames()
if("ad" %in% brain){brain <- brain[!brain=="ad"]}
  setwd(results)
  cont <- c("age","bmi","bmi_sds","ao","durill","deprsymp","iq")
  cat <- c("dx","dx3","ap","ad","in_out","comorb","hand","parentses","subtype","site")
  
  merged_ordered[,c(brain)] <- sapply(merged_ordered[,c(brain)],helper)
  merged_ordered[,c(cont)] <- sapply(merged_ordered[,c(cont)],helper)
  merged_ordered[,c(cat)] <- sapply(merged_ordered[,c(cat)],factorit)
  
  demo_vars <- c("age","bmi","bmi_sds","ao","durill","deprsymp","iq","ap","ad","in_out","comorb","hand","parentses","subtype","site")
  #Check that the number of rows after merging is the same
  if(nrow(Dat) != nrow(merged_ordered)){
    cat(paste0('WARNING: ', tbssfile, ' and Covariates.csv have non-matching SubjIDs.','\n'))
    cat('Please make sure the number of subjects in your merged data set are as expected.','\n')
    cat(paste0('The number of SubjIDs in ', tbssfile, ' is: ',nrow(Dat),'\n'))
    cat('The number of SubjIDs in the merged_ordered data set is: ',nrow(merged_ordered),'\n')
  }
  
  if(loop==1){
    cat('Calculating demographics for 2 groups', tbssfile,'\n')
    
    cont_sum <- merged_ordered %>% dplyr::group_by(dx) %>% st(cont,group="dx", out = 'return')
    cat_sum <- merged_ordered %>% dplyr::group_by(dx) %>% dplyr::select(cat,dx) %>% dfSummary() 
    write.csv(cat_sum[1],"cat_summary_2group_HC.csv")
    write.csv(cat_sum[2],"cat_summary_2group_AN.csv")
    write.csv(cont_sum,"cont_summary_2group.csv")
    
    cat('Calculating demographics using 3 groups for ', tbssfile,'\n')
    
    cont_sum <- merged_ordered %>% dplyr::group_by(dx3) %>% st(cont, group="dx3", out = 'return')
    cat_sum <- merged_ordered %>% dplyr::group_by(dx3) %>% dplyr::select(cat,dx) %>% dfSummary()
    write.csv(cat_sum[1],"cat_summary_3group_HC.csv")
    write.csv(cat_sum[2],"cat_summary_3group_pAN.csv")
    write.csv(cat_sum[3],"cat_summary_3group_AN.csv")
    
    write.csv(cont_sum,"cont_summary_3group.csv")
  }


cat('Calculating brain summaries for 2 groups', tbssfile,'\n')
brain_sum <- merged_ordered %>% dplyr::group_by(dx) %>% st(brain, group="dx",out='csv',file=paste0(tbssfile,"_brain_summary_2group.csv"))

cat('Calculating brain summaries for 3 groups for ', tbssfile,'\n')
brain_sum <- merged_ordered %>% dplyr::group_by(dx3) %>% st(brain, group="dx3",out='csv',file=paste0(tbssfile,"_brain_summary_3group.csv"))




setwd(enigmadir)
models <- read_xlsx("Models_betweengroup.xlsx")

testvars <- merged_ordered %>% dplyr::select(ends_with(filetype)) %>% colnames()
if("ad" %in% testvars){testvars <- testvars[!testvars=="ad"]}

merged_ordered$dx3 <- as.factor(merged_ordered$dx3)

##start with two-group
for(i in 1:nrow(models)){  
  if(i > 1){testvars <- testvars[!(testvars=="Average" | testvars=="Weighted_avg"| testvars=="Core_weighted_avg" | testvars=="Core_weighted_avg" | testvars=="Peri")]}
  formula <- models[i,]$Formula
  info <- models[i,]$Info
  if(length(unique(merged_ordered$site<2))){formula <- gsub(" + site","",formula, fixed = T)}
  formula2dx <- formula
  for(test in testvars){
    merged_ordered$test <- merged_ordered[[test]]  
    mod <-lm(formula = formula2dx, data=merged_ordered)
    n <- data.frame(model.matrix(mod))
    n1 <- nrow(subset(n, n$dx1==1))
    n2 <- nrow(subset(n, n$dx1==0))
    stat <- data.frame(summary(mod)$coefficients)
    t <- stat$t.value[rownames(stat)=="dx1"]
    df_error <- mod$df.residual
    if(formula == "test ~ dx"){
      d <- d.t.unpaired(t,n1,n2)
    }else{
      d <- partial.d(t,df_error,n1,n2)}
    seg <- se.g(d,n1,n2)  
    #sed <- se.d(d,n1,n2) 
    ci <- CI1(d, seg)
    row <- data.frame(test, info,n1,n2,t,d,ci[1],ci[2], seg, df_error)
    TWO_GROUP <- rbind(TWO_GROUP,row)
    ###This analysis is only done if there are three groups
    if(length(unique(merged_ordered$dx3))>2){
      formula <- models[i,]$Formula
      formula <- gsub("dx", "dx3", formula)
      if(length(unique(merged_ordered$site))<2){formula <- gsub(" + site","",formula, fixed = T)}
      mod <-lm(formula = formula, data=merged_ordered)
      n <- data.frame(model.matrix(mod))
      n_an <- nrow(subset(n, n$dx332==1))
      n_pan <- nrow(subset(n, n$dx331==1))
      n_hc <- nrow(subset(n, n$dx331==0 & n$dx332==0))
      stat <- data.frame(summary(mod)$coefficients)
      tmp=summary(glht(mod, mcp(dx3="Tukey")))
      t_hc_pan=tmp$test$tstat[1] 
      tstat.df=tmp$df
      d_hc_pan <- partial.d(t_hc_pan,tstat.df,n_pan,n_hc)
      seg_hc_pan <- se.g(d_hc_pan,n_pan,n_hc)
      ci_hc_pan <- CI1(d_hc_pan, seg_hc_pan)
      
      t_hc_an=tmp$test$tstat[2] 
      tstat.df=tmp$df
      d_hc_an <- partial.d(t_hc_an,tstat.df,n_an,n_hc)
      seg_hc_an <- se.g(d_hc_an,n_an,n_hc)
      ci_hc_an <- CI1(d_hc_an, seg_hc_an)
      
      t_pan_an=tmp$test$tstat[3] 
      tstat.df=tmp$df
      d_pan_an <- partial.d(t_pan_an,tstat.df,n_an,n_pan)
      seg_pan_an <- se.g(d_pan_an,n_an,n_pan)
      ci_pan_an <- CI1(d_pan_an, seg_pan_an)
      #sed <- se.d(d,n1,n2) 
      
      row <- data.frame(test, info,n_an,n_pan,n_hc,t_hc_pan,d_hc_pan,seg_hc_pan,ci_hc_pan[1],ci_hc_pan[2],t_hc_an,d_hc_an,seg_hc_an,ci_hc_an[1],ci_hc_an[2],t_pan_an,d_pan_an,seg_pan_an,ci_pan_an[1],ci_pan_an[2],tstat.df)
      THREE_GROUP <- rbind(THREE_GROUP,row)}
}
}

## Predictors of brain outcomes per group
setwd(enigmadir)
models <- read_xlsx("Models_withingroup.xlsx")


AN <- subset(merged_ordered, merged_ordered$dx==1)
HC <- subset(merged_ordered, merged_ordered$dx==0)
AN_acute <- subset(merged_ordered, merged_ordered$dx3==32)
AN_partial <- subset(merged_ordered, merged_ordered$dx3==31)

## preds can be changed to add in other variables, using string format
preds <- c("+ age + age2", "+ age + age2 +bmi", "+ age + age2")


framename <- c("AN","HC", "AN_acute", "AN_partial")
i <- 0
for(frame in list(AN,HC, AN_acute, AN_partial)){
  i <- i+1
  name <- framename[i]
  for(test in testvars){
    for(j in 1:nrow(models)){  
      for(pred in preds){
        frame$test <- frame[[test]]
        formula <- paste0(models[j,]$Formula,pred)
        info <- paste0(models[j,]$Info," adj for ",pred)
        if(length(unique(frame$site<2))){formula <- gsub("site+","",formula, fixed = T)}
        mod <-lm(formula = formula, data=frame)
        n <- data.frame(model.matrix(mod))
        n1 <- nrow(n)
        stat <- data.frame(summary(mod)$coefficients)
        stat <- stat[-1,]
        r2 <- data.frame(partial_r2(mod))[-1,]
        stat$r2 <- c(r2)
        stat$lci <- stat$Estimate - 1.96*stat$Std..Error
        stat$uci <- stat$Estimate + 1.96*stat$Std..Error
        stat$n <- stat$n1
        stat$outcome <- test
        stat$model <- info
        stat$sample <- name
        STATS <- rbind(STATS, stat)
      }}
}}
setwd(results)
write.csv(TWO_GROUP,paste0(projectdir,"/two_group_comparison_ENIGMA_",filetype,".csv"))
write.csv(THREE_GROUP,paste0(projectdir,"/three_group_comparison_ENIGMA_",filetype,".csv"))
write.csv(STATS,paste0("correlations_ENIGMA_",filetype,".csv"))
}


##Now voxel wise - change the path to where your images are.
##If the readnii function does not work you can substitute to readNifti

path <- projectdir
mask <- paste0(enigmadir,"/ENIGMA_DTI_FA_skeleton_mask.nii.gz")
mask = readnii(mask)

#sort the merged_ordered file to make sure all is in order

merged_ordered <- merged_ordered %>% arrange("SubjId")
setwd(statsdir)
# Run the voxel model
skeletons <- c("all_FA_skeletonized.nii.gz", "all_MD_skeletonized.nii.gz", "all_AD_skeletonized.nii.gz", "all_RD_skeletonized.nii.gz")
for(skeleton in skeletons){
param <- sub(".*_([^_]+)_.*", "\\1", skeleton)
dir.create(paste0(results,"/TBSS",param), mode = '0777')
voxelstats <- lmNIfTI(image=skeleton,mask=mask,form=' ~ dx + age + age2',subjData=merged_ordered, outDir=paste0(results,"/TBSS",param))
}
