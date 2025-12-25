# Firebase Password Reset Email Template Setup

## Quick Setup Guide (Gujarati: ઝડપી સેટઅપ ગાઈડ)

### Step 1: Open Firebase Console
Go to: https://console.firebase.google.com/project/surveyor-90246/authentication/emails

### Step 2: Select "Password reset" Template
Click on "Password reset" in the list of email templates.

### Step 3: Click Edit (Pencil Icon)
Click the pencil/edit icon to modify the template.

### Step 4: Configure the Template

#### Subject Line:
```
Reset your Surveyor password
```

#### Sender Name:
```
Surveyor App
```

#### Message (Simple Version):
If Firebase doesn't support full HTML, use this simple version:

```
Hello %DISPLAY_NAME%,

We received a request to reset the password for your Surveyor account (%EMAIL%).

Click the link below to reset your password:
%LINK%

This link will expire in 1 hour for security reasons.

⚠️ If you didn't request this password reset, you can safely ignore this email. Your password will remain unchanged.

---
Surveyor App
Survey Management Made Simple

This is an automated message. Please do not reply to this email.
```

### Step 5: Save
Click "Save" to apply the changes.

---

## Full HTML Template

For the full HTML template with modern design, see:
`password_reset_email.html` in this folder.

**Note:** Firebase's email template editor has limited HTML support. If the full HTML doesn't render correctly, use the simple version above.

---

## Available Placeholders

| Placeholder | Description |
|-------------|-------------|
| `%DISPLAY_NAME%` | User's display name |
| `%EMAIL%` | User's email address |
| `%LINK%` | Password reset link (Required!) |
| `%APP_NAME%` | Your app name from Firebase settings |

---

## Testing

After saving the template:
1. Open the Surveyor app
2. Go to Login → "Forgot Password?"
3. Enter your email
4. Check your inbox for the new email design
5. Verify the reset link works correctly

---

## Troubleshooting

### Email not arriving?
- Check spam/junk folder
- Verify email address is correct
- Check Firebase Console → Authentication → Users to confirm user exists

### Link not working?
- Make sure `%LINK%` placeholder is included in template
- Check if link has expired (1 hour limit)
- Try requesting a new reset link

### Design not showing?
- Some email clients block images/styles
- Use the simple text version for better compatibility
