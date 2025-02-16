# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "python-dotenv",
# ]
# ///

# uv run backup_bg.py


import os
from datetime import datetime
from dotenv import load_dotenv
import subprocess

# Load environment variables from .env file
load_dotenv()

# Get database credentials from environment variables
DB_NAME = os.getenv('DATA_DB_NAME')
DB_USER = os.getenv('DATA_DB_USER')
DB_PASSWORD = os.getenv('DATA_DB_PASSWORD')
DB_HOST = os.getenv('DATA_DB_HOST')
DB_PORT = os.getenv('DATA_DB_PORT')

# Create backup filename with timestamp
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
backup_file = f"backup_{DB_NAME}_{timestamp}.sql"

# Construct the pg_dump command
backup_command = [
    'pg_dump',
    '-h', DB_HOST,
    '-p', DB_PORT,
    '-U', DB_USER,
    '-d', DB_NAME,
    '-f', backup_file
]

# Set PGPASSWORD environment variable
os.environ['PGPASSWORD'] = DB_PASSWORD

def main() -> None:
    try:
        # Execute the backup command
        subprocess.run(backup_command, check=True)
        print(f"Backup completed successfully! File: {backup_file}")
    except subprocess.CalledProcessError as e:
        print(f"Backup failed! Error: {e}")
    finally:
        # Clear the password from environment
        os.environ['PGPASSWORD'] = ''


if __name__ == "__main__":
    main()
