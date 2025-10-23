# Controlla Website - GitHub Pages

This folder contains the website files for Controlla, hosted via GitHub Pages.

## Files

- `index.html` - Landing page
- `privacy.html` - Privacy Policy (required for App Store)
- `terms.html` - Terms of Use (required for App Store)

## Setup GitHub Pages

1. **Push this repository to GitHub:**
   ```bash
   # In your AirType directory
   git remote add origin https://github.com/YOUR_USERNAME/controlla.git
   git push -u origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your GitHub repository
   - Click **Settings** → **Pages**
   - Under "Source", select: **Deploy from a branch**
   - Branch: **main**
   - Folder: **/docs**
   - Click **Save**

3. **Your site will be live at:**
   ```
   https://YOUR_USERNAME.github.io/controlla/
   ```

4. **Specific pages:**
   ```
   Privacy: https://YOUR_USERNAME.github.io/controlla/privacy.html
   Terms:   https://YOUR_USERNAME.github.io/controlla/terms.html
   ```

## Custom Domain (Optional)

If you want to use `sundai.us/controlla/*`:

1. **In your domain DNS settings (sundai.us):**
   - Add a CNAME record:
     - Name: `controlla` (or subdomain you want)
     - Value: `YOUR_USERNAME.github.io`

2. **In GitHub Pages settings:**
   - Custom domain: `controlla.sundai.us`
   - Enable "Enforce HTTPS"

3. **Update PaywallView.swift URLs** if needed

## URLs Used in App

The app currently links to:
- Privacy Policy: `https://sundai.us/controlla/privacy`
- Terms of Use: `https://sundai.us/controlla/terms`

Make sure these URLs are accessible before submitting to App Store!

## Testing Locally

Open the HTML files directly in your browser to preview:
```bash
open docs/index.html
open docs/privacy.html
open docs/terms.html
```
