# Use the official nginx base image
FROM nginx:1.25.1

# Copy the nginx.conf file to the appropriate directory in the Docker container
COPY nginx.conf /etc/nginx/conf.d/default.conf 

# Copy the index.html file into the container
COPY . /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80
