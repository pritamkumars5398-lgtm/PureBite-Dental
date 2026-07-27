#!/bin/bash
set -e

ENVIRONMENTS=("production" "preview" "development")

for env in "${ENVIRONMENTS[@]}"; do
  echo "Adding environment variables for: $env..."
  
  # For ENVIRONMENT variable, use production for production env, development for others
  if [ "$env" = "production" ]; then
    ENV_VAL="production"
  else
    ENV_VAL="development"
  fi

  vercel env add DATABASE_URL "$env" --value "postgresql+asyncpg://neondb_owner:npg_UKLeREGcuJ40@ep-snowy-star-aixtxi7u.c-4.us-east-1.aws.neon.tech/neondb?ssl=require" --yes --force
  vercel env add SECRET_KEY "$env" --value "dev-secret-key-min-32-chars-long-1234567890" --yes --force
  vercel env add BUDGET_PUBLIC_SECRET_KEY "$env" --value "dev-budget-secret-key-min-32-characters-1234567" --yes --force
  vercel env add ENVIRONMENT "$env" --value "$ENV_VAL" --yes --force
  vercel env add STORAGE_BACKEND "$env" --value "cloudinary" --yes --force
  vercel env add CLOUDINARY_CLOUD_NAME "$env" --value "j32ielua" --yes --force
  vercel env add CLOUDINARY_API_KEY "$env" --value "937638828526347" --yes --force
  vercel env add CLOUDINARY_API_SECRET "$env" --value "z-lznjqfl72J2lNR3o-PcG_8uwo" --yes --force
done

echo "Vercel environment variables set successfully!"
