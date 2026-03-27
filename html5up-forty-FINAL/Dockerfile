FROM nginx:1.25-alpine

LABEL maintainer="mamansamb100-commits"
LABEL description="html5up-forty static site"

RUN rm -rf /usr/share/nginx/html/*

COPY assets/   /usr/share/nginx/html/assets/
COPY images/   /usr/share/nginx/html/images/
COPY *.html    /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
