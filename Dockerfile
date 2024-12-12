# Use an official Nginx image as a base
FROM nginx:alpine

# Copy your HTML files into the Nginx container
COPY ./ /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]
