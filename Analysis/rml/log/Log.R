RML$Log <- (function () {
    writeToFile <- function (level, message) {
        time <- format(Sys.time(), '%Y-%m-%d %H:%M:%S')
        message <- paste(time, level, message, sep=' - ')
        write(message, file='execution.log', append=TRUE)
    }

    Debug <- function (message) {
        writeToFile('Debug', message)
    }

    Log <- function (message) {
        writeToFile('Log', message)
    }

    Info <- function (message) {
        writeToFile('Info', message)
    }

    Warn <- function (message) {
        writeToFile('Warn', message)
    }

    Error <- function (message) {
        writeToFile('Error', message)
    }

    Logging <- new.env()
    Logging$Debug <- Debug
    Logging$Log <- Log
    Logging$Info <- Info
    Logging$Warn <- Warn
    Logging$Error <- Error
    return(Logging)
})()

