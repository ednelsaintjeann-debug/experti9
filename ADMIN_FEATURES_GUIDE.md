# Admin Features Implementation Guide

This document outlines all the new admin features that have been added to your property investment platform.

## Features Overview

### 1. User Activity Tracking
- **Real-time online status** - See which users are currently online (active in last 5 minutes)
- **Activity statistics** - Total users, online users, and users active in last 24 hours
- **Last seen tracking** - Automatically tracks when users were last active
- **Activity dashboard** - New "Activity" tab in admin panel showing all user activity

### 2. Manual Transaction Management
- **View all transactions** - See all manual transactions with user details
- **Delete transactions** - Remove any manual transaction entered by admin
- **Transaction history** - Complete audit trail of all manual adjustments
- **Type filtering** - Transactions categorized by type (deposit, withdrawal, profit, fee, adjustment)

### 3. Enhanced Balance Management
- **Edit cash balance** - Directly set any user's cash balance
- **Edit portfolio value** - Directly set any user's total equity value
- **Visual overview** - See current balances before making changes
- **Audit trail** - All changes are logged in manual_transactions table
- **Reason tracking** - Require description for all balance changes

### 4. User Account Management
- **Disable user accounts** - Prevent users from accessing their accounts
- **Custom error messages** - Set personalized messages shown to disabled users
- **Enable accounts** - Re-enable previously disabled accounts
- **Real-time enforcement** - Disabled users are logged out immediately
- **Account status tracking** - See which accounts are active vs disabled

### 5. Currency Management
- **Multi-currency support** - Support for 30+ global currencies
- **Currency activation** - Enable/disable which currencies are available
- **Default currency** - Set platform-wide default currency
- **Exchange rates** - Manage exchange rates for all currencies
- **User currency assignment** - Assign specific currency to any user
- **Active currency filtering** - Only show active currencies to users

### 6. User Role Management (Enhanced)
- **View all user roles** - See admin and regular users
- **Modify roles** - Grant or revoke admin privileges
- **Withdrawal settings** - Configure withdrawal permissions per user

## Navigation

All new features are accessible from the Admin Dashboard in dedicated tabs:

1. **Activity** - User activity tracking and statistics
2. **Manual Txns** - Manual transaction creation and history
3. **Enhanced Balances** - Advanced balance editing for users
4. **Accounts** - User account enable/disable management
5. **Currency** - Currency management and user assignment
6. **User Roles** - User role and permission management

## Database Migration

Before using these features, you need to apply the database migration:

### Migration File Location
`supabase/migrations/20251024000000_admin_features.sql`

### What the Migration Adds
- `is_disabled` - Boolean flag for account status
- `disabled_message` - Custom error message for disabled users
- `last_seen` - Timestamp of last user activity
- `currency` - User's preferred currency (default: USD)
- `currencies` table - Stores all supported currencies
- RLS policies for secure admin operations

### How to Apply the Migration

1. **Using Supabase CLI** (Recommended):
   ```bash
   supabase db push
   ```

2. **Manual Application**:
   - Open your Supabase dashboard
   - Go to SQL Editor
   - Copy and paste the contents of the migration file
   - Execute the SQL

## Security Features

### Row Level Security (RLS)
All new operations are protected by RLS policies:

- ✅ Only admins can disable/enable user accounts
- ✅ Only admins can delete manual transactions
- ✅ Only admins can edit other users' balances
- ✅ Only admins can manage currencies
- ✅ Users can only update their own `last_seen` timestamp
- ✅ All operations are logged for audit purposes

### Automatic Disabled User Handling
- Disabled users are automatically logged out
- Real-time subscription monitors account status
- Custom error messages guide users to support
- No access granted until account is re-enabled

### Activity Tracking Privacy
- Only last_seen timestamps are tracked
- No detailed action logging (privacy-focused)
- Admins can see online status and last activity time
- Updates happen automatically in the background

## Supported Currencies

The platform supports 30 major world currencies:

- USD (US Dollar) - Default
- EUR (Euro)
- GBP (British Pound)
- JPY (Japanese Yen)
- CAD (Canadian Dollar)
- AUD (Australian Dollar)
- CHF (Swiss Franc)
- CNY (Chinese Yuan)
- INR (Indian Rupee)
- MXN (Mexican Peso)
- BRL (Brazilian Real)
- ZAR (South African Rand)
- And 18 more...

