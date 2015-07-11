test = list(c('A','A','A','B','B','C','D','D','D'),
            c('z','y','z','z','y','x','w','y','z'),
            c('m','n','l','m','n','l','m','n','l'))
testm = matrix(unlist(test), nrow = 9, ncol = 3)
df = data.frame(testm)
df

library(dplyr)
df = outlays[o_indices]

end = ncol(df)
colnms = names(df)
df$idx = as.numeric(rownames(df))
newDF = data.frame(df[ ,1])
names(newDF) = colnms[1]
gbx1 = do.call(group_by, list(df, as.name(colnms[1])))
for (col in 2:(end)) {
  col = 2
  e1 = summarise(gbx1, id = min(idx))
  dic = ungroup(e1)
  gbx1 = merge(gbx1, dic, on = gbx1[ ,1])
  newDF[,col] = apply(gbx1[, c(colnms[col],'id')], 1, paste, collapse = '')
}


 
  