-- Add severityLabels to ConfigurationKey enum
ALTER TYPE "ConfigurationKey" ADD VALUE IF NOT EXISTS 'severityLabels';
