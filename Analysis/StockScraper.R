source('rml/Rml.R', chdir = TRUE)

connection <- RML$Connector$MSSQL$ConnectMsAuth('FPRYANNEL1', 'StockScraper')

dataset <- connection$ExecuteFile('../DB/Scripts/GetPortfolio.sql')


test <- function(test) {
    
}

test()
