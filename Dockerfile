FROM postgis/postgis:16-3.4
USER root

# Set environment variables (customize these as needed)
ENV POSTGRES_DB=water
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=password

ENV SHAPE_FILE_NAME=water_polygons.shp
ENV TABLE_NAME=regions
ENV GEOMETRY_COLUMN_NAME=geom
ENV WATER_TYPE_COLUMN_NAME=waterType

EXPOSE 5432

RUN apt-get update && apt-get install -y nano bash bash-completion curl unzip postgis && rm -rf /var/lib/apt/lists/*

# install bash and bash-completion
# we need to symlink bash to sh, because the docker desktop CLi will auto run the basic shell
RUN echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
RUN ln -sf /bin/bash /bin/sh


COPY . /

WORKDIR /data
#RUN unzip -j water-polygons-split-4326.zip -d /data
#RUN rm water-polygons-split-4326.zip
