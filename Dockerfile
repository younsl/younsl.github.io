FROM alpine:3.21

# Install Zola
RUN apk add --no-cache zola

WORKDIR /app

# Expose port for Zola server
EXPOSE 1111

# Serve the site with live reload
CMD ["zola", "serve", "--interface", "0.0.0.0", "--port", "1111"]
