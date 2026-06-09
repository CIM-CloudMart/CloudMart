"""
CloudMart Product Service
Manages product catalogue: CRUD operations, search, category filtering.

Data Store:
  - Default: In-memory dictionary (for local dev / Docker Compose)
  - Cloud:   Set STORE_BACKEND=dynamodb|firestore|cosmosdb via env var
             to use a managed NoSQL database (requires workload identity / credentials)
"""

import os
import uuid
import logging
from datetime import datetime
from flask import Flask, jsonify, request, abort
import boto3
from botocore.exceptions import ClientError
from decimal import Decimal
from dotenv import load_dotenv

# AWS X-Ray Tracing Setup
from aws_xray_sdk.core import xray_recorder, patch_all
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware
patch_all()

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------
app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False
XRayMiddleware(app, xray_recorder)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("product-service")

# ---------------------------------------------------------------------------
# Data store abstraction
# ---------------------------------------------------------------------------

# Seed data
SEED_PRODUCTS = [
    {
        "id": "prod-001",
        "name": "Wireless Bluetooth Headphones",
        "description": "Premium noise-cancelling over-ear headphones with 30-hour battery life",
        "price": 79.99,
        "category": "electronics",
        "stock": 150,
        "imageUrl": "/images/headphones.jpg",
        "createdAt": "2025-01-15T10:00:00Z",
    },
    {
        "id": "prod-002",
        "name": "Organic Ceylon Tea (100 bags)",
        "description": "Premium hand-picked Ceylon black tea from Nuwara Eliya estates",
        "price": 12.99,
        "category": "food",
        "stock": 500,
        "imageUrl": "/images/ceylon-tea.jpg",
        "createdAt": "2025-01-15T10:00:00Z",
    },
    {
        "id": "prod-003",
        "name": "USB-C Laptop Stand",
        "description": "Adjustable aluminium stand with integrated USB-C hub (HDMI, USB 3.0, PD charging)",
        "price": 49.99,
        "category": "electronics",
        "stock": 75,
        "imageUrl": "/images/laptop-stand.jpg",
        "createdAt": "2025-01-15T10:00:00Z",
    },
    {
        "id": "prod-004",
        "name": "Handloom Cotton Sarong",
        "description": "Traditional Sri Lankan handloom sarong, 100% cotton, machine washable",
        "price": 24.99,
        "category": "clothing",
        "stock": 200,
        "imageUrl": "/images/sarong.jpg",
        "createdAt": "2025-01-15T10:00:00Z",
    },
    {
        "id": "prod-005",
        "name": "Mechanical Keyboard (TKL)",
        "description": "Tenkeyless mechanical keyboard with Cherry MX Brown switches, RGB backlight",
        "price": 89.99,
        "category": "electronics",
        "stock": 60,
        "imageUrl": "/images/keyboard.jpg",
        "createdAt": "2025-01-15T10:00:00Z",
    },
    {
        "id": "prod-006",
        "name": "Coconut Oil (Cold Pressed, 500ml)",
        "description": "Virgin cold-pressed coconut oil from Southern Province, Sri Lanka",
        "price": 8.99,
        "category": "food",
        "stock": 300,
        "imageUrl": "/images/coconut-oil.jpg",
        "createdAt": "2025-01-15T10:00:00Z",
    },
]


class InMemoryStore:
    """Simple in-memory product store for local development."""

    def __init__(self):
        self.products = {p["id"]: dict(p) for p in SEED_PRODUCTS}

    def get_all(self, category=None, search=None):
        results = list(self.products.values())
        if category:
            results = [p for p in results if p["category"] == category]
        if search:
            q = search.lower()
            results = [
                p
                for p in results
                if q in p["name"].lower() or q in p["description"].lower()
            ]
        return results

    def get_by_id(self, product_id):
        return self.products.get(product_id)

    def create(self, data):
        product_id = f"prod-{uuid.uuid4().hex[:6]}"
        product = {
            "id": product_id,
            "name": data["name"],
            "description": data.get("description", ""),
            "price": float(data["price"]),
            "category": data.get("category", "general"),
            "stock": int(data.get("stock", 0)),
            "imageUrl": data.get("imageUrl", ""),
            "createdAt": datetime.utcnow().isoformat() + "Z",
        }
        self.products[product_id] = product
        return product

    def update(self, product_id, data):
        if product_id not in self.products:
            return None
        product = self.products[product_id]
        for key in ["name", "description", "price", "category", "stock", "imageUrl"]:
            if key in data:
                product[key] = data[key]
        product["updatedAt"] = datetime.utcnow().isoformat() + "Z"
        return product

    def delete(self, product_id):
        return self.products.pop(product_id, None) is not None

    def check_stock(self, product_id, quantity):
        product = self.products.get(product_id)
        if not product:
            return False
        return product["stock"] >= quantity

    def decrement_stock(self, product_id, quantity):
        product = self.products.get(product_id)
        if product and product["stock"] >= quantity:
            product["stock"] -= quantity
            return True
        return False


