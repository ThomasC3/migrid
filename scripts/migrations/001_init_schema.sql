-- MiGrid Database Schema
-- PostgreSQL 15+ with TimescaleDB

CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE TABLE fleets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    grid_connection_limit_kw DECIMAL(10,2) DEFAULT 500,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fleet_id UUID REFERENCES fleets(id),
    vin VARCHAR(17) UNIQUE NOT NULL,
    make VARCHAR(100),
    model VARCHAR(100),
    battery_capacity_kwh DECIMAL(10,2) NOT NULL,
    current_soc DECIMAL(5,2) DEFAULT 50.0,
    is_plugged_in BOOLEAN DEFAULT false,
    v2g_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE charging_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES vehicles(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    start_soc DECIMAL(5,2),
    end_soc DECIMAL(5,2),
    energy_dispensed_kwh DECIMAL(10,3),
    variance_percentage DECIMAL(5,2),
    is_valid BOOLEAN
);

SELECT create_hypertable('charging_sessions', 'start_time', if_not_exists => TRUE);
