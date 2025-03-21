#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Iniciando entorno de Big Data y Machine Learning ===${NC}"

# Función para verificar si un contenedor está ejecutándose
check_service() {
  local container=$1
  local status=$(docker inspect -f '{{.State.Status}}' $container 2>/dev/null)
  if [ "$status" == "running" ]; then
    echo -e "${GREEN}✓ $container está en ejecución${NC}"
    return 0
  else
    echo -e "${RED}✗ $container no está ejecutándose correctamente${NC}"
    echo "   Estado actual: $status"
    echo "   Últimas líneas de log:"
    docker logs $container --tail 5 2>/dev/null
    return 1
  fi
}

# Función para iniciar servicios con reintentos
start_service() {
  local service=$1
  local max_attempts=${2:-3}
  local attempt=1
  
  echo -e "${BLUE}Iniciando $service (intento $attempt/$max_attempts)...${NC}"
  
  while [ $attempt -le $max_attempts ]; do
    docker-compose up -d $service
    sleep 5
    
    if check_service $service; then
      echo -e "${GREEN}Servicio $service iniciado correctamente${NC}"
      return 0
    else
      echo -e "${RED}Fallo al iniciar $service, reintentando...${NC}"
      docker-compose rm -f $service
      attempt=$((attempt+1))
      sleep 3
    fi
  done
  
  echo -e "${RED}No se pudo iniciar $service después de $max_attempts intentos${NC}"
  return 1
}

# Función para preparar directorios y archivos de configuración
prepare_environment() {
  echo -e "${BLUE}Preparando entorno...${NC}"
  
  # Crear directorios necesarios
#   mkdir -p ./conf/spark-conf
#   mkdir -p ./conf/hive-conf
#   mkdir -p ./conf/hue
#   mkdir -p ./notebooks
#   mkdir -p ./airflow/dags
#   mkdir -p ./airflow/logs
#   mkdir -p ./airflow/plugins
#   mkdir -p ./init/postgres-init
  
  # Verificar permisos
  echo "Configurando permisos..."
  chmod -R 777 ./conf
  chmod -R 777 ./notebooks
  chmod -R 777 ./airflow
}

# Pull de imágenes en grupos para evitar timeouts
pull_images() {
  echo -e "${BLUE}Descargando imágenes en grupos para evitar timeouts...${NC}"
  
  # Grupo 1: Hadoop/HDFS
  echo "Descargando imágenes de Hadoop/HDFS..."
  docker-compose pull namenode datanode1 datanode2 resourcemanager nodemanager historyserver
  
  # Grupo 2: Base de datos
  echo "Descargando imágenes de bases de datos..."
  docker-compose pull postgres_db pgadmin hive-metastore-postgresql mongodb redis
  
  # Grupo 3: Procesamiento
  echo "Descargando imágenes de procesamiento..."
  docker-compose pull spark-master spark-worker-1 spark-worker-2 spark-history
  
  # Grupo 4: Herramientas de análisis
  echo "Descargando imágenes de herramientas de análisis..."
  docker-compose pull jupyter hue superset
  
  # Grupo 5: Gestión de flujos
  echo "Descargando imágenes de gestión de flujos..."
  docker-compose pull nifi airflow-webserver airflow-scheduler
  
  # Grupo 6: Metastore
  echo "Descargando imágenes de metastore..."
  docker-compose pull hive-metastore hive-server
}

# Iniciar servicios en orden correcto con reintentos y esperas
start_services() {
  echo -e "${BLUE}Iniciando servicios en orden...${NC}"
  
  # 1. Iniciar servicios de almacenamiento
  echo "Iniciando servicios de almacenamiento..."
  start_service namenode
  start_service datanode1
  start_service datanode2
  echo "Esperando a que HDFS esté disponible..."
  sleep 15
  
  # 2. Iniciar servicios de recursos
  echo "Iniciando servicios de gestión de recursos..."
  start_service resourcemanager
  start_service nodemanager
  start_service historyserver
  sleep 10
  
  # 3. Iniciar bases de datos
  echo "Iniciando bases de datos..."
  start_service postgres_db
  start_service hive-metastore-postgresql
  start_service mongodb
  start_service redis
  sleep 15
  
  # 4. Iniciar Hive
  echo "Iniciando servicios de Hive..."
  start_service hive-metastore
  sleep 10
  start_service hive-server
  sleep 15
  
  # 5. Iniciar Spark
  echo "Iniciando servicios de Spark..."
  start_service spark-master
  sleep 10
  start_service spark-worker-1
  start_service spark-worker-2
  start_service spark-history
  sleep 10
  
  # 6. Iniciar herramientas de análisis
  echo "Iniciando herramientas de análisis..."
  start_service jupyter
  start_service hue
  start_service superset
  start_service pgadmin
  sleep 10
  
  # 7. Iniciar servicios de flujo
  echo "Iniciando servicios de flujo de datos..."
  start_service nifi
  start_service airflow-webserver
  start_service airflow-scheduler
}

# Imprimir información de los servicios
print_service_info() {
  echo -e "${YELLOW}=== URLs de servicios ===${NC}"
  echo -e "${GREEN}Hadoop NameNode${NC}: http://localhost:9870"
  echo -e "${GREEN}Hadoop Resource Manager${NC}: http://localhost:8088"
  echo -e "${GREEN}Spark Master${NC}: http://localhost:8080"
  echo -e "${GREEN}Spark History${NC}: http://localhost:18080"
  echo -e "${GREEN}Jupyter Notebook${NC}: http://localhost:8888"
  echo -e "${GREEN}Hive Server${NC}: http://localhost:10002"
  echo -e "${GREEN}NiFi${NC}: http://localhost:8090"
  echo -e "${GREEN}Airflow${NC}: http://localhost:8089"
  echo -e "${GREEN}PGAdmin${NC}: http://localhost:${PORT_PGA:-5050}"
  echo -e "${GREEN}MongoDB${NC}: localhost:27017"
  echo -e "${GREEN}Superset${NC}: http://localhost:8088"
  echo -e "${GREEN}Hue${NC}: http://localhost:8888"
  
  echo -e "${YELLOW}=== Verificando servicios principales ===${NC}"
  services=("namenode" "datanode1" "datanode2" "resourcemanager" 
           "hive-metastore" "hive-server" "spark-master" "spark-worker-1" 
           "jupyter" "airflow-webserver" "postgres_db" "pgadmin")
  
  for service in "${services[@]}"; do
    check_service $service
  done
}

# Función principal
main() {
  # Verificar que Docker y Docker Compose estén instalados
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker no está instalado. Por favor, instálelo primero.${NC}"
    exit 1
  fi
  
  if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose no está instalado. Por favor, instálelo primero.${NC}"
    exit 1
  fi
  
  # Preparar el entorno
  prepare_environment
  
  # Descargar imágenes en grupos
  pull_images
  
  # Iniciar servicios
  start_services
  
  # Mostrar información
  print_service_info
  
  echo -e "${YELLOW}=== Entorno inicializado! ===${NC}"
  echo -e "${YELLOW}Nota: Si algún servicio no está disponible, puede intentar reiniciarlo con:${NC}"
  echo -e "docker-compose restart <nombre_servicio>"
}

# Ejecutar función principal
main "$@"