setwd('~/Documents/__NYC_DSA/Dev/EsztiS.github.io/')
library(shiny)
library(googleVis)
library(dplyr)
outlays2 <- outlays[outlays$X1962 > 0,]
accounts <- select(outlays2, BEA.Category, Agency.Name, Bureau.Name, Account.Name, X1962)
bea <- aggregate(list(bea.value=accounts$X1962),
                      list(bea=accounts$BEA.Category),sum)
agency <- aggregate(list(agency.value=accounts$X1962),
                         list(agency=accounts$Agency.Name,
                              bea=accounts$BEA.Category),sum)
bureau <- aggregate(list(bureau.value=accounts$X1962),
                    list(bureau=accounts$Bureau.Name,
                         agency=accounts$Agency.Name,
                         bea=accounts$BEA.Category),sum)
account <- aggregate(list(account.value=accounts$X1962),
                    list(account=accounts$Account.Name,
                         bureau=accounts$Bureau.Name,
                         agency=accounts$Agency.Name,
                         bea=accounts$BEA.Category),sum)

the.money <- data.frame(categoryid=c('TotalBudget',
                                    as.character(bea$bea),
                                    as.character(agency$agency),
                                    as.character(bureau$bureau),
                                    as.character(account$account)),
                       parentid=c(NA,
                                  rep('TotalBudget',length(unique(accounts$BEA.Category))),
                                  as.character(agency$bea),
                                  as.character(bureau$agency),
                                  as.character(account$bureau)),
                       values=c(sum(accounts$X1962),
                                bea$bea.value,
                                agency$agency.value,
                                bureau$bureau.value,
                                account$account.value))

#the.money2=the.money[!duplicated(the.money$category),]
the.money$colors=the.money$values+1
the.money$rows = rownames(the.money)
# try to find a way of testing if a neighboring column is equal, then skip
numbers = rownames(the.money[grep('Citizens',the.money$parentid),])

apply((the.money[grep('Citizens',the.money$parentid),]
       ), 
      1, paste, collapse='')

moneyTree <- gvisTreeMap(the.money, "categoryid", "parentid",
                           "values",'colors')
                            #, options=list(showScale=TRUE,width=1200, height=1000, fontSize=20))
plot(moneyTree) 
the.money[the.money$parentid == 'Governmental Receipts', ]
the.money[the.money$categoryid == 'Governmental Receipts', ]
the.money[the.money$parentid == 'Corporation Income Taxes', ]
the.money[the.money$categoryid == 'Corporation Income Taxes', ]


cat(createGoogleGadget(moneyTree), file="USBudgetTree.xml")
