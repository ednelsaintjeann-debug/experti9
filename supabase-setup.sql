-- ==========================================
-- SUPABASE DATABASE SETUP
-- Run this in your Supabase SQL Editor
-- ==========================================

-- Create enum for app roles
CREATE TYPE public.app_role AS ENUM ('user', 'admin');

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  role app_role NOT NULL DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create properties table
CREATE TABLE public.properties (
  property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  type TEXT,
  description TEXT,
  image_url TEXT,
  total_shares INTEGER NOT NULL DEFAULT 100000,
  shares_available INTEGER NOT NULL,
  price_per_share NUMERIC(12,2) NOT NULL,
  current_valuation NUMERIC(14,2) NOT NULL,
  target_yield NUMERIC(5,2),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'suspended')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

-- Create portfolios table
CREATE TABLE public.portfolios (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  total_equity_value NUMERIC(14,2) NOT NULL DEFAULT 0,
  cash_balance NUMERIC(14,2) NOT NULL DEFAULT 10000,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;

-- Create transactions table
CREATE TABLE public.transactions (
  transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  property_id UUID REFERENCES public.properties(property_id) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('buy', 'sell')),
  share_quantity INTEGER NOT NULL,
  price_at_time NUMERIC(12,2) NOT NULL,
  total_amount NUMERIC(14,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Create user_holdings table
CREATE TABLE public.user_holdings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  property_id UUID REFERENCES public.properties(property_id) NOT NULL,
  shares_held INTEGER NOT NULL DEFAULT 0,
  average_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, property_id)
);

ALTER TABLE public.user_holdings ENABLE ROW LEVEL SECURITY;

