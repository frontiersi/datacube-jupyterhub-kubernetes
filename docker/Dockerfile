FROM opendatacube/jupyterhub

RUN apt-get update && apt-get install -y git

RUN pip3 install nbgitpuller geopandas scikit-image fiona ipyleaflet geopy jupyterlab \
    hdmedians rasterstats seaborn sklearn

ENV GDAL_DATA=/usr/share/gdal/2.3/

RUN jupyter nbextension enable --py --sys-prefix ipyleaflet \
    && jupyter labextension install jupyter-leaflet \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager
