PRINT 'Creating database....'

/****** Object:  Database [SolidQ_ServiceBroker]    Script Date: 01-09-2017 11:24:21 ******/
USE [master]
IF EXISTS(select * from sys.databases where name='SolidQ_ServiceBroker')
DROP DATABASE [SolidQ_ServiceBroker]
GO

CREATE DATABASE SolidQ_ServiceBroker
GO

ALTER DATABASE [SolidQ_ServiceBroker] ADD FILEGROUP [CustomerData]
GO


DECLARE @SqlStr NVARCHAR(MAX), @dir NVARCHAR(MAX)

SELECT @Dir = CAST(serverproperty('InstanceDefaultDataPath') AS NVARCHAR(MAX))
SET @SqlStr = 'ALTER DATABASE [SolidQ_ServiceBroker] ADD FILE ( NAME = N''SolidQ_ServiceBroker_Data'', FILENAME = N''' + @dir + 'SolidQ_ServiceBroker.ndf'' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [CustomerData]'
EXEC (@SqlStr)
GO

USE [SolidQ_ServiceBroker]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'CustomerData') ALTER DATABASE [SolidQ_ServiceBroker] MODIFY FILEGROUP [CustomerData] DEFAULT
GO



USE [master]
GO
ALTER DATABASE [SolidQ_ServiceBroker] SET RECOVERY SIMPLE WITH NO_WAIT
GO

USE [SolidQ_ServiceBroker]
GO

EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false
GO

CREATE SCHEMA [SolidQ] AUTHORIZATION [dbo]
GO

PRINT 'Creating Dynamic Management Views tables'

CREATE TABLE SolidQ.dm_broker_queue_monitors
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_dm_broker_queue_monitors_sampleTime DEFAULT GETDATE()
	, database_id INT
	, queue_id INT
	, [state] nvarchar(64)
	, last_empty_rowset_time DATETIME
	, last_activated_time DATETIME
	, tasks_waiting	INT
)
GO
ALTER TABLE SolidQ.dm_broker_queue_monitors ADD CONSTRAINT PK_dm_broker_queue_monitors PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.dm_broker_activated_tasks
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_dm_broker_activated_tasks_sampleTime DEFAULT GETDATE()
	, spid INT
	, database_id SMALLINT
	, queue_id INT
	, procedure_name NVARCHAR(650)
	, execute_as INT
)
GO
ALTER TABLE SolidQ.dm_broker_activated_tasks ADD CONSTRAINT PK_dm_broker_activated_tasks PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.dm_broker_connections
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_dm_broker_connections_sampleTime DEFAULT GETDATE()
	, connection_id	uniqueidentifier
	, transport_stream_id	uniqueidentifier
	, state	smallint
	, state_desc	nvarchar(120)
	, connect_time	datetime
	, login_time	datetime
	, authentication_method	nvarchar(256)
	, principal_name	nvarchar(256)
	, remote_user_name	nvarchar(256)
	, last_activity_time	datetime
	, is_accept	bit
	, login_state	smallint
	, login_state_desc	nvarchar(120)
	, peer_certificate_id	int
	, encryption_algorithm	smallint
	, encryption_algorithm_desc	nvarchar(120)
	, receives_posted	smallint
	, is_receive_flow_controlled	bit
	, sends_posted	smallint
	, is_send_flow_controlled	bit
	, total_bytes_sent	bigint
	, total_bytes_received	bigint
	, total_fragments_sent	bigint
	, total_fragments_received	bigint
	, total_sends	bigint
	, total_receives	bigint
	, peer_arbitration_id	uniqueidentifier
)
GO
ALTER TABLE SolidQ.dm_broker_connections ADD CONSTRAINT PK_dm_broker_connections PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.dm_broker_forwarded_messages
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_dm_broker_forwarded_messages_sampleTime DEFAULT GETDATE()
	, conversation_id	uniqueidentifier
	, is_initiator	bit
	, to_service_name	nvarchar(512)
	, to_broker_instance	nvarchar(512)
	, from_service_name	nvarchar(512)
	, from_broker_instance	nvarchar(512)
	, adjacent_broker_address	nvarchar(512)
	, message_sequence_number	bigint
	, message_fragment_number	int
	, hops_remaining	tinyint
	, time_to_live	int
	, time_consumed	int
	, message_id	uniqueidentifier
)
GO
ALTER TABLE SolidQ.dm_broker_forwarded_messages ADD CONSTRAINT PK_dm_broker_forwarded_messages PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

PRINT 'Creating Catalog Views tables'

