"""Initial migration - Capacity Connect v1.0.0

Revision ID: 001_initial
Revises: 
Create Date: 2026-08-31

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '001_initial'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # Users
    op.create_table('users',
        sa.Column('id', sa.String(), nullable=False),
        sa.Column('username', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('password_hash', sa.String(), nullable=False),
        sa.Column('role', sa.String(), nullable=False),
        sa.Column('display_name', sa.String(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('last_login_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)
    
    # Components
    op.create_table('components',
        sa.Column('id', sa.String(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('category', sa.String(), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('manufacturer', sa.String(), nullable=False),
        sa.Column('model', sa.String(), nullable=False),
        sa.Column('mesh_id', sa.String(), nullable=False),
        sa.Column('x', sa.Float(), nullable=True),
        sa.Column('y', sa.Float(), nullable=True),
        sa.Column('z', sa.Float(), nullable=True),
        sa.Column('status', sa.String(), nullable=True),
        sa.Column('installation_location', sa.String(), nullable=False),
        sa.Column('possible_faults', sa.JSON(), nullable=True),
        sa.Column('maintenance_procedures', sa.JSON(), nullable=True),
        sa.Column('training_references', sa.JSON(), nullable=True),
        sa.Column('documentation_references', sa.JSON(), nullable=True),
        sa.Column('last_inspection', sa.DateTime(), nullable=True),
        sa.Column('next_maintenance', sa.DateTime(), nullable=True),
        sa.Column('version', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_components_mesh_id'), 'components', ['mesh_id'], unique=True)
    
    # Diagnostics
    op.create_table('diagnostics',
        sa.Column('id', sa.String(), nullable=False),
        sa.Column('component_id', sa.String(), nullable=False),
        sa.Column('reported_by', sa.String(), nullable=False),
        sa.Column('title', sa.String(), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('ai_analysis', sa.Text(), nullable=True),
        sa.Column('fault_code', sa.String(), nullable=True),
        sa.Column('severity', sa.String(), nullable=True),
        sa.Column('status', sa.String(), nullable=True),
        sa.Column('recommended_actions', sa.Text(), nullable=True),
        sa.Column('technician_action', sa.Text(), nullable=True),
        sa.Column('resolution_notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.Column('sync_status', sa.String(), nullable=True),
        sa.Column('version', sa.Integer(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_diagnostics_component_id'), 'diagnostics', ['component_id'], unique=False)

def downgrade() -> None:
    op.drop_index(op.f('ix_diagnostics_component_id'), table_name='diagnostics')
    op.drop_table('diagnostics')
    op.drop_index(op.f('ix_components_mesh_id'), table_name='components')
    op.drop_table('components')
    op.drop_index(op.f('ix_users_username'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')
