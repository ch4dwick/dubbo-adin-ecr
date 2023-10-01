# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dockerized custom dubb-admin build for pushing into custom po.

# Copied and modified from the official dubbo-admin GitHub.
FROM maven:3.9.4-amazoncorretto-21-al2023
RUN yum install -y unzip wget
RUN mkdir /source && wget https://github.com/apache/dubbo-admin/archive/0.6.0.zip && unzip -q 0.6.0.zip -d /source
WORKDIR /source/dubbo-admin-0.6.0
# You may use a custom application.properties as a default reference if a ConfigMap is not present.
# COPY application.properties dubbo-admin-server/src/main/resources/application.properties
RUN mvn --batch-mode clean package -Dmaven.test.skip=true

FROM amazoncorretto:20.0.2

ENV TINI_VERSION v0.19.0
ADD --chmod=700 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

COPY --from=0 /source/dubbo-admin-0.6.0/dubbo-admin-distribution/target/dubbo-admin-0.6.0.jar /app.jar
COPY --from=0 /source/dubbo-admin-0.6.0/docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Add these manually because, the packaged zip above doesn't have mysql built or included.
ENV MYSQL_JDBC_VERSION 8.1.0
RUN mkdir -p /BOOT-INF/lib
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar /BOOT-INF/lib/mysql.jar
# Include the above file in the spring-boot classpath.
RUN jar -uf0 /app.jar /BOOT-INF/lib
RUN rm -rf /BOOT-INF
ENV JAVA_OPTS ""

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
EXPOSE 8080
