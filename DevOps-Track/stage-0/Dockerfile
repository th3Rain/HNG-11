# Use the official NGINX image from the Docker Hub
FROM nginx:latest

# Copy your static website files to the NGINX web root directory
COPY . /usr/share/nginx/html

# Expose port 80 to the host
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]