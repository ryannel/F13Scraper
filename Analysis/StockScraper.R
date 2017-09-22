library(ggplot2)
library(dplyr)

source('rml/Rml.R', chdir = TRUE)

connection <- RML$Connector$MSSQL$ConnectMsAuth('FPRYANNEL1', 'StockScraper')

dataset <- connection$ExecuteFile('../DB/Scripts/GetPortfolio.sql')

dataset <- arrange(dataset, desc(ValueUSD))
dataset <- dataset[1:50,]

theme <- theme(panel.background = element_rect(fill = '#ffffff'), 
               panel.grid.major = element_line(color = '#f1f1f1'), 
               panel.grid.minor = element_line(color = '#f7f7f7'), 
               plot.title = element_text(hjust = 0.5, size=18, color='#464646'),
               axis.title = element_text(size=12, color='#464646'))

ggplot(data = dataset) +
    theme + 
    geom_bar(stat = "identity", fill = "#3498db") + 
    theme(axis.text.x=element_text(angle=90,hjust=1, vjust=0.5)) +
    aes(x = reorder(Security, -ValueUSD, sum), y=ValueUSD) +
    labs(x = "Securities", y = "Values", title = "Top 50 Securities")

