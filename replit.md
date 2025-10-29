# Northcrest Holdings - Northcrest Holdings Investment Platform

## Overview

Northcrest Holdings is a web-based platform that enables fractional ownership of real estate properties. Users can invest in premium properties by purchasing shares, track their portfolio performance, receive profit distributions, and manage deposits/withdrawals. The platform features role-based access control with admin capabilities for property management, deposit/withdrawal approvals, and profit distribution.

## Recent Changes (October 23, 2025)

- **Transaction History**: Added comprehensive transaction history view showing all user transactions including manual transactions, deposits, withdrawals, property purchases/sales, and profit distributions
- **Personalized Greetings**: Implemented timezone-aware greetings (Good morning/afternoon/evening) that display user's name on dashboard
- **Password Reset**: Added forgot password functionality to login page, allowing users to reset passwords via email link
- **Real-time Updates**: Enhanced real-time subscriptions to include transaction history updates across all transaction types

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture

**Framework**: React 18 with TypeScript, built using Vite for fast development and optimized builds.

**UI Component System**: Utilizes shadcn/ui components built on Radix UI primitives, providing accessible and customizable components. The design system is centralized in `src/index.css` with HSL color definitions for consistent theming.

**Styling**: TailwindCSS with custom configuration supporting dark mode via `next-themes`. All colors are defined using HSL values for theme flexibility.

**State Management**: React Query (@tanstack/react-query) for server state management, caching, and real-time data synchronization. Local state is managed through React hooks.

**Routing**: React Router v6 for client-side navigation with protected routes via AuthGuard component.

**Form Handling**: React Hook Form with Zod resolvers for type-safe form validation.

**Real-time Updates**: Supabase real-time subscriptions for properties, deposits, withdrawals, transactions, manual transactions, and distribution payments to keep UI synchronized across users.

### Backend Architecture

**Backend-as-a-Service**: Supabase handles authentication, database, and real-time functionality.

**Authentication**: Supabase Auth manages user registration, login, password reset, and session management. Email/password authentication is implemented with server-side session validation.

**Authorization**: Role-based access control (RBAC) implemented through `user_roles` table. Admin privileges control access to property management, user management, and financial operations.

### Data Storage

**Database**: PostgreSQL via Supabase with the following core schema:

- **profiles**: User profile information (full_name, username)
- **properties**: Property listings with valuation, shares, pricing, and status
- **user_holdings**: Junction table tracking user share ownership per property
- **portfolios**: Aggregated user portfolio metrics (total_value, total_invested, total_returns)
- **transactions**: Investment transaction history (property buy/sell)
- **manual_transactions**: Admin-created transaction records for adjustments
- **deposits**: User deposit requests with approval workflow
- **withdrawals**: User withdrawal requests with admin approval
- **distribution_payments**: Individual profit distribution payments to shareholders
- **distributions**: Property-level profit distribution records
- **profit_distributions**: Records of profit payouts to shareholders
- **payment_settings**: Configuration for payment methods
- **crypto_wallets**: Cryptocurrency wallet addresses for transactions
- **user_roles**: Role assignments for access control
- **user_withdrawal_settings**: Per-user withdrawal configuration and restrictions

**File Storage**: Property images stored via URL references (external hosting or Supabase Storage).

### Authentication & Authorization

**Authentication Flow**: 
- Email/password signup creates user account and profile
- Session-based authentication with JWT tokens
- Password reset via email link
- AuthGuard component protects routes requiring authentication

**Authorization Strategy**:
- Role checking via `user_roles` table queries
- `useRole` hook provides admin status throughout application
- Admin-only routes and components conditionally rendered based on role
- Operations like property creation, deposit approval, and profit distribution require admin role

### Real-time Features

**Supabase Channels**: Real-time subscriptions for:
- Property updates (shares available, status changes)
- Deposit status changes
- Withdrawal status changes
- Transaction history updates (all transaction types)
- Manual transaction changes
- Distribution payment notifications

This ensures users see immediate updates without manual refresh.

### Admin Capabilities

Administrators have access to:
- Property CRUD operations (create, edit, delete properties)
- User role management (grant/revoke admin privileges)
- Deposit approval workflow with receipt verification
- Withdrawal approval with custom notes
- Profit distribution across property shareholders
- Manual transaction creation for adjustments
- Payment method configuration (traditional and crypto)
- Per-user withdrawal settings and restrictions

### User Features

Standard users can:
- Browse available properties with filtering
- Purchase property shares using portfolio balance
- View portfolio holdings and performance metrics
- Submit deposit requests with payment proof
- Request withdrawals to configured payment methods
- View comprehensive transaction history (manual transactions, deposits, withdrawals, property purchases, and profit distributions)
- Receive profit distributions from property holdings
- See personalized time-based greetings (Good morning/afternoon/evening) using browser timezone
- Reset forgotten passwords via email link

## External Dependencies

### Core Services

**Supabase** (@supabase/supabase-js v2.76.1): Provides authentication, PostgreSQL database, real-time subscriptions, and optional file storage. Acts as the complete backend infrastructure.

### UI & Styling

**Radix UI**: Comprehensive set of accessible component primitives including dialogs, dropdowns, popovers, tabs, and form controls.

**TailwindCSS**: Utility-first CSS framework for styling with PostCSS processing.

**next-themes**: Theme management supporting light/dark mode with system preference detection.

**class-variance-authority**: Type-safe variant management for component styles.

**lucide-react**: Icon library providing consistent iconography throughout the application.

### Data Management

**@tanstack/react-query**: Server state management with automatic caching, background refetching, and optimistic updates.

**react-hook-form**: Performant form library with validation support.

**@hookform/resolvers**: Validation resolver adapters for form validation schemas.

**zod**: TypeScript-first schema validation (implied by resolvers usage).

### Additional Libraries

**date-fns**: Date manipulation and formatting utilities.

**embla-carousel-react**: Carousel/slider component for image galleries.

**cmdk**: Command palette component for keyboard-driven navigation.

**sonner**: Toast notification system for user feedback.

**vaul**: Drawer component library for mobile-friendly overlays.

### Development Tools

**Vite**: Build tool providing fast HMR and optimized production builds.

**TypeScript**: Type safety throughout the application with relaxed compiler settings for rapid development.

**ESLint**: Code linting with React-specific rules and TypeScript support.

**lovable-tagger**: Development plugin for component identification (development mode only).