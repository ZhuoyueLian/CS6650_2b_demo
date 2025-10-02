from locust import HttpUser, task, between
import random

class ProductAPIUser(HttpUser):
    wait_time = between(1, 3)
    
    @task(3)  # GET will be called 3x more often than POST
    def get_product(self):
        product_id = random.randint(1, 1000)
        self.client.get(f"/products/{product_id}")
    
    @task(1)
    def post_product(self):
        product_id = random.randint(1, 1000)
        self.client.post(f"/products/{product_id}/details", json={
            "product_id": product_id,
            "sku": f"SKU-{product_id}",
            "manufacturer": "Locust Test",
            "category_id": random.randint(1, 10),
            "weight": random.randint(100, 5000),
            "some_other_id": random.randint(1, 999)
        })
