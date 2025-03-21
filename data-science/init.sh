#!/bin/bash

# Create the directory structure
echo "Creating directory structure..."
mkdir -p conf/hadoop-conf conf/spark-conf conf/hive-conf conf/nifi-conf conf/hadoop-conf conf/hue
mkdir -p init/postgres-init init/hive-init 
mkdir -p data notebooks airflow/dags airflow/logs airflow/plugins


# Copy configuration files to their directories
echo "Copiando archivos de configuración..."

# Hadoop environment variables
cat > hadoop.env << 'EOF'
CORE_CONF_fs_defaultFS=hdfs://namenode:9000
CORE_CONF_hadoop_http_staticuser_user=root
CORE_CONF_hadoop_proxyuser_hue_hosts=*
CORE_CONF_hadoop_proxyuser_hue_groups=*
CORE_CONF_io_compression_codecs=org.apache.hadoop.io.compress.SnappyCodec

HDFS_CONF_dfs_webhdfs_enabled=true
HDFS_CONF_dfs_permissions_enabled=false
HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check=false

YARN_CONF_yarn_log___aggregation___enable=true
YARN_CONF_yarn_log_server_url=http://historyserver:8188/applicationhistory/logs/
YARN_CONF_yarn_resourcemanager_recovery_enabled=true
YARN_CONF_yarn_resourcemanager_store_class=org.apache.hadoop.yarn.server.resourcemanager.recovery.FileSystemRMStateStore
YARN_CONF_yarn_resourcemanager_scheduler_class=org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler
YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb=8192
YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores=4
YARN_CONF_yarn_resourcemanager_fs_state___store_uri=/rmstate
YARN_CONF_yarn_resourcemanager_system___metrics___publisher_enabled=true
YARN_CONF_yarn_resourcemanager_hostname=resourcemanager
YARN_CONF_yarn_resourcemanager_address=resourcemanager:8032
YARN_CONF_yarn_resourcemanager_scheduler_address=resourcemanager:8030
YARN_CONF_yarn_resourcemanager_resource___tracker_address=resourcemanager:8031
YARN_CONF_yarn_timeline___service_enabled=true
YARN_CONF_yarn_timeline___service_generic___application___history_enabled=true
YARN_CONF_yarn_timeline___service_hostname=historyserver
YARN_CONF_mapreduce_map_output_compress=true
YARN_CONF_mapred_map_output_compress_codec=org.apache.hadoop.io.compress.SnappyCodec
YARN_CONF_yarn_nodemanager_resource_memory___mb=16384
YARN_CONF_yarn_nodemanager_resource_cpu___vcores=8
YARN_CONF_yarn_nodemanager_disk___health___checker_max___disk___utilization___per___disk___percentage=98.5
YARN_CONF_yarn_nodemanager_remote___app___log___dir=/app-logs
YARN_CONF_yarn_nodemanager_aux___services=mapreduce_shuffle

MAPRED_CONF_mapreduce_framework_name=yarn
MAPRED_CONF_mapred_child_java_opts=-Xmx4096m
MAPRED_CONF_mapreduce_map_memory_mb=4096
MAPRED_CONF_mapreduce_reduce_memory_mb=8192
MAPRED_CONF_mapreduce_map_java_opts=-Xmx3072m
MAPRED_CONF_mapreduce_reduce_java_opts=-Xmx6144m
MAPRED_CONF_yarn_app_mapreduce_am_env=HADOOP_MAPRED_HOME=/opt/hadoop-2.7.4/
MAPRED_CONF_mapreduce_map_env=HADOOP_MAPRED_HOME=/opt/hadoop-2.7.4/
MAPRED_CONF_mapreduce_reduce_env=HADOOP_MAPRED_HOME=/opt/hadoop-2.7.4/
EOF

# Spark defaults configuration
cat > conf/spark-conf/spark-defaults.conf << 'EOF'
# Configuración para Spark:

# Configuración del master
spark.master                     spark://spark-master:7077
spark.driver.memory              1g
spark.executor.memory            1g
spark.executor.cores             1
spark.default.parallelism        2
spark.sql.shuffle.partitions     2

# Configuración para integración con Hadoop/HDFS
spark.hadoop.fs.defaultFS        hdfs://namenode:9000

