r_raw <- read.csv('data/receipts.csv', colClasses='character')
r_nums <- as.data.frame(sapply(r_raw[13:72], FUN = function(x) as.numeric(gsub(",", "", x))))
receipts <- cbind(r_raw[1:12], r_nums)

r_years = grep('^X[1-2][0-9][0-9][0-9]',names(receipts))
r_indices = grep('.name$|.Budget$',names(receipts))

o_raw <- read.csv('data/outlays.csv', colClasses='character')
o_nums <- as.data.frame(sapply(o_raw[13:72], FUN = function(x) as.numeric(gsub(",", "", x))))
outlays <- cbind(o_raw[1:12], o_nums)

o_years = grep('^X[1-2][0-9][0-9][0-9]',names(outlays))
o_indices = grep('.Name$|.Budget$|.split$|ory$',names(outlays))

b_raw <- read.csv('data/budauth.csv', colClasses='character')
b_nums <- as.data.frame(sapply(b_raw[12:57], FUN = function(x) as.numeric(gsub(",", "", x))))
budauth <- cbind(b_raw[1:11], b_nums)

b_years = grep('^X[1-2][0-9][0-9][0-9]',names(budauth))
b_indices = grep('.Name|.Budget|.Title|.Category',names(budauth))