-- Create user_roles table
CREATE TABLE public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  role app_role not null default 'user',
  created_at timestamp with time zone default now(),
  unique (user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Create deposits table
CREATE TABLE public.deposits (
  deposit_id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(14,2) NOT NULL CHECK (amount > 0),
  payment_method TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  receipt_url TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  approved_at TIMESTAMP WITH TIME ZONE,
  approved_by UUID REFERENCES auth.users(id),
  admin_notes TEXT
);

ALTER TABLE public.deposits ENABLE ROW LEVEL SECURITY;

-- Create distributions table
CREATE TABLE public.distributions (
  distribution_id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  property_id UUID NOT NULL REFERENCES public.properties(property_id) ON DELETE CASCADE,
  total_amount NUMERIC(14,2) NOT NULL CHECK (total_amount > 0),
  distribution_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.distributions ENABLE ROW LEVEL SECURITY;

-- Create distribution_payments table
CREATE TABLE public.distribution_payments (
  payment_id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  distribution_id UUID NOT NULL REFERENCES public.distributions(distribution_id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
  shares_held INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.distribution_payments ENABLE ROW LEVEL SECURITY;

-- Create manual_transactions table
CREATE TABLE public.manual_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(14,2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('deposit', 'withdrawal', 'profit', 'fee', 'adjustment')),
  description TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.manual_transactions ENABLE ROW LEVEL SECURITY;

-- Create payment_settings table
CREATE TABLE public.payment_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_method TEXT NOT NULL UNIQUE CHECK (payment_method IN ('cashapp', 'venmo', 'paypal')),
  payment_address TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_available BOOLEAN NOT NULL DEFAULT true,
  receipt_required BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.payment_settings ENABLE ROW LEVEL SECURITY;

-- Create crypto_wallets table
CREATE TABLE public.crypto_wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  currency TEXT NOT NULL,
  wallet_address TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_available BOOLEAN NOT NULL DEFAULT true,
  receipt_required BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.crypto_wallets ENABLE ROW LEVEL SECURITY;

-- Create withdrawals table
CREATE TABLE public.withdrawals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(14,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'completed')),
  withdrawal_method TEXT CHECK (withdrawal_method IN ('cashapp', 'venmo', 'paypal', 'bank')),
  withdrawal_details JSONB,
  admin_notes TEXT,
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.withdrawals ENABLE ROW LEVEL SECURITY;

-- Create user_withdrawal_settings table
CREATE TABLE public.user_withdrawal_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  withdrawal_enabled BOOLEAN NOT NULL DEFAULT false,
  custom_error_message TEXT,
  allow_pending BOOLEAN NOT NULL DEFAULT true,
  enabled_methods TEXT[] DEFAULT ARRAY['cashapp', 'venmo', 'paypal', 'bank'],
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.user_withdrawal_settings ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- FUNCTIONS
-- ==========================================

-- Function to check admin role
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = auth.uid()
      AND role = 'admin'
  )
$$;

-- Trigger function to create profile and portfolio on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  
  INSERT INTO public.portfolios (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to assign 'user' role on signup
CREATE OR REPLACE FUNCTION public.handle_new_user_role()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_roles (user_id, role)
  VALUES (new.id, 'user');
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created_role
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user_role();

-- Function to process transactions
CREATE OR REPLACE FUNCTION public.process_transaction()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_shares INTEGER;
  current_cash NUMERIC(14,2);
  current_user_shares INTEGER;
BEGIN
  IF NEW.type = 'buy' THEN
    SELECT shares_available INTO current_shares 
    FROM public.properties 
    WHERE property_id = NEW.property_id 
    FOR UPDATE;
    
    IF current_shares < NEW.share_quantity THEN
      RAISE EXCEPTION 'Insufficient shares available';
    END IF;
    
    SELECT cash_balance INTO current_cash 
    FROM public.portfolios 
    WHERE user_id = NEW.user_id 
    FOR UPDATE;
    
    IF current_cash < NEW.total_amount THEN
      RAISE EXCEPTION 'Insufficient cash balance';
    END IF;
    
    UPDATE public.properties 
    SET shares_available = shares_available - NEW.share_quantity,
        updated_at = NOW()
    WHERE property_id = NEW.property_id;
    
    INSERT INTO public.user_holdings (user_id, property_id, shares_held, average_price, updated_at)
    VALUES (NEW.user_id, NEW.property_id, NEW.share_quantity, NEW.price_at_time, NOW())
    ON CONFLICT (user_id, property_id) 
    DO UPDATE SET
      average_price = ((user_holdings.average_price * user_holdings.shares_held) + (NEW.price_at_time * NEW.share_quantity)) / (user_holdings.shares_held + NEW.share_quantity),
      shares_held = user_holdings.shares_held + NEW.share_quantity,
      updated_at = NOW();
    
    UPDATE public.portfolios 
    SET cash_balance = cash_balance - NEW.total_amount,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
  ELSIF NEW.type = 'sell' THEN
    SELECT shares_held INTO current_user_shares 
    FROM public.user_holdings 
    WHERE user_id = NEW.user_id AND property_id = NEW.property_id 
    FOR UPDATE;
    
    IF current_user_shares IS NULL OR current_user_shares < NEW.share_quantity THEN
      RAISE EXCEPTION 'Insufficient shares to sell';
    END IF;
    
    UPDATE public.properties 
    SET shares_available = shares_available + NEW.share_quantity,
        updated_at = NOW()
    WHERE property_id = NEW.property_id;
    
    UPDATE public.user_holdings 
    SET shares_held = shares_held - NEW.share_quantity,
        updated_at = NOW()
    WHERE user_id = NEW.user_id AND property_id = NEW.property_id;
    
    UPDATE public.portfolios 
    SET cash_balance = cash_balance + NEW.total_amount,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_process_transaction
  AFTER INSERT ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.process_transaction();

-- Function to recalculate portfolio equity
CREATE OR REPLACE FUNCTION public.recalculate_portfolio_equity()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.portfolios p
  SET total_equity_value = COALESCE(
    (SELECT SUM(uh.shares_held * prop.price_per_share)
     FROM public.user_holdings uh
     JOIN public.properties prop ON uh.property_id = prop.property_id
     WHERE uh.user_id = p.user_id),
    0
  ),
  updated_at = NOW();
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_property_valuation_change
  AFTER UPDATE OF price_per_share ON public.properties
  FOR EACH ROW EXECUTE FUNCTION public.recalculate_portfolio_equity();

-- Function to deduct withdrawal
CREATE OR REPLACE FUNCTION public.deduct_withdrawal(p_user_id UUID, p_amount NUMERIC)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.portfolios
  SET cash_balance = cash_balance - p_amount,
      updated_at = NOW()
  WHERE user_id = p_user_id;
END;
$$;

-- ==========================================
-- ROW LEVEL SECURITY POLICIES
-- ==========================================

-- Profiles policies
CREATE POLICY "profiles_select" ON public.profiles
  FOR SELECT USING (id = auth.uid() OR public.is_admin());

CREATE POLICY "profiles_update" ON public.profiles
  FOR UPDATE USING (id = auth.uid() OR public.is_admin());

-- Properties policies
CREATE POLICY "properties_select_all" ON public.properties
  FOR SELECT USING (true);

CREATE POLICY "properties_admin_all" ON public.properties
  FOR ALL USING (public.is_admin());

-- Portfolios policies
CREATE POLICY "portfolios_select_own" ON public.portfolios
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "portfolios_update_own" ON public.portfolios
  FOR UPDATE USING (user_id = auth.uid() OR public.is_admin());

-- Transactions policies
CREATE POLICY "transactions_select_own" ON public.transactions
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "transactions_insert_own" ON public.transactions
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- User holdings policies
CREATE POLICY "user_holdings_select_own" ON public.user_holdings
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

-- User roles policies
CREATE POLICY "Users can view their own roles"
ON public.user_roles
FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Admins can view all roles"
ON public.user_roles
FOR SELECT
USING (is_admin());

CREATE POLICY "Admins can insert roles"
ON public.user_roles
FOR INSERT
WITH CHECK (is_admin());

CREATE POLICY "Admins can delete roles"
ON public.user_roles
FOR DELETE
USING (is_admin());

-- Deposits policies
CREATE POLICY "deposits_select_own" 
ON public.deposits 
FOR SELECT 
USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "deposits_insert_own" 
ON public.deposits 
FOR INSERT 
WITH CHECK (user_id = auth.uid());

CREATE POLICY "deposits_update_admin" 
ON public.deposits 
FOR UPDATE 
USING (is_admin());

-- Distributions policies
CREATE POLICY "distributions_select_authenticated" 
ON public.distributions 
FOR SELECT 
USING (
  is_admin() OR 
  EXISTS (
    SELECT 1 
    FROM public.user_holdings 
    WHERE user_holdings.user_id = auth.uid() 
    AND user_holdings.property_id = distributions.property_id
    AND user_holdings.shares_held > 0
  )
);

CREATE POLICY "distributions_insert_admin" 
ON public.distributions 
FOR INSERT 
WITH CHECK (is_admin());

-- Distribution payments policies
CREATE POLICY "distribution_payments_select_own" 
ON public.distribution_payments 
FOR SELECT 
USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "distribution_payments_insert_admin" 
ON public.distribution_payments 
FOR INSERT 
WITH CHECK (is_admin());

-- Manual transactions policies
CREATE POLICY "manual_transactions_select" ON public.manual_transactions
  FOR SELECT USING ((user_id = auth.uid()) OR is_admin());

CREATE POLICY "manual_transactions_insert_admin" ON public.manual_transactions
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "manual_transactions_update_admin" ON public.manual_transactions
  FOR UPDATE USING (is_admin());

CREATE POLICY "manual_transactions_delete_admin" ON public.manual_transactions
  FOR DELETE USING (is_admin());

-- Payment settings policies
CREATE POLICY "payment_settings_select_all" ON public.payment_settings
  FOR SELECT USING (true);

CREATE POLICY "payment_settings_admin_all" ON public.payment_settings
  FOR ALL USING (is_admin());

-- Crypto wallets policies
CREATE POLICY "crypto_wallets_select_all" ON public.crypto_wallets
  FOR SELECT USING (true);

CREATE POLICY "crypto_wallets_admin_all" ON public.crypto_wallets
  FOR ALL USING (is_admin());

-- Withdrawals policies
CREATE POLICY "withdrawals_select_own" ON public.withdrawals
  FOR SELECT USING ((user_id = auth.uid()) OR is_admin());

CREATE POLICY "withdrawals_insert_own" ON public.withdrawals
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "withdrawals_update_admin" ON public.withdrawals
  FOR UPDATE USING (is_admin());

-- User withdrawal settings policies
CREATE POLICY "user_withdrawal_settings_select_own" ON public.user_withdrawal_settings
  FOR SELECT USING ((user_id = auth.uid()) OR is_admin());

CREATE POLICY "user_withdrawal_settings_admin_all" ON public.user_withdrawal_settings
  FOR ALL USING (is_admin());

-- ==========================================
-- INDEXES
-- ==========================================

CREATE INDEX idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX idx_transactions_property_id ON public.transactions(property_id);
CREATE INDEX idx_user_holdings_user_id ON public.user_holdings(user_id);
CREATE INDEX idx_properties_status ON public.properties(status);

-- ==========================================
-- DEFAULT DATA
-- ==========================================

-- Insert default payment settings
INSERT INTO public.payment_settings (payment_method, payment_address) VALUES
  ('cashapp', '$YourCashAppTag'),
  ('venmo', '@YourVenmoUsername'),
  ('paypal', 'your-email@paypal.com');

-- ==========================================
-- STORAGE BUCKET (Optional - for deposit receipts)
-- ==========================================

-- Create storage bucket for deposit receipts
INSERT INTO storage.buckets (id, name, public) 
VALUES ('deposit-receipts', 'deposit-receipts', false)
ON CONFLICT DO NOTHING;

-- Storage policies for deposit receipts
CREATE POLICY "Users can upload their own receipts" 
ON storage.objects 
FOR INSERT 
WITH CHECK (bucket_id = 'deposit-receipts' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own receipts" 
ON storage.objects 
FOR SELECT 
USING (bucket_id = 'deposit-receipts' AND (auth.uid()::text = (storage.foldername(name))[1] OR is_admin()));

CREATE POLICY "Admins can view all receipts" 
ON storage.objects 
FOR SELECT 
USING (bucket_id = 'deposit-receipts' AND is_admin());