# Configuración para integración con Hive
spark.sql.warehouse.dir          hdfs://namenode:9000/user/hive/warehouse
spark.sql.hive.metastore.version 2.3.0
spark.sql.hive.metastore.jars    path
spark.sql.hive.metastore.jars.path /opt/hive/lib/*
spark.sql.catalogImplementation  hive
spark.hive.metastore.uris        thrift://hive-metastore:9083

# Configuración para el History Server
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://namenode:9000/spark-logs
spark.history.fs.logDirectory    hdfs://namenode:9000/spark-logs

# Gestión de memoria y recursos
spark.memory.fraction            0.6
spark.memory.storageFraction     0.5

# Serialización
spark.serializer                 org.apache.spark.serializer.KryoSerializer

# Optimización de rendimiento
spark.speculation                false
spark.dynamicAllocation.enabled  false

# Configuración para el driver UI
spark.ui.port                    4040
spark.ui.reverseProxy            true
EOF

# Hive site configuration
cat > conf/hive-conf/hive-site.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<configuration>
    <!-- Configuración de conexión a PostgreSQL mejorada -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://hive-metastore-postgresql:5432/metastore</value>
        <description>PostgreSQL JDBC driver connection URL</description>
    </property>
    
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
        <description>PostgreSQL JDBC driver class</description>
    </property>
    
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hive</value>
        <description>Username for metastore database</description>
    </property>
    
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>hive</value>
        <description>Password for metastore database</description>
    </property>
    
    <!-- Optimización del pool de conexiones -->
    <property>
        <name>datanucleus.connectionPool.maxPoolSize</name>
        <value>25</value>
        <description>Tamaño máximo del pool de conexiones</description>
    </property>
    
    <property>
        <name>datanucleus.connectionPool.minPoolSize</name>
        <value>5</value>
        <description>Tamaño mínimo del pool de conexiones</description>
    </property>
    
    <property>
        <name>datanucleus.connectionPool.maxActive</name>
        <value>100</value>
        <description>Máximo de conexiones activas</description>
    </property>
    
    <!-- Configuración de esquema y directorio de Hive -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>hdfs://namenode:9000/user/hive/warehouse</value>
        <description>Location of default database for the warehouse</description>
    </property>
    
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://hive-metastore:9083</value>
        <description>URI for client to connect to remote metastore</description>
    </property>
    
    <!-- Configuración de compresión y rendimiento -->
    <property>
        <name>hive.exec.compress.output</name>
        <value>true</value>
        <description>Compress Hive query output</description>
    </property>
    
    <property>
        <name>hive.exec.compress.intermediate</name>
        <value>true</value>
        <description>Compress intermediate files during Hive query execution</description>
    </property>
    
    <property>
        <name>hive.default.fileformat</name>
        <value>ORC</value>
        <description>Default file format for Hive tables</description>
    </property>
    
    <!-- Optimización para consultas -->
    <property>
        <name>hive.optimize.reducededuplication</name>
        <value>true</value>
        <description>Reduce duplicated work in queries</description>
    </property>
    
    <property>
        <name>hive.vectorized.execution.enabled</name>
        <value>true</value>
        <description>Enable vectorized mode of execution</description>
    </property>
    
    <property>
        <name>hive.vectorized.execution.reduce.enabled</name>
        <value>true</value>
        <description>Enable vectorized mode of the reduce-side of query execution</description>
    </property>
    
    <property>
        <name>hive.optimize.skewjoin</name>
        <value>true</value>
        <description>Optimize joins with skewed keys</description>
    </property>
    
    <property>
        <name>hive.exec.parallel</name>
        <value>true</value>
        <description>Enable parallel execution of map/reduce tasks</description>
    </property>
    
    <property>
        <name>hive.exec.parallel.thread.number</name>
        <value>8</value>
        <description>Number of threads for parallel execution</description>
    </property>
    
    <!-- Configuración de memoria y recursos -->
    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
        <description>Use Tez as execution engine for better performance</description>
    </property>
    
    <property>
        <name>hive.tez.container.size</name>
        <value>4096</value>
        <description>Tez container size in MB</description>
    </property>
    
    <property>
        <name>hive.tez.java.opts</name>
        <value>-Xmx3276m -XX:+UseG1GC -XX:+ResizeTLAB</value>
        <description>JVM options for Tez containers</description>
    </property>
    
    <!-- Configuración del servidor HiveServer2 -->
    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
        <description>Port for HiveServer2 Thrift service</description>
    </property>
    
    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>0.0.0.0</value>
        <description>Bind host for HiveServer2 Thrift server</description>
    </property>
    
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
        <description>Disable user impersonation for HiveServer2</description>
    </property>
    
    <property>
        <name>hive.server2.authentication</name>
        <value>NONE</value>
        <description>Authentication method for HiveServer2</description>
    </property>
    
    <property>
        <name>hive.server2.session.check.interval</name>
        <value>6h</value>
        <description>Check session timeout interval</description>
    </property>
    
    <property>
        <name>hive.server2.idle.session.timeout</name>
        <value>12h</value>
        <description>Session timeout</description>
    </property>
    
    <property>
        <name>hive.server2.logging.operation.enabled</name>
        <value>true</value>
        <description>Enable operation logging</description>
    </property>
    
    <!-- Seguridad y verificación de esquema -->
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>false</value>
        <description>Skip metastore schema version verification</description>
    </property>
    
    <property>
        <name>hive.metastore.client.connect.retry.delay</name>
        <value>5s</value>
        <description>Time between metastore connection retries</description>
    </property>
    
    <property>
        <name>hive.metastore.client.socket.timeout</name>
        <value>600s</value>
        <description>Socket timeout for metastore client</description>
    </property>
    
    <property>
        <name>hive.server2.max.start.attempts</name>
        <value>5</value>
        <description>Maximum number of start attempts for HiveServer2</description>
    </property>
    
    <property>
        <name>datanucleus.autoCreateSchema</name>
        <value>false</value>
        <description>Auto creates the necessary schema in the JDBC datastore</description>
    </property>
    
    <property>
        <name>datanucleus.fixedDatastore</name>
        <value>true</value>
        <description>Whether the datastore is fixed</description>
    </property>
    
    <!-- Estadísticas y ejecución CBO -->
    <property>
        <name>hive.stats.fetch.column.stats</name>
        <value>true</value>
        <description>Fetch column statistics for query optimization</description>
    </property>
    
    <property>
        <name>hive.stats.autogather</name>
        <value>true</value>
        <description>Auto gather statistics during data insertion</description>
    </property>
    
    <property>
        <name>hive.cbo.enable</name>
        <value>true</value>
        <description>Enable cost-based optimization</description>
    </property>
</configuration>
EOF

# Hive site configuration
cat > init/hive-init/init-schema.sql<< 'EOF'
-- Script de inicialización para el esquema de Hive
-- Guarda este archivo en init/hive-init/init-schema.sql

-- Creación de la base de datos metastore
CREATE DATABASE IF NOT EXISTS metastore;
\c metastore;

-- Creación de tablas para el esquema del metastore de Hive
-- Nota: Este es un script simplificado, el esquema completo se inicializa por Hive

-- Tabla para funciones
CREATE TABLE IF NOT EXISTS FUNCS (
    FUNC_ID BIGINT PRIMARY KEY,
    CLASS_NAME VARCHAR(4000),
    CREATE_TIME INT,
    DB_ID BIGINT,
    FUNC_NAME VARCHAR(128),
    FUNC_TYPE INT,
    OWNER_NAME VARCHAR(128),
    OWNER_TYPE INT
);

-- Tabla para bases de datos
CREATE TABLE IF NOT EXISTS DBS (
    DB_ID BIGINT PRIMARY KEY,
    DESC VARCHAR(4000),
    DB_LOCATION_URI VARCHAR(4000) NOT NULL,
    NAME VARCHAR(128) UNIQUE,
    OWNER_NAME VARCHAR(128),
    OWNER_TYPE INT
);

-- Tabla para tablas
CREATE TABLE IF NOT EXISTS TBLS (
    TBL_ID BIGINT PRIMARY KEY,
    CREATE_TIME INT,
    DB_ID BIGINT REFERENCES DBS(DB_ID),
    LAST_ACCESS_TIME INT,
    OWNER VARCHAR(767),
    RETENTION INT,
    SD_ID BIGINT,
    TBL_NAME VARCHAR(256),
    TBL_TYPE VARCHAR(128),
    VIEW_EXPANDED_TEXT TEXT,
    VIEW_ORIGINAL_TEXT TEXT
);

-- Tabla para particiones
CREATE TABLE IF NOT EXISTS PARTITIONS (
    PART_ID BIGINT PRIMARY KEY,
    CREATE_TIME INT,
    LAST_ACCESS_TIME INT,
    PART_NAME VARCHAR(767),
    SD_ID BIGINT,
    TBL_ID BIGINT REFERENCES TBLS(TBL_ID)
);

-- Índices
CREATE INDEX IF NOT EXISTS TBLS_N49 ON TBLS(SD_ID);
CREATE INDEX IF NOT EXISTS TBLS_N50 ON TBLS(DB_ID);
CREATE INDEX IF NOT EXISTS PARTITIONS_N49 ON PARTITIONS(SD_ID);
CREATE INDEX IF NOT EXISTS PARTITIONS_N50 ON PARTITIONS(TBL_ID);

-- Concede permisos al usuario hive
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hive;
EOF

# Hive site configuration
cat > init/postgres-init/init.sql << 'EOF'
-- Create Airflow database
CREATE DATABASE airflow;

-- Create a user for Airflow
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

-- Create a database for ML applications if needed
CREATE DATABASE ml_data;
CREATE USER ml_user WITH PASSWORD 'ml_password';
GRANT ALL PRIVILEGES ON DATABASE ml_data TO ml_user;

-- Setup permissions
ALTER USER postgres WITH SUPERUSER;

EOF

# .env configuration
cat > .env << 'EOF'
# Credenciales para Redis
REDIS_PASSWORD=mailitoredis

# Credenciales para MongoDB
MONGO_USERNAME=mailitomongo
MONGO_PASSWORD=mailitomongo

# Configuración para PostgreSQL
PORT_DB=5432
PORT_DBA=5432
DB_PASSWORD=mailitopostgres

# Configuración para PGAdmin
PORT_PGA=5050
PORT_PGB=80
PGADMIN_EMAIL=clblommberg@gmail.com
PGADMIN_PASSWORD=mailitopgadmin

# Credenciales para MSSQL Server
MSSQL_SA_PASSWORD=mailitomssql

# Airflow
AIRFLOW_USER=airflow
AIRFLOW_PASSWORD=airflow
AIRFLOW_DB=airflow
AIRFLOW_FERNET_KEY=46BKJoQYlPPOexq0OhDZnIlNepKFf87WFwLbfzqDDho=

# Superset
SUPERSET_SECRET_KEY=supersetsecretkey

# Hive configuration
HIVE_USER=hive
HIVE_PASSWORD=hive_password
HIVE_DB=hive

EOF

# Hive site configuration
cat > conf/hue/z-hue.ini<< 'EOF'

# Configuración de base de datos para Hue
[desktop]
secret_key=jFE93j;2[290-eiw.KEiwN2s3['d;/.q[eIW^y#e=+Iei*@Mn<qW5o
http_host=0.0.0.0
http_port=8888
is_hue_4=true
time_zone=America/Los_Angeles
dev=false

# Database configuration
[[database]]
engine=postgresql_psycopg2
host=postgres_db
port=5432
user=postgres
password=postgres_password
name=hue

# Configuración SMTP
[[smtp]]
host=
port=25
user=
password=
tls=no

# Autenticación
[auth]
backend=desktop.auth.backend.AllowFirstUserDjangoBackend

# HDFS (Hadoop File System)
[hadoop]
[[hdfs_clusters]]
[[[default]]]
fs_defaultfs=hdfs://namenode:9000
webhdfs_url=http://namenode:50070/webhdfs/v1

# Hive
[beeswax]
hive_server_host=hive-server
hive_server_port=10000

# Impala (opcional)
[impala]
server_host=localhost
server_port=21050

# Spark
[spark]
spark_master_url=spark://spark-master:7077

# Editor de SQL
[notebook]
show_notebooks=true

# Corrección para resolución de hosts
[[yarn_clusters]]
[[[default]]]
resourcemanager_host=resourcemanager
resourcemanager_port=8088
EOF

echo "Completados"