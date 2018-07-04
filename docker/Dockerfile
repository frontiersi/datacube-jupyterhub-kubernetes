from opendatacube/jupyterhub

RUN apt-get update && apt-get install -y git

RUN pip3 install nbgitpuller geopandas scikit-image fiona ipyleaflet

RUN jupyter nbextension enable --py --sys-prefix ipyleaflet
