r_inSelect = c('Governmental Receipts')
pane = 'Agency.name'
data = as.data.frame(setNames(replicate(length(r_inSelect), 
                                        numeric(length(r_years)),
                                        simplify=F),
                              r_inSelect))

for(i in 1:length(r_inSelect)) {
  data[i] = colSums(receipts[(receipts[ ,pane] == r_inSelect[i]), r_years])
}
data = cbind(Years = names(receipts[r_years]),data)
data2 = melt(data, id.vars = 'Years', variable.name = 'Category')

a <- ggplot(data2, aes(as.numeric(Years),value,color=Category)) + 
  xlab('Years') + ylab('USD in 1000s') +
  geom_point() +
  theme_bw() +
  scale_x_discrete(
    breaks = seq(1,length(r_years),5), 
    labels = names(receipts[r_years[seq(1,length(r_years),5)]])) +
  theme(axis.line = element_line(colour = 'black')) +
  theme(text=element_text(family='Arial Black', size = 16)) +
  theme(title=element_text(size = 20))
    
y = colSums(receipts[(receipts[ ,'Agency.name'] == 'Governmental Receipts'), r_years])
b <- qplot(1:length(y), y,
           xlab = 'Year',
           ylab = 'USD in $1000s',
           colour = I('blue'),
           shape = I(17),
           geom = c('point','line')) +
  theme_bw() +
  scale_x_discrete(
    breaks = seq(1,length(r_years),5), 
    labels = names(receipts[r_years[seq(1,length(y),5)]])
  )