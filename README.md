# New PostgreSQL catalog and config backend for GeoServer Cloud example

## Configuration

See `config/values.yml` and `config/jndi.yml`.

## Run

Add the AWS credentials to the `aws_credentials` file. It's used to create the sample COGs.

Should look like:

```
[default]
aws_access_key_id = XXXXXXXX
aws_secret_access_key = YYYYYYYYYYYYYYYYY
```

Run the composition:

```
docker compose pull
docker compose up -d
```

## Check start up time

Initial start up time with an empty data directory:

```
docker compose logs|grep "JVM running"| cut -d":" -f4|sort
 Started GatewayApplication in 1.667 seconds (JVM running for 1.843)
 Started RestConfigApplication in 6.873 seconds (JVM running for 7.226)
 Started WebUIApplication in 7.191 seconds (JVM running for 7.654)
 Started WfsApplication in 6.945 seconds (JVM running for 7.296)
 Started WmsApplication in 7.272 seconds (JVM running for 7.636)
```

## Import test data:

The following scripts will load NaturalEarth vector layers to postgis and configure them in the `ne` workspace,
and Natural Earth COGS in the `cog` workspace.

```
./import_cogs.sh
./import_postgis.sh
```

Open the [PostGIS](http://localhost:9090/geoserver/cloud/wms?service=WMS&version=1.1.0&request=GetMap&layers=world&bbox=-180.0%2C-90.0%2C180.0%2C90.0&width=768&height=384&srs=EPSG%3A4326&styles=&format=application/openlayers) or [COG](http://localhost:9090/geoserver/cloud/wms?service=WMS&version=1.1.0&request=GetMap&layers=land_shallow_topo_21600&bbox=-180.0%2C-90.0%2C180.0%2C90.0&width=768&height=384&srs=EPSG%3A4326&styles=&format=application/openlayers) layer preview.


## Create thousands of layers

Use the "Catalog Bulk Load Tool" to create 5k recursive copies of the `cog` and `ne` workspaces (make sure to check the `Resursive copy` checkbox).

This results in about 45k layers, 25k stores, and 10k workspaces.

## Startup time test

Restart the docker composition and check for applications startup time:

```
docker compose down
docker compose up -d
docker compose logs|grep "JVM running"| cut -d":" -f4|sort
 Started GatewayApplication in 1.598 seconds (JVM running for 1.776)
 Started RestConfigApplication in 6.676 seconds (JVM running for 7.037)
 Started WebUIApplication in 7.505 seconds (JVM running for 7.934)
 Started WfsApplication in 6.713 seconds (JVM running for 7.016)
 Started WmsApplication in 7.108 seconds (JVM running for 7.454)
```


