# ☁️ AWS Static Portfolio Deployment


**Live Site:** https://manueldelahoz.com


![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![CloudFront](https://img.shields.io/badge/CDN-CloudFront-blue)
![S3](https://img.shields.io/badge/Storage-S3-yellow)
![Route53](https://img.shields.io/badge/DNS-Route53-green)
![Status](https://img.shields.io/badge/Status-Live-success)

---

## Overview

This project demonstrates how to deploy a **static web application** on AWS using production-oriented practices.

The application is built with a static export workflow and deployed using:

* Amazon S3 (object storage & hosting)
* CloudFront (CDN)
* Route 53 (DNS)
* AWS Certificate Manager (SSL/TLS)

---

## Architecture

<img width="1346" height="749" alt="image" src="https://github.com/user-attachments/assets/5fbdb57c-a3eb-42f0-b83f-6a9b4e4cd1e3" />


---

## Deployment Workflow

```text
Build → Upload → CDN → Domain → HTTPS
```

---

## Step-by-Step Deployment

### 1. Application Development

* Create your application (e.g., Next.js static export)
* Test locally:

```bash
pnpm dev
```

---

### 2. Build Application

```bash
pnpm build
```

This generates:

```text
/out
```

---

### 3. Create S3 Bucket

* Bucket name = your domain (e.g. `manueldelahoz.com`)
* Enable **Static Website Hosting**
* Temporarily allow **public access**
* Add policy:

```json
{
  "Effect": "Allow",
  "Principal": "*",
  "Action": "s3:GetObject",
  "Resource": "BUCKET_ARN/*"
}
```

---

### 4. Upload Website

```bash
aws s3 sync out/ s3://BUCKET_NAME --delete
```

Verify using the S3 website endpoint.

---

### 5. Secure the Bucket

After verification:

* Disable public access
* Remove public policy

---

### 6. Create CloudFront Distribution

* Origin: S3 bucket
* Use **Origin Access Control (OAC)**

#### ⚠️ Critical Configuration

* **Origin Path → MUST be EMPTY**
* **Distribution Default Root Object → `index.html`**

> Misconfiguring Origin Path (e.g. `/index.html`) will cause `AccessDenied`.

---

### 7. Update Bucket Policy for CloudFront

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "cloudfront.amazonaws.com"
  },
  "Action": "s3:GetObject",
  "Resource": "BUCKET_ARN/*",
  "Condition": {
    "StringEquals": {
      "AWS:SourceArn": "DISTRIBUTION_ARN"
    }
  }
}
```

---

### 8. Enable Versioning & Lifecycle

Enable:

* Versioning

My lifecycle preferences:

* Delete noncurrent versions after 30 days
* Delete expired delete markers
* Abort incomplete multipart uploads after 7 days

---

### 9. Register Domain

Register your domain on Route 53 (e.g. `manueldelahoz.com`) associated cost: 15 USD.
It is also recommended to register the subdomains using *.manueldelahoz.com

---

### 10. Create SSL Certificate

In AWS Certificate Manager:

1. Request public certificate
2. Validate via DNS (Route 53)
3. Wait until status = **Issued**

---

### 11. Attach Domain to CloudFront distribution

* Add Alternate Domain Name (CNAME):

```text
manueldelahoz.com
```

* Attach SSL certificate

---

### 12. Configure Route 53

Create record:

* Type: A
* Name: `manueldelahoz.com`
* Alias → CloudFront distribution

---

## Result

After propagation (~5 minutes):

Your website is live with HTTPS enabled.

---

## 🌍 Optional: www Redirect

### 1. Create S3 bucket

```text
www.manueldelahoz.com
```

Enable:

* Static website hosting
* Redirect to:

```text
https://manueldelahoz.com
```

---

### 2. Route 53 Record

* Type: A
* Name: `www`
* Alias → redirect to newly created bucket

---

## Optional: Deployment Automation

### `deploy.ps1`

```powershell
$BUCKET="BUCKET_NAME"
$DISTRIBUTION_ID="DISTRIBUTION_ID"

pnpm build
aws s3 sync out/ s3://$BUCKET --delete

aws cloudfront create-invalidation `
  --distribution-id $DISTRIBUTION_ID `
  --paths "/*"
```

---

## Deployment Flow

```text
Edit → Build → Upload → Invalidate → Live
```

---

## Key Learnings

* CloudFront origin configuration is critical
* Incorrect Origin Path causes `AccessDenied`
* Cache invalidation is required after updates
* Static hosting on AWS is scalable and cost-efficient
* DNS + SSL integration is essential for production

---

## 🧪 Troubleshooting

### ❌ AccessDenied (CloudFront)

✔️ Fix:

* Ensure Origin Path is empty
* Verify OAC is attached
* Check bucket policy

---

### ❌ Styles not loading

✔️ Fix:

* Ensure `_next/` exists in S3
* Run `pnpm build`
* Invalidate CloudFront cache

---

### ❌ Changes not visible

✔️ Fix:

* Invalidate cache:

```text
/*
```

* Clear browser cache

---

### ❌ Favicon not updating

✔️ Fix:

* Browser cache issue (Ctrl + Shift + R to reload the page, ignoring cached content)
* Or use incognito to verify

---

## Best Practices Implemented

* Private S3 bucket with CloudFront access
* HTTPS via ACM
* CDN caching with invalidation strategy
* Lifecycle policy for cost control
* Versioning for rollback capability
* Automated deployment script

---

## Author

**Manuel De La Hoz**
Virtualization & Infrastructure Engineer

