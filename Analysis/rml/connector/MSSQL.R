RML$Connector$MSSQL <- (function () {
    Connect <- function(server, databaseName, userName, password) {
        connectionString <- paste('driver={SQL Server};server=', server, ';database=', databaseName, ';UID=', userName, ';PWD=', password, sep='')
        return(GetConnection(connectionString))
    }

    ConnectMsAuth <- function(server, databaseName) {
        connectionString <- paste('driver={SQL Server};server=', server, ';database=', databaseName, ';trusted_connection=true', sep='')
        return(GetConnection(connectionString))
    }

    GetConnection <- function(connectionString) {
        library(RODBC)
        connection <- odbcDriverConnect(connectionString)

        connectionEnv <- GetConnectionEnv(connection)
        return(connectionEnv)
    }
    
    GetConnectionEnv <- function(connection) {
        library(digest)

        Execute <- function (connection) {
            return (function (query, cache) {
                if (missing(cache)) cache = FALSE
                result <- ExecuteQuery(connection, query, cache)
                return(result)
            })
        }
      
        ExecuteFile <- function (connection) {
            return (function (filePath, cache) {
                query <- readChar(filePath, file.info(filePath)$size)
                if (missing(cache)) cache = FALSE
                result <- ExecuteQuery(connection, query, cache)
                return(result)
            })
        }
      
        Close <- function (connection) {
            return (function () {
                odbcClose(connection)
            })
        }

        ExecuteQuery <- function (connection, query, cache) {
            if (cache == FALSE || missing(cache)) {
                return(sqlQuery(connection, query))
            }

            dir.create('cache', showWarnings = FALSE)

            hash <- digest(query, algo='md5')
            filePath <- paste('cache/', hash, '.rds', sep='')

            if (file.exists(filePath)) {
                result <- readRDS(filePath)
            } else {
                result <- sqlQuery(connection, query)
                saveRDS(result, filePath)
            }

            return(result)
        }
      
        result <- new.env()
        result$Execute <- Execute(connection)
        result$ExecuteFile <- ExecuteFile(connection)
        result$Close <- Close(connection)
        return(result)
    }
    
    MSSQL <- new.env()
    MSSQL$Connect <- Connect
    MSSQL$ConnectMsAuth <- ConnectMsAuth
    return(MSSQL)
})()