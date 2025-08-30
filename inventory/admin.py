from django.contrib import admin
from .models import Product

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'sku', 'quantity', 'price')
    search_fields = ('name', 'sku')
    list_editable = ('quantity', 'price')
