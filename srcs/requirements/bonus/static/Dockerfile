FROM debian:bookworm

EXPOSE 7070

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

COPY conf/default /etc/nginx/sites-available/

COPY data/ /var/www/html/

CMD ["nginx", "-g", "daemon off;"]