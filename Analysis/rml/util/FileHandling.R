RML$Util$FileHandling <- (function () {
    readFile <- function (path) {
      paste(readLines(path, warn = FALSE), collapse = "\n")
    }

    FileHandling <- new.env()
    FileHandling$ReadFile <- readFile
    return(FileHandling)
})()
