$ErrorActionPreference = "Stop"

$BUCKET="manueldelahoz.com"
$DISTRIBUTION_ID="EEC29ECTPVHLV"

Write-Host "Building project..."
pnpm build

Write-Host "Deploying to S3..."
aws s3 sync out/ s3://$BUCKET --delete

Write-Host "Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"

Write-Host "Deploy complete."
