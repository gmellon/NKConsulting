
library(rjson)
head(master_NEA$TIN)
 
master_NEA$ntee_code<-NA

for (i in which(is.na(master_NEA$ntee_code))){
ein<-master_NEA$TIN[i]
object<-try(fromJSON(paste0("https://projects.propublica.org/nonprofits/api/v2/organizations/", ein, ".json"),
                     method="c"))
if (class(object)=="try-error"){
  master_NEA$ntee_code[i]<-NA
} else {
  master_NEA$ntee_code[i]<-object$organization$ntee_code
}
  print(i)
  if(round(i/1000)==(i/1000)) {
    save(master_NEA, file = "master_bk.rda")
  }
}



