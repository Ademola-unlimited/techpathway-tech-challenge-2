
# Use Node.js 24 LTS as the base image
FROM node:24-alpine

# Set the application working directory
WORKDIR /app

# Copy dependency configuration files
COPY package*.json ./

# Install application dependencies
RUN npm ci

# Copy the backend application source code
COPY . .

# Document the port used by Express
EXPOSE 8080

# Start the backend application
CMD ["npm", "start"]
