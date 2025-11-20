# Dokploy Deployment Instructions

This document provides detailed instructions for deploying this multi-container application to Dokploy.

## Prerequisites

- Dokploy account with access to create services
- Git repository access
- Basic knowledge of Docker and container services

## Configuration Files

This repository uses a unified Docker Compose configuration for Dokploy deployment:

- `docker-compose.yml` - Main configuration file that defines all services, networks, and volumes

## Step 1: Create a Compose Service in Dokploy

1. In the Dokploy dashboard, create a new service of type "Compose"
2. Give it a meaningful name and description
3. Connect it to this GitHub repository
4. Specify the branch to deploy (typically `main`)
5. Set the "Compose Path" field to `./docker-compose.yml`

## Step 2: Configure Environment Variables

Before deploying, you must set the following environment variables in Dokploy's "Environment" section:

### Database Variables
- `DB_USER` - PostgreSQL user (e.g., postgres)
- `DB_PASSWORD` - Strong password for PostgreSQL
- `DB_NAME` - Database name (e.g., directus_db)

### pgAdmin Variables
- `PGADMIN_DEFAULT_EMAIL` - Admin email for pgAdmin access
- `PGADMIN_DEFAULT_PASSWORD` - Admin password for pgAdmin

### Directus Variables
- `DIRECTUS_KEY` - Encryption key (generate with `openssl rand -hex 32`)
- `DIRECTUS_SECRET` - Secret for Directus (generate with `openssl rand -hex 32`)
- `DIRECTUS_ADMIN_EMAIL` - Admin email for Directus
- `DIRECTUS_ADMIN_PASSWORD` - Admin password for Directus
- `DIRECTUS_PUBLIC_URL` - URL for accessing Directus (for initial deployment, you can use a placeholder like https://directus.yourdomain.com)

### Next.js Variables
- `NEXT_PUBLIC_DIRECTUS_URL` - Same value as DIRECTUS_PUBLIC_URL

### Domain Variables
- `APP_DOMAIN` - Domain for the Next.js app (e.g., app.yourdomain.com)
- `DIRECTUS_DOMAIN` - Domain for Directus (e.g., directus.yourdomain.com)

## Step 3: Deploy

1. Once environment variables are set, initiate the deployment
2. Dokploy will use the `dokploy.config.json` file to understand how to deploy the services
3. The deployment will create the necessary networks, volumes, and containers

## Step 4: Configure Domains

After initial deployment:

1. In the Dokploy dashboard, navigate to the "Domains" section
2. Configure the domains as specified in the environment variables
3. Set up DNS records to point to the Dokploy infrastructure
4. Once domains are properly configured, update the URL variables if needed and redeploy

## Step 5: Verify Deployment

Check that all services are running properly:

1. Access the Next.js app at your configured domain
2. Access Directus CMS at your configured domain
3. Check logs for any errors in the Dokploy dashboard

## Troubleshooting

### Network Issues
If services can't communicate, ensure the `directus_network` is correctly created.

### Database Connection Problems
If Directus cannot connect to the database, verify:
- Database container is running
- Environment variables are correct
- Network configuration is proper

### Missing Volumes
If data doesn't persist, check that volumes are correctly configured in Dokploy.

## Maintenance

### Updates
To update your deployment:
1. Push changes to your GitHub repository
2. Dokploy will automatically deploy if auto-deploy is enabled
3. Or manually trigger a new deployment from the Dokploy dashboard

### Backups
Set up regular backups of your volumes, especially the database volume.

## Additional Resources

- [Dokploy Documentation](https://docs.dokploy.com)
- [Directus Documentation](https://docs.directus.io)
- [Next.js Documentation](https://nextjs.org/docs)