# ---------------------------------------------------------------------------
# Cloud store adapters (students implement these for the assignment)
# ---------------------------------------------------------------------------

class DynamoDBStore:
    """
    AWS DynamoDB adapter.

    To use: set STORE_BACKEND=dynamodb and DYNAMODB_TABLE=<table-name>
    Optional: DYNAMODB_ENDPOINT for local Docker instance.
    """

    def __init__(self):
        table_name = os.getenv('DYNAMODB_TABLE')
        if not table_name:
            raise ValueError('DYNAMODB_TABLE environment variable is required for DynamoDB backend')
        endpoint = os.getenv('DYNAMODB_ENDPOINT')
        if endpoint:
            self.dynamodb = boto3.resource('dynamodb', endpoint_url=endpoint)
        else:
            self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
        
        # Seed logic
        try:
            if not self.get_all():
                for p in SEED_PRODUCTS:
                    item = {
                        'id': p['id'],
                        'name': p['name'],
                        'description': p.get('description', ''),
                        'price': Decimal(str(p['price'])),
                        'category': p.get('category', 'general'),
                        'stock': int(p.get('stock', 0)),
                        'imageUrl': p.get('imageUrl', ''),
                        'createdAt': p.get('createdAt', datetime.utcnow().isoformat() + 'Z'),
                    }
                    self.table.put_item(Item=item)
                logger.info("Successfully seeded DynamoDB with initial products.")
        except Exception as e:
            logger.warning(f"Failed to seed products: {e}")

    def _parse_item(self, item):
        """Convert DynamoDB item to plain dict (handles Decimal)."""
        import decimal
        def convert(value):
            if isinstance(value, decimal.Decimal):
                return float(value) if value % 1 else int(value)
            if isinstance(value, dict):
                return {k: convert(v) for k, v in value.items()}
            if isinstance(value, list):
                return [convert(v) for v in value]
            return value
        return {k: convert(v) for k, v in item.items()}

    def get_all(self, category=None, search=None):
        response = self.table.scan()
        items = [self._parse_item(i) for i in response.get('Items', [])]
        # Apply same filtering logic as InMemoryStore
        if category:
            items = [p for p in items if p.get('category') == category]
        if search:
            q = search.lower()
            items = [p for p in items if q in p.get('name', '').lower() or q in p.get('description', '').lower()]
        return items

    def get_by_id(self, product_id):
        response = self.table.get_item(Key={'id': product_id})
        item = response.get('Item')
        return self._parse_item(item) if item else None

    def create(self, data):
        product_id = f"prod-{uuid.uuid4().hex[:6]}"
        product = {
            'id': product_id,
            'name': data['name'],
            'description': data.get('description', ''),
            # Store price as Decimal to satisfy DynamoDB type requirements
            'price': Decimal(str(data['price'])),
            'category': data.get('category', 'general'),
            'stock': int(data.get('stock', 0)),
            'imageUrl': data.get('imageUrl', ''),
            'createdAt': datetime.utcnow().isoformat() + 'Z',
        }
        self.table.put_item(Item=product)
        return product

    def update(self, product_id, data):
        existing = self.get_by_id(product_id)
        if not existing:
            return None
        # Update fields
        for key in ['name', 'description', 'price', 'category', 'stock', 'imageUrl']:
            if key in data:
                if key == 'price':
                    existing[key] = Decimal(str(data[key]))
                else:
                    existing[key] = data[key]
        existing['updatedAt'] = datetime.utcnow().isoformat() + 'Z'
        self.table.put_item(Item=existing)
        return existing

    def delete(self, product_id):
        try:
            self.table.delete_item(Key={'id': product_id})
            return True
        except ClientError:
            return False

    def check_stock(self, product_id, quantity):
        product = self.get_by_id(product_id)
        if not product:
            return False
        return product.get('stock', 0) >= quantity

    def decrement_stock(self, product_id, quantity):
        try:
            # Conditional update to ensure stock is sufficient
            self.table.update_item(
                Key={'id': product_id},
                UpdateExpression='SET stock = stock - :qty',
                ConditionExpression='stock >= :qty',
                ExpressionAttributeValues={':qty': quantity},
            )
            return True
        except ClientError as e:
            # ConditionalCheckFailedException means insufficient stock
            return False


