# Respuesta a Issue #2: Filtrar por ASN

## Pregunta del Usuario
El usuario pregunta cómo filtrar por ASN (Autonomous System Number) para conocer el tráfico hacia Facebook.

## Respuesta

¡Hola @vigranad!

Gracias por tu pregunta. Este proyecto Docker Netflow utiliza **NfSen** y **nfdump** para recolectar y procesar datos de NetFlow. Ambas herramientas soportan el filtrado por ASN (Número de Sistema Autónomo).

### ¿Qué es este proyecto?

Este es un contenedor Docker que ejecuta:
- **NfSen**: Una interfaz web gráfica para visualizar datos de NetFlow
- **nfdump**: Herramientas de línea de comandos para procesar datos de NetFlow
- Colectores para NetFlow, IPFIX y sFlow

### Cómo filtrar por ASN

Para filtrar tráfico por ASN, puedes usar las siguientes sintaxis de filtros:

#### 1. En la interfaz web de NfSen

En la interfaz web de NfSen (http://tu-servidor:80/nfsen.php), puedes crear filtros o canales usando:

- Para filtrar tráfico donde el origen es un ASN específico:
  ```
  srcas <número_ASN>
  ```

- Para filtrar tráfico donde el destino es un ASN específico:
  ```
  dstas <número_ASN>
  ```

- Para filtrar tráfico donde el origen O el destino es un ASN específico:
  ```
  srcas <número_ASN> or dstas <número_ASN>
  ```

#### 2. Usando nfdump en línea de comandos

Si accedes al contenedor Docker, puedes usar nfdump directamente:

```bash
# Entrar al contenedor
docker exec -it <nombre_contenedor> bash

# Filtrar por ASN origen
nfdump -r /opt/nfsen/profiles-data/live/<fuente>/nfcapd.* 'srcas <número_ASN>'

# Filtrar por ASN destino
nfdump -r /opt/nfsen/profiles-data/live/<fuente>/nfcapd.* 'dstas <número_ASN>'

# Filtrar por ASN origen O destino
nfdump -r /opt/nfsen/profiles-data/live/<fuente>/nfcapd.* 'srcas <número_ASN> or dstas <número_ASN>'
```

### Ejemplo específico: Tráfico hacia Facebook

El ASN principal de Facebook (Meta Platforms, Inc.) es **AS32934**.

Para ver tu tráfico hacia Facebook, usa:

#### En la interfaz web de NfSen:
```
dstas 32934
```

O para ver tráfico en ambas direcciones:
```
srcas 32934 or dstas 32934
```

#### En línea de comandos:
```bash
nfdump -r /opt/nfsen/profiles-data/live/*/nfcapd.* 'dstas 32934'
```

### Otros ASN de Meta/Facebook

Facebook/Meta también puede usar otros ASN para diferentes servicios:
- **AS32934**: Facebook principal
- **AS54115**: Facebook adicional
- **AS63293**: WhatsApp

### Requisitos importantes

⚠️ **Nota importante**: Para que el filtrado por ASN funcione, tu dispositivo exportador de NetFlow (router, switch, etc.) debe estar configurado para exportar información de ASN en los registros de NetFlow. 

- NetFlow v5, v9 e IPFIX soportan campos de ASN
- Debes asegurarte de que tu dispositivo esté configurado para incluir esta información

### Recursos adicionales

- Documentación de nfdump: http://nfdump.sourceforge.net/
- Documentación de NfSen: http://nfsen.sourceforge.net/
- Sintaxis de filtros de nfdump: Consulta `man nfdump` o la documentación en línea

Espero que esta información te ayude. Si tienes más preguntas sobre el filtrado o la configuración, no dudes en preguntar.

---

**English Summary for Repository Maintainers:**

This answer explains how to filter NetFlow traffic by ASN (Autonomous System Number) using NfSen and nfdump, specifically for tracking Facebook traffic. The main Facebook ASN is AS32934. Users can filter using `srcas` and `dstas` keywords in both the NfSen web interface and nfdump command line. The key requirement is that the NetFlow exporter must be configured to include ASN information in the flow records.
