# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# Copy source code
COPY . .

# Generate the production build
RUN pnpm build

# Stage 2: Production image
FROM node:18-alpine

WORKDIR /app

# Copy the standalone output from the builder stage
COPY --from=builder /app/.next/standalone .
# Copy the public and static assets
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static

# Expose the port the app runs on
EXPOSE 3000

# Set the host to 0.0.0.0 to be accessible from outside the container
ENV HOSTNAME 0.0.0.0

# Start the server
CMD ["node", "server.js"]