### Currency Features
- Activate/deactivate any currency
- Set default currency for new users
- Update exchange rates in real-time
- Assign different currencies to different users
- Only active currencies are visible to users

## Usage Examples

### Example 1: Disabling a User Account

1. Navigate to **Admin Dashboard** > **Accounts** tab
2. Find the user in the list
3. Click the "Disable" button
4. Enter a custom message (e.g., "Your account is under review. Please contact support@example.com")
5. Click "Disable Account"

Result: User is immediately logged out and sees your custom message on next login attempt.

### Example 2: Editing User Balance

1. Navigate to **Admin Dashboard** > **Enhanced Balances** tab
2. Select the user from dropdown
3. Switch to "Edit Balances" tab
4. Update cash balance and/or portfolio value
5. Enter a reason (e.g., "Correction for duplicate transaction")
6. Click "Update Balances"

Result: User's balance is updated and a manual transaction record is created for audit trail.

### Example 3: Managing Currencies

1. Navigate to **Admin Dashboard** > **Currency** tab
2. Toggle currencies on/off using the switches
3. Set a currency as default by clicking "Set Default"
4. Update exchange rates by editing the rate field
5. Assign currency to specific user in the bottom section

Result: Users will see updated currency options and exchange rates.

### Example 4: Deleting a Manual Transaction

1. Navigate to **Admin Dashboard** > **Manual Txns** tab
2. Scroll down to view transaction history
3. Find the transaction to delete
4. Click the trash icon
5. Confirm deletion in the dialog

Result: Transaction is removed from history (Note: This does NOT reverse the balance changes).

## Best Practices

### Account Disabling
- Always provide clear, helpful error messages
- Include contact information for support
- Document reason for disabling in internal notes
- Review disabled accounts regularly

### Balance Adjustments
- Always provide detailed descriptions
- Document external ticket/case numbers
- Review adjustments with another team member
- Keep audit trail for compliance

### Currency Management
- Update exchange rates regularly
- Test currency before making it default
- Communicate currency changes to users
- Keep at least one currency active

### Transaction Management
- Review manual transactions regularly
- Delete only duplicate or erroneous entries
- Understand that deletion doesn't reverse balance changes
- Use balance adjustments to correct balances if needed

## Troubleshooting

### Users Not Showing as Online
- Ensure migration has been applied
- Check that `last_seen` field exists in profiles table
- Verify user has logged in after migration
- Check browser console for errors

### Currency Changes Not Saving
- Verify you have admin permissions
- Check that migration was applied successfully
- Ensure RLS policies are in place
- Check for browser console errors

### Disabled Users Can Still Log In
- Verify real-time subscription is working
- Check that `is_disabled` field exists
- Ensure `useUserStatus` hook is in DashboardLayout
- Check browser console for errors

### Balance Updates Not Working
- Confirm admin role is assigned
- Verify RLS policies were created
- Check that portfolios table has proper permissions
- Review error messages in toast notifications

## API Reference

### Custom Hooks

#### `useUserStatus()`
Monitors user account status and logs out disabled users.

```typescript
const { isDisabled, disabledMessage, loading } = useUserStatus();
```

#### `useActivityTracker()`
Automatically updates user's last_seen timestamp.

```typescript
useActivityTracker(); // No return value, runs automatically
```

### Database Functions

#### `update_last_seen()`
Manual function to update last seen (though automatic tracking is preferred).

```sql
SELECT public.update_last_seen();
```

#### `is_user_enabled()`
Check if current user's account is enabled.

```sql
SELECT public.is_user_enabled();
```

## Support

For issues or questions about these features:

1. Check this documentation first
2. Review the migration file for database schema
3. Check component code in `src/components/admin/`
4. Review hooks in `src/hooks/`
5. Check Supabase logs for RLS errors

## Future Enhancements

Potential improvements for consideration:

- Email notifications when accounts are disabled
- Scheduled re-enabling of accounts
- Bulk currency assignments
- Export transaction history
- Advanced user filtering
- Custom activity reports
- Multi-factor authentication for disabled accounts
- Temporary account suspensions with auto-enable dates
