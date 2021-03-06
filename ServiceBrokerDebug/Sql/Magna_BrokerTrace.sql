/****************************************************/
/* Created by: SolidQ Denmark 
               Torben Schou
   
   Description: 
     Run Server side trace, targeted events releated to SQL Broker.
	   The size of each tracec files are max 250 MB
	   Should the trace contain more data the trace will add extra trace files automatic
     Max numbers of files are set to 200 (@fileCount)

     Runtime for trace are set to 15 minutes (@TraceTime).


   NB: 
     Please replace the text <Trace files folder> (@fileName), with an appropriate
	   filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
	   will be appended to the filename automatically. If you are writing from
	   remote server to local drive, please use UNC path and make sure server has
	   write access to your network share
        */
/****************************************************/


-- Create a Queue
DECLARE @TraceID int, @TraceTime INT
DECLARE @rc INT
DECLARE @maxfilesize BIGINT, @fileName NVARCHAR(128), @fileCount INT
DECLARE @stoptime DATETIME

-- Set Parameters
SET @maxfilesize = 250
SET @fileName = '$(FileName)'
SET @fileName = CAST(@FileName AS NVARCHAR(MAX))
SET @fileCount = 200
SET @TraceTime = '$(TraceTime)'
SET @TraceTime = CAST(@TraceTime AS INT)
SET @stoptime = DATEADD(mi, @TraceTime, GETDATE())

exec @rc = sp_trace_create @TraceID output, 6 -- enable tracefile failover (2) and SHUTDOWN_ON_ERROR (4)
  , @fileName, @maxfilesize, @stoptime, @fileCount

