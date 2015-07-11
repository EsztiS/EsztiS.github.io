r_raw <- read.csv('data/receipts.csv', colClasses='character')
r_nums <- as.data.frame(sapply(r_raw[13:72], FUN = function(x) as.numeric(gsub(",", "", x))))
receipts <- cbind(r_raw[1:12], r_nums)

r_years = grep('^X[1-2][0-9][0-9][0-9]',names(receipts))
r_indices = grep('.name$|.Budget$',names(receipts))