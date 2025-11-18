FROM debian:bookworm

EXPOSE 443

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

RUN mkdir -p /etc/ssl/certs /etc/ssl/private && \
	chmod 755 /etc/ssl/certs && \
	chmod 700 /etc/ssl/private

ARG COUNTRY STATE LOCALITY ORGANIZATION UNIT COMMON_NAME

RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
	-out /etc/ssl/certs/server.crt \
	-keyout /etc/ssl/private/server.key \
	-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=${COMMON_NAME}"

RUN chmod 644 /etc/ssl/certs/server.crt && \
	chmod 600 /etc/ssl/private/server.key

COPY conf/default /etc/nginx/sites-available/

CMD ["nginx", "-g", "daemon off;"]
