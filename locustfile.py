from locust import FastHttpUser, task, between
import random

class ProductSearchUser(FastHttpUser):
    wait_time = between(0.1, 0.5)  # Minimal wait time for aggressive testing
    
    # Common search terms that will find results
    search_terms = [
        "alpha", "beta", "gamma", "delta", "epsilon",
        "electronics", "books", "home", "sports", "toys",
        "product", "1", "2", "3"
    ]
    
    @task
    def search_products(self):
        query = random.choice(self.search_terms)
        self.client.get(f"/products/search?q={query}", name="/products/search")
    
    @task(1)  # Less frequent than search
    def health_check(self):
        self.client.get("/health")