CREATE TABLE SolidQ.service_message_types
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_service_message_types_sampleTime DEFAULT GETDATE()
	, name	sysname
	, message_type_id	int
	, principal_id	int
	, validation	char(2)
	, validation_desc	nvarchar(120)
	, xml_collection_id	int
)
GO
ALTER TABLE SolidQ.service_message_types ADD CONSTRAINT PK_service_message_types PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.service_contracts
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_service_contracts_sampleTime DEFAULT GETDATE()
	, name	sysname
	, service_contract_id	int
	, principal_id	int
)
GO
ALTER TABLE SolidQ.service_contracts ADD CONSTRAINT PK_service_contracts PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.service_contract_message_usages
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_service_contract_message_usages_sampleTime DEFAULT GETDATE()
	, service_contract_id	int
	, message_type_id	int
	, is_sent_by_initiator	bit
	, is_sent_by_target	bit
)
GO
ALTER TABLE SolidQ.service_contract_message_usages ADD CONSTRAINT PK_service_contract_message_usages PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.service_contract_usages
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_service_contract_usages_sampleTime DEFAULT GETDATE()
	, service_id int
	, service_contract_id	int
)
GO
ALTER TABLE SolidQ.service_contract_usages ADD CONSTRAINT PK_service_contract_usages PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.service_queues
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_service_queues_sampleTime DEFAULT GETDATE()
	, name	sysname
	, object_id	int
	, principal_id	int
	, schema_id	int
	, parent_object_id	int
	, type	char(2)
	, type_desc	nvarchar(120)
	, create_date	datetime
	, modify_date	datetime
	, is_ms_shipped	bit
	, is_published	bit
	, is_schema_published	bit
	, max_readers	smallint
	, activation_procedure	nvarchar(1552)
	, execute_as_principal_id	int
	, is_activation_enabled	bit
	, is_receive_enabled	bit
	, is_enqueue_enabled	bit
	, is_retention_enabled	bit
	, is_poison_message_handling_enabled	bit
)
GO
ALTER TABLE SolidQ.service_queues ADD CONSTRAINT PK_service_queues PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.service_queue_usages
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_service_queue_usages_sampleTime DEFAULT GETDATE()
	, service_id	int
	, service_queue_id	int
)
GO
ALTER TABLE SolidQ.service_queue_usages ADD CONSTRAINT PK_service_queue_usages PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.services
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_services_sampleTime DEFAULT GETDATE()
	, name sysname
	, service_id	int
	, principal_id	int
	, service_queue_id	int
)
GO
ALTER TABLE SolidQ.services ADD CONSTRAINT PK_services PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.routes
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_routes_sampleTime DEFAULT GETDATE()
	, name sysname
	, route_id	int
	, principal_id	int
	, remote_service_name	nvarchar(512)
	, broker_instance	nvarchar(256)
	, lifetime	datetime
	, address	nvarchar(512)
	, mirror_address	nvarchar(512)
)
GO
ALTER TABLE SolidQ.routes ADD CONSTRAINT PK_routes PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.conversation_priorities
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_conversation_priorities_sampleTime DEFAULT GETDATE()
	, priority_id	int
	, name sysname
	, service_contract_id	int
	, local_service_id	int
	, remote_service_name	nvarchar(512)
	, priority	tinyint
)
GO
ALTER TABLE SolidQ.conversation_priorities ADD CONSTRAINT PK_conversation_priorities PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.conversation_groups
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_conversation_groups_sampleTime DEFAULT GETDATE()
	, conversation_group_id	uniqueidentifier
	, service_id	int
	, is_system	bit
)
GO
ALTER TABLE SolidQ.conversation_groups ADD CONSTRAINT PK_conversation_groups PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.conversation_endpoints
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_conversation_endpoints_sampleTime DEFAULT GETDATE()
	, conversation_handle	uniqueidentifier
	, conversation_id	uniqueidentifier
	, is_initiator	bit
	, service_contract_id	int
	, conversation_group_id	uniqueidentifier
	, service_id	int
	, lifetime	datetime
	, state	char(2)
	, state_desc	nvarchar(120)
	, far_service	nvarchar(512)
	, far_broker_instance	nvarchar(256)
	, principal_id	int
	, far_principal_id	int
	, outbound_session_key_identifier	uniqueidentifier
	, inbound_session_key_identifier	uniqueidentifier
	, security_timestamp	datetime
	, dialog_timer	datetime
	, send_sequence	bigint
	, last_send_tran_id	binary
	, end_dialog_sequence	bigint
	, receive_sequence	bigint
	, receive_sequence_frag	int
	, system_sequence	bigint
	, first_out_of_order_sequence	bigint
	, last_out_of_order_sequence	bigint
	, last_out_of_order_frag	int
	, is_system	bit
	, priority	tinyint
)
GO
ALTER TABLE SolidQ.conversation_endpoints ADD CONSTRAINT PK_conversation_endpoints PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

CREATE TABLE SolidQ.remote_service_bindings
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_remote_service_bindings_sampleTime DEFAULT GETDATE()
	, name	sysname
	, remote_service_binding_id	int
	, principal_id	int
	, remote_service_name	nvarchar(512)
	, service_contract_id	int
	, remote_principal_id	int
	, is_anonymous_on	bit
)
GO
ALTER TABLE SolidQ.remote_service_bindings ADD CONSTRAINT PK_remote_service_bindings PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

PRINT 'Creating Performance Counter tables'

CREATE TABLE SolidQ.BrokerPerfCounters
(
	monitorsID INT NOT NULL IDENTITY(1,1)
	, sampleTime DATETIME NOT NULL CONSTRAINT DF_BrokerPerfCounters_sampleTime DEFAULT GETDATE()
	, CounterName nvarchar(512)
	, [Value] Float
)
GO
ALTER TABLE SolidQ.BrokerPerfCounters ADD CONSTRAINT PK_BrokerPerfCounters PRIMARY KEY CLUSTERED (monitorsID, sampleTime)
GO

