###Functions used in the code for Cohens d
d.t.unpaired<-function(t.val,n1,n2){
  d<-t.val*sqrt((n1+n2)/(n1*n2))
  #names(d)<-"effect size d"
  return(d)
}

##For multiple regression
partial.d<-function(t.val,df,n1,n2){
  d<-t.val*(n1+n2)/(sqrt(n1*n2)*sqrt(df))
  #names(d)<-"effect size d"
  return(d)
}

CI1<-function(ES,se){
  ci<-c((ES-(1.96)*se),(ES+(1.96)*se))
  #names(ci)<-c("95% CI lower","95% CI upper")
  return(ci)
}

se.g <-function(d,n1,n2){
  se<-sqrt((n1+n2)/(n1*n2)+(d^2)/(2*(n1+n2-2)))
  #names(se)<-"se for g"
  return(se)
}

se.d <-function(d,n1,n2){
  se<-sqrt((n1+n2-1)/(n1+n2-3))*((1+((d^2)/8))*(4/(n1+n2)))
  #names(se)<-"se for d"
  return(se)
}

helper <- function(x){as.numeric(as.character(x))}
factorit <- function(x){as.factor(x)}