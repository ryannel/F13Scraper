import glob
from time import gmtime, strftime

currentDate = strftime("%Y-%m-%d %H:%M:%S", gmtime())
initialComment = """-- ====================================================
-- Baskerville API DB Release
-- {0}
-- ====================================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'GameMonitor') USE GameMonitor;
GO
IF (db_name() <> 'GameMonitor') RAISERROR('Error, ''USE GameMonitor'' failed!  Killing the SPID now.',22,127) WITH LOG;
SET NOCOUNT ON;

RAISERROR ('Update Started:', 10, 0) WITH NOWAIT;

""".format(currentDate)

runningMessage = """-- =========================
-- File Path: {0}
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: {0}', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

"""

def processGlob(filter, outfile):
    for fname in glob.glob(filter, recursive=True):
        with open(fname, 'r') as readfile:
            print('Writing: {0}'.format(fname))
            outfile.write(runningMessage.format(fname))
            outfile.write(readfile.read() + "\n\n")

fileName = 'install.sql'
open(fileName, 'w').close()
print('Clearing: {0}'.format(fileName))
with open(fileName, 'w') as outfile:
    outfile.write(initialComment)
    processGlob('./DataBase/*.sql', outfile)
    processGlob('./Tables/*.sql', outfile)
    processGlob('./Procedures/*.sql', outfile)
    outfile.write("RAISERROR ('Update Complete. Please check for errors.', 10, 0) WITH NOWAIT;")