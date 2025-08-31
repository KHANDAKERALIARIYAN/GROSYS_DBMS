from django.db import models
from django.contrib.auth.models import User



class Category(models.Model):
    id = models.BigIntegerField(primary_key=True, db_column='ID')
    name = models.CharField(max_length=100, db_column='NAME')
    description = models.TextField(db_column='DESCRIPTION', blank=True, null=True)

    class Meta:
        db_table = 'INVENTORY_CATEGORY'

    def __str__(self):
        return self.name



class Supplier(models.Model):
    id = models.BigIntegerField(primary_key=True, db_column='ID')
    name = models.CharField(max_length=150, db_column='NAME')
    contact_person = models.CharField(max_length=100, db_column='CONTACT_PERSON', blank=True, null=True)
    phone = models.CharField(max_length=20, db_column='PHONE', blank=True, null=True)
    email = models.EmailField(db_column='EMAIL', blank=True, null=True)
    address = models.TextField(db_column='ADDRESS', blank=True, null=True)

    class Meta:
        db_table = 'INVENTORY_SUPPLIER'

    def __str__(self):
        return self.name


class Product(models.Model):
    name = models.CharField(max_length=100)
    sku = models.CharField(max_length=50, unique=True)   # Stock Keeping Unit
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    supplier = models.ForeignKey(Supplier, on_delete=models.SET_NULL, null=True, blank=True)
    quantity = models.IntegerField(default=0)
    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.name} ({self.sku})"


class Purchase(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Purchase {self.product.name} x {self.quantity}"


class Sale(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Sale {self.product.name} x {self.quantity}"
