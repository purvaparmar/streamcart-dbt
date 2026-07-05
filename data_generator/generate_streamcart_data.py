import json
import random
from datetime import datetime,timedelta
from faker import Faker
import snowflake.connector

faker = Faker("en_IN")
conn = snowflake.connector.connect(
    user="purva2114",
    password = "Prashilparmar@0307",
    account="munpsrp-zhb98455",
    database = "DBT_ASSIGN",
    schema ="RAW"
)
cursor = conn.cursor()
cursor.execute("SELECT CURRENT_VERSION()")
print(cursor.fetchone())


def generate_product(product_number):

    product = {
        "product_id": f"P-{product_number:03d}",
        "name": f" Samsung TV {random.randint(32,75)} inch ",
        "category": random.choice([
            "ELECTRONICS",
            "APPAREL",
            "HOME GOODS"
        ]),
        "sub_category": random.choice([
            "televisions",
            "shirts",
            "kitchen"
        ]),
        "brand": random.choice([
            "samsung",
            "lg",
            "sony",
            "nike",
            "puma"
        ]),
        "is_available": random.choice([
            "1",
            "0",
            "YES",
            "NO",
            "true",
            "false"
        ]),
        "tags": [
            "smart",
            "4K",
            "OLED"
        ],

        "specs": {
            "weight_kg": str(round(random.uniform(1,20),1)),
            "warranty_yr": str(random.randint(1,5))
        },

        "pricing": {
            "cost_price": round(random.uniform(100,1000),2),
            "list_price": round(random.uniform(1000,2000),2),
            "currency": "USD"
        },

        "stock": {
            "qty_on_hand": str(random.randint(0,100)),
            "reorder_lvl": str(random.randint(5,20)),
            "warehouse": random.choice([
                "WH-WEST",
                "WH-EAST"
            ])
        }
    }

    return product

product = generate_product(1)

print(json.dumps(product, indent=4))

product = generate_product(1)
cursor.execute(
    """
    INSERT INTO RAW_PRODUCTS
    (DATA, _LOADED_AT)
    VALUES
    (PARSE_JSON(%s), CURRENT_TIMESTAMP())
    """,
    (json.dumps(product),)
)
conn.commit()
print("Inserted successfully")
