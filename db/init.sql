CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    service_name VARCHAR(50) NOT NULL,
    request_id UUID,
    action_performed TEXT NOT NULL,
    status VARCHAR(20) NOT NULL,
    source VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS request_states (
    id SERIAL PRIMARY KEY,
    request_id UUID NOT NULL,
    state VARCHAR(50) NOT NULL,
    service_name VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);