# FirestoreStore removed (not required for this assignment)


# CosmosDBStore removed (not required for this assignment)


def create_store():
    load_dotenv()
    backend = os.getenv("STORE_BACKEND", "memory").lower()
    if backend == "dynamodb":
        return DynamoDBStore()
    elif backend == "memory" or not backend:
        logger.info("Using in-memory product store (set STORE_BACKEND=dynamodb to use DynamoDB backend)")
        return InMemoryStore()
    else:
        raise NotImplementedError(f"Store backend '{backend}' is not supported in this implementation.")


store = create_store()

# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.route("/health")
def health():
    """Health check endpoint for Kubernetes liveness/readiness probes."""
    return jsonify({"status": "healthy", "service": "product-service"})


@app.route("/ready")
def ready():
    """Readiness check — verifies the store is accessible."""
    try:
        store.get_all()
        return jsonify({"status": "ready", "service": "product-service"})
    except Exception as e:
        return jsonify({"status": "not ready", "error": str(e)}), 503


@app.route("/products", methods=["GET"])
def list_products():
    """
    List all products.
    Query params: ?category=electronics  &search=headphone
    """
    category = request.args.get("category")
    search = request.args.get("search")
    products = store.get_all(category=category, search=search)
    return jsonify({"products": products, "count": len(products)})


@app.route("/products/<product_id>", methods=["GET"])
def get_product(product_id):
    """Get a single product by ID."""
    product = store.get_by_id(product_id)
    if not product:
        abort(404, description=f"Product {product_id} not found")
    return jsonify(product)


@app.route("/products", methods=["POST"])
def create_product():
    """Create a new product."""
    data = request.get_json()
    if not data or "name" not in data or "price" not in data:
        abort(400, description="Missing required fields: name, price")
    product = store.create(data)
    logger.info(f"Created product: {product['id']} — {product['name']}")
    return jsonify(product), 201


@app.route("/products/<product_id>", methods=["PUT"])
def update_product(product_id):
    """Update an existing product."""
    data = request.get_json()
    if not data:
        abort(400, description="Request body required")
    product = store.update(product_id, data)
    if not product:
        abort(404, description=f"Product {product_id} not found")
    logger.info(f"Updated product: {product_id}")
    return jsonify(product)


@app.route("/products/<product_id>", methods=["DELETE"])
def delete_product(product_id):
    """Delete a product."""
    if not store.delete(product_id):
        abort(404, description=f"Product {product_id} not found")
    logger.info(f"Deleted product: {product_id}")
    return jsonify({"message": f"Product {product_id} deleted"}), 200


@app.route("/products/<product_id>/stock", methods=["GET"])
def check_stock(product_id):
    """Check stock availability (called by order-service)."""
    product = store.get_by_id(product_id)
    if not product:
        abort(404, description=f"Product {product_id} not found")
    return jsonify(
        {"productId": product_id, "stock": product["stock"], "available": product["stock"] > 0}
    )


@app.route("/products/<product_id>/stock/decrement", methods=["POST"])
def decrement_stock(product_id):
    """Decrement stock after order placement (called by order-service)."""
    data = request.get_json() or {}
    quantity = int(data.get("quantity", 1))
    if not store.decrement_stock(product_id, quantity):
        abort(409, description=f"Insufficient stock for product {product_id}")
    logger.info(f"Decremented stock for {product_id} by {quantity}")
    return jsonify({"message": "Stock updated", "productId": product_id})


@app.route("/categories", methods=["GET"])
def list_categories():
    """List all unique product categories."""
    products = store.get_all()
    categories = sorted(set(p["category"] for p in products))
    return jsonify({"categories": categories})


# ---------------------------------------------------------------------------
# Error handlers
# ---------------------------------------------------------------------------


@app.errorhandler(400)
def bad_request(e):
    return jsonify({"error": "Bad Request", "message": str(e.description)}), 400


@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Not Found", "message": str(e.description)}), 404


@app.errorhandler(409)
def conflict(e):
    return jsonify({"error": "Conflict", "message": str(e.description)}), 409


@app.errorhandler(500)
def internal_error(e):
    logger.error(f"Internal Server Error: {e}")
    return jsonify({"error": "Internal Server Error"}), 500


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    load_dotenv()
    port = int(os.environ.get("PORT", 8001))
    debug = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
    logger.info(f"Starting product-service on port {port}")
    app.run(host="0.0.0.0", port=port, debug=debug)
