#!/bin/bash

declare -a cog_names=( \
	"land_shallow_topo_21600_NE_cog" \
	"land_shallow_topo_21600_NW_cog" \
	"land_shallow_topo_21600_SE_cog" \
	"land_shallow_topo_21600_SW_cog" \
)

baseurl="http://localhost:9090/geoserver/cloud"
resturl="$baseurl/rest"
credentials="admin:geoserver"
workspace=cog

echo ">>>>>>>>>>>>>>>> Delete and re-create workspace $workspace <<<<<<<<<<<<<<<<<"
curl --silent -u $credentials -XDELETE "$resturl/workspaces/$workspace?recurse=true"
curl -i -u $credentials -XPOST \
	-H "Content-type: text/xml" \
	-d "<workspace><name>$workspace</name></workspace>" \
	"$resturl/workspaces"

for cog in "${cog_names[@]}"
do

 echo
 echo ">>>>>>>>>>>>>>>> Creating COG for $cog <<<<<<<<<<<<<<<<<"

 curl --silent -u $credentials "$resturl/workspaces/$workspace/coveragestores" \
  -H "Content-Type: application/xml" \
  -d "<coverageStore>
	 <name>$cog</name>
	 <type>GeoTIFF</type>
	 <enabled>true</enabled>
	 <workspace><name>${workspace}</name></workspace>
	 <url>cog://https://s3-us-east-1.amazonaws.com/test-data-cog-public/private/$cog.tif</url>
	 <metadata>
       <entry key=\"CogSettings.Key\"><cogSettings><rangeReaderSettings>S3</rangeReaderSettings></cogSettings></entry>
	 </metadata>
    </coverageStore>"
 
 curl --silent -u $credentials "$resturl/workspaces/$workspace/coveragestores/$cog/coverages" \
  -H "Content-Type: application/xml" \
  -d "<coverage><name>$cog</name><nativeName>$cog</nativeName></coverage>"

done

lg="<layerGroup>
  <name>land_shallow_topo_21600</name>
  <title>Land Shallow Topo 21600</title>
  <mode>SINGLE</mode>
  <enabled>true</enabled>
  <advertised>true</advertised>
  <publishables>"

for cog in "${cog_names[@]}"
do 
  lg="$lg
    <published type=\"layer\">$workspace:$cog</published>"
done

lg="$lg
   </publishables>
   <styles>"

for cog in "${cog_names[@]}";do lg="$lg<style><name>raster</name></style>";done

lg="$lg
  </styles>
  <bounds><minx>-180</minx><maxx>180</maxx><miny>-90</miny><maxy>90</maxy><crs>EPSG:4326</crs></bounds>
  </layerGroup>"

echo
echo ">>>>>>>>>>>>>>>> Creating LayerGroup <<<<<<<<<<<<<<<<<"

curl --silent -u $credentials "$resturl/layergroups" \
 -H "Content-Type: application/xml" \
 -d "$lg"
