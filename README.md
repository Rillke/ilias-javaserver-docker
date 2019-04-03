# ILIAS Chat Server

⚠ Work in progress. Untested preview. With many spelling errors inside. ⚠

Docker-ized version of the [**ILIAS Java Server**](https://github.com/ILIAS-eLearning/ILIAS/blob/trunk/Services/WebServices/RPC/lib/README.md).

> If activated, it is possible to search in PDF, HTML files and HTML-Learning modules

The Java-Server of the ILIAS LMS periodically pre-populates a search index using Apache Lucene and provides an RPC service to ILIAS in order to speed-up search in larger ILIAS instances.

This Docker files / image aims to facilitate setting up the Java server in an isolated environment, either as part of the docker(-compose) network on the same host as ILIAS, or distributed to another physical or virtual host.

* Code on [GitHub](https://github.com/uni-halle/ilias-javaserver-docker) ([Issues](https://github.com/uni-halle/ilias-javaserver-docker/issues))
* Image on [Docker Hub](https://hub.docker.com/r/unihalle/ilias-javaserver)
* Author: Dockerization: Abt. Anwendungssysteme, [ITZ Uni Halle](http://itz.uni-halle.de/); Image includes various open source software.
  See Dockerfile for details.
* Support: As a **university** or **research facility** you might be successful in requesting support through the **[ITZ Helpdesk](mailto:helpdesk@itz.uni-halle.de)** (this can take some time) or contacting the author directly. For **any other entity**, including **companies**, see [my home page](https://wohlpa.de/) for contact details and pricing. You may request hosting, support or customizations.
  *Reporting issues and creating pull requests is always welcome and appreciated.*

## Which version/ tag?

There are multiple versions/ tags available under [dockerhub:unihalle/ilias-javaserver/tags/](https://hub.docker.com/r/unihalle/ilias-javaserver/tags/). Please ensure the tag matches your ILIAS minor release's version number (MAJOR.MINOR.PATCH).

## Basic usage

Create the following file:

`.env` (adjust the values):
```
# Time zone
TZ=Europe/Berlin

# Path to the ILIAS instance
ILIAS_HTTP_PATH=https://ilias.example.com

# Name of the ILIAS client / teanant
# and its NIC ID
# Open /setup/setup.php on your ILIAS instance
# if you are not sure. If you logged-in as root
# choose your client; otherwise take the values
# directly from "Overview -> Description"
# You have to install ILIAS first in order to
# obtain these values.
LUCENE_CLIENT_ID=ilias-main-client
LUCENE_NIC_ID=1234

# Log level: log4j levels possible:
# TRACE|OFF|FATAL|ERROR|WARN|INFO|DEBUG|ALL
LUCENE_LOG_LEVEL=WARN

# Number of threads used for indexing
LUCENE_NUM_THREADS=2

# Amount of heap memory available to the Java server in MiB
LUCENE_RAM_BUFFER_SIZE=2048

# Maximun file size to consider while indexing in MB
LUCENE_INDEX_MAX_FILE_SIZE=500
```

### Running using Docker only

```
docker run -d \
   --name TestIliasjavaserver \
   --env-file .env \
   -p "127.0.0.1:11111:11111" \
   -v "/path/to/plugin-dir:/var/www/ilias/Customizing/global/plugins:ro" \
   -v "/path/to/ilias-public-data:/var/www/ilias/data" \
   -v "/path/to/ilias-private-data:/var/ilias/private_data" \
   -v "/path/to/log-files:/var/log/lucene" \
   -v "/etc/localtime:/etc/localtime:ro" \
   unihalle/ilias-javaserver
```

TODO: Explain every line.

You can now test your chat server at http://localhost:11111//RPC2 - for instance:

```
curl -H "Host: 0.0.0.0:11111" -H "Content-Length: 129" \
-d '<?xml version="1.0" encoding="UTF-8"?><methodCall><methodName>RPCAdministration.status</methodName><params></params></methodCall>' \
-X POST http://127.0.0.1:11111//RPC2
```

### Running using docker-compose

Minimal example (binds port 11111 to localhost):

`docker-compose.yaml`:
```
version: "2"
services:
  javaserver:
    image: unihalle/ilias-javaserver:v5.3.13
    restart: always
    environment:
      - LUCENE_CLIENT_ID
      - LUCENE_NIC_ID
      - LUCENE_LOG_LEVEL
      - LUCENE_NUM_THREADS
      - LUCENE_RAM_BUFFER_SIZE
      - LUCENE_INDEX_MAX_FILE_SIZE
    ports:
      - "127.0.0.1:11111:11111"
    volumes:
      - ...
```

You can now test your Java server at http://127.0.0.1:11111//RPC2
Inside the docker-compose network, the URL is `http://javaserver:11111//RPC2`
cURL example above.

## Configuring ILIAS

PHP curl and xmlrpc [are required for using the Java server features](https://github.com/ILIAS-eLearning/ILIAS/blob/trunk/Services/WebServices/RPC/lib/README.md).

Go to `Administration`→`General Settings`→`Server`→`Java-Server`

Java-Server:

* Host: Provide the host name or IP of the Java-Server host so that PHP can
        establish connections to that server.
* Port: Port under which the PHP Server can reach the Java server

Go to `Administration`→`Search`

`Settings` → `Search Settings`:
* Type: Lucene search

`Lucene` → `Lucene Settings`:
* Configure as you prefer

If you would like to use the ILIAS cron scheduler, go to `Administration`→`General Settings`→`Cron jobs`
* Look for the `Update Lucene serch index` job and configure it as to you like. Our job runs once a day causing a delay of one day until uploads can be searched.
* The ILIAS cron scheduler itself must be regularly triggered. Read the ILIAS installation manual in order to find out how. As of writing this manual, it is no more than calling `php cron/cron.php \"$ILIAS_CRON_USER\" \"$ILIAS_CRON_PASSWORD\" \"$ILIAS_CLIENT_NAME\"`.

If you do not like using the ILIAS cron scheduler, a command like the following should update the index periodically:
`docker exec -it javaserver bash -c 'java -jar ./ilServer.jar /var/www/ilias/ilias.ini.php updateIndex $LUCENE_CLIENT_ID'`