if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 163, 1, @on -- Broker:Activation
exec sp_trace_setevent @TraceID, 163, 9, @on
exec sp_trace_setevent @TraceID, 163, 3, @on
exec sp_trace_setevent @TraceID, 163, 4, @on
exec sp_trace_setevent @TraceID, 163, 12, @on
exec sp_trace_setevent @TraceID, 163, 6, @on
exec sp_trace_setevent @TraceID, 163, 7, @on
exec sp_trace_setevent @TraceID, 163, 8, @on
exec sp_trace_setevent @TraceID, 163, 10, @on
exec sp_trace_setevent @TraceID, 163, 13, @on
exec sp_trace_setevent @TraceID, 163, 14, @on
exec sp_trace_setevent @TraceID, 163, 15, @on
exec sp_trace_setevent @TraceID, 163, 16, @on
exec sp_trace_setevent @TraceID, 163, 17, @on
exec sp_trace_setevent @TraceID, 163, 18, @on
exec sp_trace_setevent @TraceID, 163, 21, @on
exec sp_trace_setevent @TraceID, 163, 22, @on
exec sp_trace_setevent @TraceID, 163, 25, @on
exec sp_trace_setevent @TraceID, 163, 26, @on
exec sp_trace_setevent @TraceID, 163, 41, @on
exec sp_trace_setevent @TraceID, 163, 51, @on
exec sp_trace_setevent @TraceID, 163, 60, @on
exec sp_trace_setevent @TraceID, 163, 64, @on
exec sp_trace_setevent @TraceID, 138, 1, @on -- Broker:Connection
exec sp_trace_setevent @TraceID, 138, 9, @on
exec sp_trace_setevent @TraceID, 138, 3, @on
exec sp_trace_setevent @TraceID, 138, 4, @on
exec sp_trace_setevent @TraceID, 138, 12, @on
exec sp_trace_setevent @TraceID, 138, 6, @on
exec sp_trace_setevent @TraceID, 138, 7, @on
exec sp_trace_setevent @TraceID, 138, 8, @on
exec sp_trace_setevent @TraceID, 138, 10, @on
exec sp_trace_setevent @TraceID, 138, 14, @on
exec sp_trace_setevent @TraceID, 138, 21, @on
exec sp_trace_setevent @TraceID, 138, 26, @on
exec sp_trace_setevent @TraceID, 138, 31, @on
exec sp_trace_setevent @TraceID, 138, 34, @on
exec sp_trace_setevent @TraceID, 138, 41, @on
exec sp_trace_setevent @TraceID, 138, 51, @on
exec sp_trace_setevent @TraceID, 138, 54, @on
exec sp_trace_setevent @TraceID, 138, 60, @on
exec sp_trace_setevent @TraceID, 138, 64, @on
exec sp_trace_setevent @TraceID, 124, 1, @on -- Broker:Conversation
exec sp_trace_setevent @TraceID, 124, 9, @on
exec sp_trace_setevent @TraceID, 124, 3, @on
exec sp_trace_setevent @TraceID, 124, 4, @on
exec sp_trace_setevent @TraceID, 124, 5, @on
exec sp_trace_setevent @TraceID, 124, 6, @on
exec sp_trace_setevent @TraceID, 124, 7, @on
exec sp_trace_setevent @TraceID, 124, 8, @on
exec sp_trace_setevent @TraceID, 124, 10, @on
exec sp_trace_setevent @TraceID, 124, 12, @on
exec sp_trace_setevent @TraceID, 124, 14, @on
exec sp_trace_setevent @TraceID, 124, 21, @on
exec sp_trace_setevent @TraceID, 124, 26, @on
exec sp_trace_setevent @TraceID, 124, 34, @on
exec sp_trace_setevent @TraceID, 124, 36, @on
exec sp_trace_setevent @TraceID, 124, 37, @on
exec sp_trace_setevent @TraceID, 124, 38, @on
exec sp_trace_setevent @TraceID, 124, 39, @on
exec sp_trace_setevent @TraceID, 124, 40, @on
exec sp_trace_setevent @TraceID, 124, 41, @on
exec sp_trace_setevent @TraceID, 124, 42, @on
exec sp_trace_setevent @TraceID, 124, 46, @on
exec sp_trace_setevent @TraceID, 124, 47, @on
exec sp_trace_setevent @TraceID, 124, 51, @on
exec sp_trace_setevent @TraceID, 124, 54, @on
exec sp_trace_setevent @TraceID, 124, 60, @on
exec sp_trace_setevent @TraceID, 124, 64, @on
exec sp_trace_setevent @TraceID, 136, 3, @on  -- Broker:Conversation Group
exec sp_trace_setevent @TraceID, 136, 4, @on
exec sp_trace_setevent @TraceID, 136, 12, @on
exec sp_trace_setevent @TraceID, 136, 6, @on
exec sp_trace_setevent @TraceID, 136, 14, @on
exec sp_trace_setevent @TraceID, 136, 7, @on
exec sp_trace_setevent @TraceID, 136, 8, @on
exec sp_trace_setevent @TraceID, 136, 9, @on
exec sp_trace_setevent @TraceID, 136, 10, @on
exec sp_trace_setevent @TraceID, 136, 21, @on
exec sp_trace_setevent @TraceID, 136, 26, @on
exec sp_trace_setevent @TraceID, 136, 41, @on
exec sp_trace_setevent @TraceID, 136, 51, @on
exec sp_trace_setevent @TraceID, 136, 54, @on
exec sp_trace_setevent @TraceID, 136, 60, @on
exec sp_trace_setevent @TraceID, 136, 64, @on
exec sp_trace_setevent @TraceID, 161, 1, @on -- Broker:Corrupted Message
exec sp_trace_setevent @TraceID, 161, 9, @on
exec sp_trace_setevent @TraceID, 161, 3, @on
exec sp_trace_setevent @TraceID, 161, 4, @on
exec sp_trace_setevent @TraceID, 161, 12, @on
exec sp_trace_setevent @TraceID, 161, 6, @on
exec sp_trace_setevent @TraceID, 161, 7, @on
exec sp_trace_setevent @TraceID, 161, 8, @on
exec sp_trace_setevent @TraceID, 161, 10, @on
exec sp_trace_setevent @TraceID, 161, 14, @on
exec sp_trace_setevent @TraceID, 161, 20, @on
exec sp_trace_setevent @TraceID, 161, 26, @on
exec sp_trace_setevent @TraceID, 161, 30, @on
exec sp_trace_setevent @TraceID, 161, 31, @on
exec sp_trace_setevent @TraceID, 161, 41, @on
exec sp_trace_setevent @TraceID, 161, 51, @on
exec sp_trace_setevent @TraceID, 161, 60, @on
exec sp_trace_setevent @TraceID, 161, 64, @on
exec sp_trace_setevent @TraceID, 140, 1, @on -- Broker:Forwarded Message Dropped
exec sp_trace_setevent @TraceID, 140, 9, @on
exec sp_trace_setevent @TraceID, 140, 3, @on
exec sp_trace_setevent @TraceID, 140, 4, @on
exec sp_trace_setevent @TraceID, 140, 12, @on
exec sp_trace_setevent @TraceID, 140, 6, @on
exec sp_trace_setevent @TraceID, 140, 7, @on
exec sp_trace_setevent @TraceID, 140, 8, @on
exec sp_trace_setevent @TraceID, 140, 10, @on
exec sp_trace_setevent @TraceID, 140, 14, @on
exec sp_trace_setevent @TraceID, 140, 20, @on
exec sp_trace_setevent @TraceID, 140, 22, @on
exec sp_trace_setevent @TraceID, 140, 23, @on
exec sp_trace_setevent @TraceID, 140, 24, @on
exec sp_trace_setevent @TraceID, 140, 25, @on
exec sp_trace_setevent @TraceID, 140, 26, @on
exec sp_trace_setevent @TraceID, 140, 30, @on
exec sp_trace_setevent @TraceID, 140, 31, @on
exec sp_trace_setevent @TraceID, 140, 36, @on
exec sp_trace_setevent @TraceID, 140, 37, @on
exec sp_trace_setevent @TraceID, 140, 38, @on
exec sp_trace_setevent @TraceID, 140, 39, @on
exec sp_trace_setevent @TraceID, 140, 40, @on
exec sp_trace_setevent @TraceID, 140, 41, @on
exec sp_trace_setevent @TraceID, 140, 42, @on
exec sp_trace_setevent @TraceID, 140, 46, @on
exec sp_trace_setevent @TraceID, 140, 47, @on
exec sp_trace_setevent @TraceID, 140, 51, @on
exec sp_trace_setevent @TraceID, 140, 52, @on
exec sp_trace_setevent @TraceID, 140, 54, @on
exec sp_trace_setevent @TraceID, 140, 64, @on
exec sp_trace_setevent @TraceID, 139, 3, @on -- Broker:Forwarded Message Sent
exec sp_trace_setevent @TraceID, 139, 4, @on
exec sp_trace_setevent @TraceID, 139, 12, @on
exec sp_trace_setevent @TraceID, 139, 6, @on
exec sp_trace_setevent @TraceID, 139, 14, @on
exec sp_trace_setevent @TraceID, 139, 7, @on
exec sp_trace_setevent @TraceID, 139, 8, @on
exec sp_trace_setevent @TraceID, 139, 9, @on
exec sp_trace_setevent @TraceID, 139, 10, @on
exec sp_trace_setevent @TraceID, 139, 22, @on
exec sp_trace_setevent @TraceID, 139, 23, @on
exec sp_trace_setevent @TraceID, 139, 24, @on
exec sp_trace_setevent @TraceID, 139, 25, @on
exec sp_trace_setevent @TraceID, 139, 26, @on
exec sp_trace_setevent @TraceID, 139, 36, @on
exec sp_trace_setevent @TraceID, 139, 37, @on
exec sp_trace_setevent @TraceID, 139, 38, @on
exec sp_trace_setevent @TraceID, 139, 39, @on
exec sp_trace_setevent @TraceID, 139, 40, @on
exec sp_trace_setevent @TraceID, 139, 41, @on
exec sp_trace_setevent @TraceID, 139, 42, @on
exec sp_trace_setevent @TraceID, 139, 46, @on
exec sp_trace_setevent @TraceID, 139, 47, @on
exec sp_trace_setevent @TraceID, 139, 51, @on
exec sp_trace_setevent @TraceID, 139, 52, @on
exec sp_trace_setevent @TraceID, 139, 54, @on
exec sp_trace_setevent @TraceID, 139, 64, @on
exec sp_trace_setevent @TraceID, 141, 1, @on -- Broker:Message Classify
exec sp_trace_setevent @TraceID, 141, 9, @on
exec sp_trace_setevent @TraceID, 141, 3, @on
exec sp_trace_setevent @TraceID, 141, 4, @on
exec sp_trace_setevent @TraceID, 141, 12, @on
exec sp_trace_setevent @TraceID, 141, 6, @on
exec sp_trace_setevent @TraceID, 141, 7, @on
exec sp_trace_setevent @TraceID, 141, 8, @on
exec sp_trace_setevent @TraceID, 141, 10, @on
exec sp_trace_setevent @TraceID, 141, 14, @on
exec sp_trace_setevent @TraceID, 141, 21, @on
exec sp_trace_setevent @TraceID, 141, 26, @on
exec sp_trace_setevent @TraceID, 141, 31, @on
exec sp_trace_setevent @TraceID, 141, 36, @on
exec sp_trace_setevent @TraceID, 141, 37, @on
exec sp_trace_setevent @TraceID, 141, 38, @on
exec sp_trace_setevent @TraceID, 141, 41, @on
exec sp_trace_setevent @TraceID, 141, 45, @on
exec sp_trace_setevent @TraceID, 141, 47, @on
exec sp_trace_setevent @TraceID, 141, 51, @on
exec sp_trace_setevent @TraceID, 141, 54, @on
exec sp_trace_setevent @TraceID, 141, 59, @on
exec sp_trace_setevent @TraceID, 141, 60, @on
exec sp_trace_setevent @TraceID, 141, 64, @on
exec sp_trace_setevent @TraceID, 160, 1, @on -- Broker:Message Undeliverable
exec sp_trace_setevent @TraceID, 160, 9, @on
exec sp_trace_setevent @TraceID, 160, 3, @on
exec sp_trace_setevent @TraceID, 160, 11, @on
exec sp_trace_setevent @TraceID, 160, 4, @on
exec sp_trace_setevent @TraceID, 160, 6, @on
exec sp_trace_setevent @TraceID, 160, 7, @on
exec sp_trace_setevent @TraceID, 160, 8, @on
exec sp_trace_setevent @TraceID, 160, 10, @on
exec sp_trace_setevent @TraceID, 160, 12, @on
exec sp_trace_setevent @TraceID, 160, 14, @on
exec sp_trace_setevent @TraceID, 160, 20, @on
exec sp_trace_setevent @TraceID, 160, 21, @on
exec sp_trace_setevent @TraceID, 160, 25, @on
exec sp_trace_setevent @TraceID, 160, 26, @on
exec sp_trace_setevent @TraceID, 160, 30, @on
exec sp_trace_setevent @TraceID, 160, 31, @on
exec sp_trace_setevent @TraceID, 160, 36, @on
exec sp_trace_setevent @TraceID, 160, 37, @on
exec sp_trace_setevent @TraceID, 160, 38, @on
exec sp_trace_setevent @TraceID, 160, 39, @on
exec sp_trace_setevent @TraceID, 160, 40, @on
exec sp_trace_setevent @TraceID, 160, 41, @on
exec sp_trace_setevent @TraceID, 160, 42, @on
exec sp_trace_setevent @TraceID, 160, 46, @on
exec sp_trace_setevent @TraceID, 160, 51, @on
exec sp_trace_setevent @TraceID, 160, 52, @on
exec sp_trace_setevent @TraceID, 160, 53, @on
exec sp_trace_setevent @TraceID, 160, 54, @on
exec sp_trace_setevent @TraceID, 160, 55, @on
exec sp_trace_setevent @TraceID, 160, 60, @on
exec sp_trace_setevent @TraceID, 160, 64, @on
exec sp_trace_setevent @TraceID, 144, 1, @on -- Broker:Mirrored Route State Changed
exec sp_trace_setevent @TraceID, 144, 9, @on
exec sp_trace_setevent @TraceID, 144, 3, @on
exec sp_trace_setevent @TraceID, 144, 11, @on
exec sp_trace_setevent @TraceID, 144, 6, @on
exec sp_trace_setevent @TraceID, 144, 7, @on
exec sp_trace_setevent @TraceID, 144, 8, @on
exec sp_trace_setevent @TraceID, 144, 10, @on
exec sp_trace_setevent @TraceID, 144, 12, @on
exec sp_trace_setevent @TraceID, 144, 14, @on
exec sp_trace_setevent @TraceID, 144, 21, @on
exec sp_trace_setevent @TraceID, 144, 26, @on
exec sp_trace_setevent @TraceID, 144, 34, @on
exec sp_trace_setevent @TraceID, 144, 35, @on
exec sp_trace_setevent @TraceID, 144, 37, @on
exec sp_trace_setevent @TraceID, 144, 39, @on
exec sp_trace_setevent @TraceID, 144, 42, @on
exec sp_trace_setevent @TraceID, 144, 47, @on
exec sp_trace_setevent @TraceID, 144, 51, @on
exec sp_trace_setevent @TraceID, 144, 60, @on
exec sp_trace_setevent @TraceID, 144, 64, @on
exec sp_trace_setevent @TraceID, 143, 3, @on -- Broker:Queue Disabled
exec sp_trace_setevent @TraceID, 143, 4, @on
exec sp_trace_setevent @TraceID, 143, 12, @on
exec sp_trace_setevent @TraceID, 143, 6, @on
exec sp_trace_setevent @TraceID, 143, 14, @on
exec sp_trace_setevent @TraceID, 143, 7, @on
exec sp_trace_setevent @TraceID, 143, 8, @on
exec sp_trace_setevent @TraceID, 143, 9, @on
exec sp_trace_setevent @TraceID, 143, 10, @on
exec sp_trace_setevent @TraceID, 143, 22, @on
exec sp_trace_setevent @TraceID, 143, 26, @on
exec sp_trace_setevent @TraceID, 143, 41, @on
exec sp_trace_setevent @TraceID, 143, 51, @on
exec sp_trace_setevent @TraceID, 143, 60, @on
exec sp_trace_setevent @TraceID, 143, 64, @on
exec sp_trace_setevent @TraceID, 149, 3, @on -- Broker:Remote Message Acknowledgement
exec sp_trace_setevent @TraceID, 149, 4, @on
exec sp_trace_setevent @TraceID, 149, 12, @on
exec sp_trace_setevent @TraceID, 149, 5, @on
exec sp_trace_setevent @TraceID, 149, 6, @on
exec sp_trace_setevent @TraceID, 149, 7, @on
exec sp_trace_setevent @TraceID, 149, 8, @on
exec sp_trace_setevent @TraceID, 149, 9, @on
exec sp_trace_setevent @TraceID, 149, 10, @on
exec sp_trace_setevent @TraceID, 149, 14, @on
exec sp_trace_setevent @TraceID, 149, 21, @on
exec sp_trace_setevent @TraceID, 149, 25, @on
exec sp_trace_setevent @TraceID, 149, 26, @on
exec sp_trace_setevent @TraceID, 149, 32, @on
exec sp_trace_setevent @TraceID, 149, 38, @on
exec sp_trace_setevent @TraceID, 149, 41, @on
exec sp_trace_setevent @TraceID, 149, 51, @on
exec sp_trace_setevent @TraceID, 149, 52, @on
exec sp_trace_setevent @TraceID, 149, 53, @on
exec sp_trace_setevent @TraceID, 149, 54, @on
exec sp_trace_setevent @TraceID, 149, 55, @on
exec sp_trace_setevent @TraceID, 149, 60, @on
exec sp_trace_setevent @TraceID, 149, 64, @on
exec sp_trace_setevent @TraceID, 142, 3, @on -- Broker:Transmission
exec sp_trace_setevent @TraceID, 142, 4, @on
exec sp_trace_setevent @TraceID, 142, 12, @on
exec sp_trace_setevent @TraceID, 142, 6, @on
exec sp_trace_setevent @TraceID, 142, 14, @on
exec sp_trace_setevent @TraceID, 142, 7, @on
exec sp_trace_setevent @TraceID, 142, 8, @on
exec sp_trace_setevent @TraceID, 142, 9, @on
exec sp_trace_setevent @TraceID, 142, 10, @on
exec sp_trace_setevent @TraceID, 142, 20, @on
exec sp_trace_setevent @TraceID, 142, 21, @on
exec sp_trace_setevent @TraceID, 142, 26, @on
exec sp_trace_setevent @TraceID, 142, 30, @on
exec sp_trace_setevent @TraceID, 142, 31, @on
exec sp_trace_setevent @TraceID, 142, 38, @on
exec sp_trace_setevent @TraceID, 142, 41, @on
exec sp_trace_setevent @TraceID, 142, 51, @on
exec sp_trace_setevent @TraceID, 142, 54, @on
exec sp_trace_setevent @TraceID, 142, 60, @on
exec sp_trace_setevent @TraceID, 142, 64, @on
exec sp_trace_setevent @TraceID, 165, 1, @on -- Performance statistics
exec sp_trace_setevent @TraceID, 165, 65, @on
exec sp_trace_setevent @TraceID, 165, 2, @on
exec sp_trace_setevent @TraceID, 165, 66, @on
exec sp_trace_setevent @TraceID, 165, 18, @on
exec sp_trace_setevent @TraceID, 165, 3, @on
exec sp_trace_setevent @TraceID, 165, 12, @on
exec sp_trace_setevent @TraceID, 165, 13, @on
exec sp_trace_setevent @TraceID, 165, 21, @on
exec sp_trace_setevent @TraceID, 165, 14, @on
exec sp_trace_setevent @TraceID, 165, 22, @on
exec sp_trace_setevent @TraceID, 165, 25, @on
exec sp_trace_setevent @TraceID, 165, 28, @on
exec sp_trace_setevent @TraceID, 165, 51, @on
exec sp_trace_setevent @TraceID, 165, 52, @on
exec sp_trace_setevent @TraceID, 165, 53, @on
exec sp_trace_setevent @TraceID, 165, 55, @on
exec sp_trace_setevent @TraceID, 165, 61, @on
exec sp_trace_setevent @TraceID, 165, 63, @on
exec sp_trace_setevent @TraceID, 165, 64, @on
exec sp_trace_setevent @TraceID, 97, 2, @on -- Showplan All
exec sp_trace_setevent @TraceID, 97, 66, @on
exec sp_trace_setevent @TraceID, 97, 10, @on
exec sp_trace_setevent @TraceID, 97, 3, @on
exec sp_trace_setevent @TraceID, 97, 11, @on
exec sp_trace_setevent @TraceID, 97, 4, @on
exec sp_trace_setevent @TraceID, 97, 5, @on
exec sp_trace_setevent @TraceID, 97, 7, @on
exec sp_trace_setevent @TraceID, 97, 8, @on
exec sp_trace_setevent @TraceID, 97, 9, @on
exec sp_trace_setevent @TraceID, 97, 12, @on
exec sp_trace_setevent @TraceID, 97, 14, @on
exec sp_trace_setevent @TraceID, 97, 22, @on
exec sp_trace_setevent @TraceID, 97, 25, @on
exec sp_trace_setevent @TraceID, 97, 26, @on
exec sp_trace_setevent @TraceID, 97, 28, @on
exec sp_trace_setevent @TraceID, 97, 29, @on
exec sp_trace_setevent @TraceID, 97, 34, @on
exec sp_trace_setevent @TraceID, 97, 35, @on
exec sp_trace_setevent @TraceID, 97, 41, @on
exec sp_trace_setevent @TraceID, 97, 49, @on
exec sp_trace_setevent @TraceID, 97, 50, @on
exec sp_trace_setevent @TraceID, 97, 51, @on
exec sp_trace_setevent @TraceID, 97, 60, @on
exec sp_trace_setevent @TraceID, 97, 64, @on
exec sp_trace_setevent @TraceID, 158, 1, @on -- Audit Broker Conversation
exec sp_trace_setevent @TraceID, 158, 9, @on
exec sp_trace_setevent @TraceID, 158, 3, @on
exec sp_trace_setevent @TraceID, 158, 4, @on
exec sp_trace_setevent @TraceID, 158, 12, @on
exec sp_trace_setevent @TraceID, 158, 6, @on
exec sp_trace_setevent @TraceID, 158, 7, @on
exec sp_trace_setevent @TraceID, 158, 8, @on
exec sp_trace_setevent @TraceID, 158, 10, @on
exec sp_trace_setevent @TraceID, 158, 14, @on
exec sp_trace_setevent @TraceID, 158, 20, @on
exec sp_trace_setevent @TraceID, 158, 21, @on
exec sp_trace_setevent @TraceID, 158, 22, @on
exec sp_trace_setevent @TraceID, 158, 25, @on
exec sp_trace_setevent @TraceID, 158, 26, @on
exec sp_trace_setevent @TraceID, 158, 30, @on
exec sp_trace_setevent @TraceID, 158, 31, @on
exec sp_trace_setevent @TraceID, 158, 38, @on
exec sp_trace_setevent @TraceID, 158, 40, @on
exec sp_trace_setevent @TraceID, 158, 41, @on
exec sp_trace_setevent @TraceID, 158, 42, @on
exec sp_trace_setevent @TraceID, 158, 51, @on
exec sp_trace_setevent @TraceID, 158, 52, @on
exec sp_trace_setevent @TraceID, 158, 54, @on
exec sp_trace_setevent @TraceID, 158, 60, @on
exec sp_trace_setevent @TraceID, 158, 64, @on
exec sp_trace_setevent @TraceID, 159, 1, @on -- Audit Broker Login
exec sp_trace_setevent @TraceID, 159, 9, @on
exec sp_trace_setevent @TraceID, 159, 3, @on
exec sp_trace_setevent @TraceID, 159, 11, @on
exec sp_trace_setevent @TraceID, 159, 4, @on
exec sp_trace_setevent @TraceID, 159, 6, @on
exec sp_trace_setevent @TraceID, 159, 7, @on
exec sp_trace_setevent @TraceID, 159, 8, @on
exec sp_trace_setevent @TraceID, 159, 10, @on
exec sp_trace_setevent @TraceID, 159, 12, @on
exec sp_trace_setevent @TraceID, 159, 14, @on
exec sp_trace_setevent @TraceID, 159, 21, @on
exec sp_trace_setevent @TraceID, 159, 26, @on
exec sp_trace_setevent @TraceID, 159, 30, @on
exec sp_trace_setevent @TraceID, 159, 34, @on
exec sp_trace_setevent @TraceID, 159, 36, @on
exec sp_trace_setevent @TraceID, 159, 37, @on
exec sp_trace_setevent @TraceID, 159, 38, @on
exec sp_trace_setevent @TraceID, 159, 39, @on
exec sp_trace_setevent @TraceID, 159, 41, @on
exec sp_trace_setevent @TraceID, 159, 46, @on
exec sp_trace_setevent @TraceID, 159, 51, @on
exec sp_trace_setevent @TraceID, 159, 54, @on
exec sp_trace_setevent @TraceID, 159, 60, @on
exec sp_trace_setevent @TraceID, 159, 64, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
