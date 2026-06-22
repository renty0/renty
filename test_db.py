import urllib.request
import json
import subprocess

def test():
    # 1. Get user roles
    token_cmd = 'psql "postgresql://neondb_owner:npg_0hBeijOPT4cL@ep-sweet-shadow-ag0l2dna-pooler.c-2.eu-central-1.aws.neon.tech/rentyDB?sslmode=require" -t -c "SELECT r.\\"Name\\" FROM \\"AspNetUserRoles\\" ur JOIN \\"Roles\\" r ON ur.\\"RoleId\\" = r.\\"Id\\" JOIN \\"Users\\" u ON ur.\\"UserId\\" = u.\\"Id\\" WHERE u.\\"Email\\" = \'admin@renty.com\';" -q'
    roles = subprocess.check_output(token_cmd, shell=True).decode('utf-8').strip()
    print(f"Roles for admin@renty.com: {roles}")

test()
